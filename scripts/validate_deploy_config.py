from __future__ import annotations

import json
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read_text(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def read_json(relative_path: str) -> object:
    return json.loads(read_text(relative_path))


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def ensure_contains(errors: list[str], relative_path: str, snippets: list[str]) -> None:
    content = read_text(relative_path)
    for snippet in snippets:
        if snippet not in content:
            fail(errors, f"{relative_path} deveria conter {snippet!r}.")


def ensure_absent(errors: list[str], relative_path: str, forbidden: list[str]) -> None:
    content = read_text(relative_path)
    for token in forbidden:
        if token in content:
            fail(errors, f"{relative_path} ainda contém referência proibida: {token!r}.")


def validate_vercel_json(errors: list[str]) -> None:
    config = read_json("vercel.json")
    rewrites = config.get("rewrites", [])
    if rewrites:
        fail(errors, "vercel.json não deve conter rewrites ativos enquanto a web usa saída prebuilt.")

    headers = {
        entry["source"]: {item["key"]: item["value"] for item in entry.get("headers", [])}
        for entry in config.get("headers", [])
    }
    expected = {
        "/_expo/static/(.*)": {"Cache-Control": "public, max-age=31536000, immutable"},
        "/assets/(.*)": {
            "Cache-Control": "public, max-age=86400",
            "Access-Control-Allow-Origin": "*",
        },
        "/(.*)": {
            "X-Content-Type-Options": "nosniff",
            "Referrer-Policy": "strict-origin-when-cross-origin",
        },
    }
    for source, required_headers in expected.items():
        actual_headers = headers.get(source)
        if actual_headers is None:
            fail(errors, f"vercel.json deveria declarar headers para {source}.")
            continue
        for key, value in required_headers.items():
            if actual_headers.get(key) != value:
                fail(
                    errors,
                    f"vercel.json deveria definir {key}={value!r} em {source}.",
                )


def validate_vercel_output_config(errors: list[str]) -> None:
    config = read_json("scripts/vercel-output-config.json")
    routes = config.get("routes", [])
    if not routes:
        fail(errors, "scripts/vercel-output-config.json deveria conter rotas com headers.")
        return

    required_sources = {
        "^/_expo/static/(.*)": {"Cache-Control": "public, max-age=31536000, immutable"},
        "^/assets/(.*)": {
            "Cache-Control": "public, max-age=86400",
            "Access-Control-Allow-Origin": "*",
        },
        "^/(.*)": {
            "X-Content-Type-Options": "nosniff",
            "Referrer-Policy": "strict-origin-when-cross-origin",
        },
    }

    indexed_routes = {route.get("src"): route.get("headers", {}) for route in routes}
    for src, required_headers in required_sources.items():
        actual_headers = indexed_routes.get(src)
        if actual_headers is None:
            fail(errors, f"scripts/vercel-output-config.json deveria conter a rota {src}.")
            continue
        for key, value in required_headers.items():
            if actual_headers.get(key) != value:
                fail(
                    errors,
                    f"scripts/vercel-output-config.json deveria definir {key}={value!r} em {src}.",
                )


def main() -> int:
    errors: list[str] = []

    forbidden_runtime_refs = ["railway.app", "*.up.railway.app", "RAILWAY_PUBLIC_DOMAIN"]
    for relative_path in (
        "vercel.json",
        "scripts/vercel-output-config.json",
        "backend/.env.example",
        "backend/main.py",
        "backend/routes/documentos.py",
        "mobile/lib/api.ts",
    ):
        ensure_absent(errors, relative_path, forbidden_runtime_refs)

    ensure_contains(
        errors,
        ".github/workflows/deploy-web.yml",
        [
            "EXPO_PUBLIC_API_BASE_URL",
            "VERCEL_ORG_ID",
            "VERCEL_PROJECT_ID",
            "npx vercel deploy --prebuilt --prod",
        ],
    )
    ensure_contains(
        errors,
        ".github/workflows/deploy-api-cloud-run.yml",
        [
            "CLOUD_RUN_RUNTIME_SERVICE_ACCOUNT",
            "PUBLIC_APP_URL",
            "SUPABASE_URL",
            "ALLOWED_ORIGINS",
            "ALLOWED_HOSTS",
            "AUTH_OBRIGATORIO=true",
            "Smoke test /health",
        ],
    )
    ensure_contains(
        errors,
        "scripts/deploy_api_cloud_run.ps1",
        [
            "AUTH_OBRIGATORIO=true",
            "Cloud Run nao pode expor AUTH_PERMITIR_BYPASS_IMPLANTACAO",
            "Cloud Run deve estar com EXPOSE_API_DOCS=false",
        ],
    )
    ensure_contains(
        errors,
        "backend/.env.example",
        [
            "PUBLIC_APP_URL=",
            "service role",
        ],
    )
    ensure_contains(
        errors,
        "docs/CONTEXTO_PROJETO.md",
        [
            "service role key",
            "Cloud Run",
            "Vercel",
            "MAPA_PROMOCAO_AMBIENTES.md",
        ],
    )
    ensure_contains(
        errors,
        "mobile/lib/api.ts",
        [
            "publicações web no Vercel",
            "builds mobile publicados via EAS/APK",
            "Cloud Run antes do deploy",
        ],
    )
    ensure_absent(
        errors,
        ".github/workflows/deploy-api-cloud-run.yml",
        [
            "AUTH_PERMITIR_BYPASS_IMPLANTACAO=",
        ],
    )
    ensure_absent(
        errors,
        "scripts/deploy_api_cloud_run.ps1",
        [
            "AUTH_PERMITIR_BYPASS_IMPLANTACAO=",
        ],
    )
    ensure_absent(
        errors,
        "docs/CONTEXTO_PROJETO.md",
        [
            "anon public",
            "Documents\\GeoAdmin-Pro\\backend",
            "http://127.0.0.1:8000/docs",
        ],
    )

    validate_vercel_json(errors)
    validate_vercel_output_config(errors)

    if errors:
        print("Falha na auditoria de configuração de deploy:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Configuração de deploy validada com sucesso.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
