FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    proj-bin \
    libproj-dev \
    && rm -rf /var/lib/apt/lists/*

# [SEC-05] Criar grupo e usuário sem privilégios — o processo nunca roda como root.
# Isso limita o raio de explosão de uma RCE: mesmo que o processo seja comprometido,
# o atacante não terá acesso de root ao container.
RUN addgroup --system geoadmin && adduser --system --ingroup geoadmin geoadmin

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# [SEC-05] Copy only application files, excluding sensitive content via .dockerignore
# to prevent secrets, version control, and test data from being included in the image.
COPY --chown=geoadmin:geoadmin main.py gunicorn_conf.py ./
COPY --chown=geoadmin:geoadmin src ./src
# [SEC-05] Garantir que todos os diretórios de dados pertencem ao usuário não-root
# antes de efetuar a troca de contexto com USER.
RUN mkdir -p /app/uploads /app/data && chown -R geoadmin:geoadmin /app

# [SEC-05] Trocar para usuário sem privilégios — todas as instruções posteriores
# (incluindo CMD/ENTRYPOINT) serão executadas como 'geoadmin', não como root.
USER geoadmin

EXPOSE 8080

# [SEC-13] HEALTHCHECK garante que orquestradores (Cloud Run, Docker Compose, K8s)
# detectem falhas e reiniciem o container automaticamente.
# - start-period=40s: aguarda o FastAPI inicializar completamente antes de pontuar
# - timeout=10s: margem razoável para resposta sob carga
# - interval=30s / retries=3: 3 falhas consecutivas = container unhealthy
# Usa urllib da stdlib — sem dependência de curl na imagem slim.
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"]

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}"]
