import { Platform } from 'react-native';

type JsonValue =
  | string
  | number
  | boolean
  | null
  | JsonValue[]
  | { [key: string]: JsonValue };

export type JsonObject = { [key: string]: JsonValue };

// Token de autenticação do Supabase — defina via definirToken()
let _authToken: string | null = null;

export function definirToken(token: string | null): void {
  _authToken = token;
}

function sanitizeBaseUrl(url: string): string {
  return url.trim().replace(/\/+$/, '');
}

function getExplicitApiBaseUrl(): string | null {
  const explicitUrl = process.env.EXPO_PUBLIC_API_BASE_URL?.trim();
  if (!explicitUrl) {
    return null;
  }

  return sanitizeBaseUrl(explicitUrl);
}

function isDevelopmentRuntime(): boolean {
  if (typeof __DEV__ !== 'undefined') {
    return __DEV__;
  }

  return process.env.NODE_ENV !== 'production';
}

function getRequiredProductionApiBaseUrl(context: string): string {
  const explicitUrl = getExplicitApiBaseUrl();
  if (explicitUrl) {
    return explicitUrl;
  }

  throw new Error(
    `EXPO_PUBLIC_API_BASE_URL é obrigatória para ${context}. Defina a URL pública do Cloud Run antes do deploy.`
  );
}

function getExpoConstants(): any | null {
  try {
    const modulo = require('expo-constants')
    return modulo.default ?? modulo
  } catch {
    return null
  }
}

function extractHostFromExpoConfig(): string | null {
  const constants = getExpoConstants()
  if (!constants) {
    return null
  }

  const expoConfigHost =
    (constants.expoConfig as { hostUri?: string } | null)?.hostUri ??
    (constants as { manifest2?: { extra?: { expoGo?: { debuggerHost?: string } } } }).manifest2
      ?.extra?.expoGo?.debuggerHost ??
    (constants as { manifest?: { debuggerHost?: string } }).manifest?.debuggerHost;

  if (!expoConfigHost) {
    return null;
  }

  return expoConfigHost.split(':')[0] ?? null;
}

function getApiBaseUrlWeb(): string {
  const explicitUrl = getExplicitApiBaseUrl();

  if (typeof window === 'undefined') {
    if (explicitUrl) {
      return explicitUrl;
    }
    if (isDevelopmentRuntime()) {
      return 'http://127.0.0.1:8001';
    }
    return getRequiredProductionApiBaseUrl('builds web fora do ambiente local');
  }

  const { hostname, origin, port, protocol } = window.location;

  const hostLocal =
    hostname === 'localhost' ||
    hostname === '127.0.0.1' ||
    hostname.startsWith('192.168.') ||
    hostname.startsWith('10.') ||
    /^172\.(1[6-9]|2\d|3[0-1])\./.test(hostname);

  if (hostLocal && port === '8001') {
    return sanitizeBaseUrl(origin);
  }

  if (hostLocal && hostname) {
    return `${protocol}//${hostname}:8001`;
  }

  return getRequiredProductionApiBaseUrl('publicações web no Vercel');
}

export function getApiBaseUrl(): string {
  if (Platform.OS === 'web') {
    return getApiBaseUrlWeb();
  }

  const explicitUrl = getExplicitApiBaseUrl();
  if (explicitUrl) {
    return explicitUrl;
  }

  const host = extractHostFromExpoConfig();
  if (host) {
    return `http://${host}:8000`;
  }

  if (isDevelopmentRuntime() && Platform.OS === 'android') {
    return 'http://10.0.2.2:8000';
  }

  if (isDevelopmentRuntime()) {
    return 'http://127.0.0.1:8000';
  }

  // URL oficial do Cloud Run — usada em builds de produção sem variável de ambiente
  return 'https://geoadmin-api-800479022570.us-central1.run.app';
}

function formatErrorDetail(detail: JsonValue | undefined): string {
  if (!detail) {
    return 'Falha na comunicação com o backend.';
  }

  if (typeof detail === 'string') {
    return detail;
  }

  if (Array.isArray(detail)) {
    return detail.map((item) => formatErrorDetail(item)).join(' | ');
  }

  if (typeof detail === 'object') {
    if (typeof detail.erro === 'string') {
      return detail.erro;
    }

    return Object.entries(detail)
      .map(([key, value]) => `${key}: ${formatErrorDetail(value)}`)
      .join(' | ');
  }

  return String(detail);
}

/**
 * Envoltório para fetch com timeout automático.
 * Aborta a requisição se ultrapassar timeoutMs.
 */
function fetchComTimeout(
  url: string,
  opcoes?: RequestInit,
  timeoutMs = 15000
): Promise<Response> {
  const controlador = new AbortController();
  const timer = setTimeout(() => controlador.abort(), timeoutMs);

  return fetch(url, { ...opcoes, signal: controlador.signal }).finally(() =>
    clearTimeout(timer)
  );
}

async function parseResponse<T>(response: Response): Promise<T> {
  const contentType = response.headers.get('content-type') ?? '';
  const payload = contentType.includes('application/json')
    ? ((await response.json()) as JsonValue)
    : ((await response.text()) as JsonValue);

  if (!response.ok) {
    if (typeof payload === 'object' && payload && 'detail' in payload) {
      throw new Error(formatErrorDetail(payload.detail as JsonValue));
    }

    throw new Error(formatErrorDetail(payload));
  }

  return payload as T;
}

/**
 * Mapeia erros de timeout e abort para mensagens amigáveis.
 */
function tratarErroFetch(erro: unknown): Error {
  if (erro instanceof DOMException && erro.name === 'AbortError') {
    return new Error('Requisição expirou — o servidor levou muito tempo para responder.');
  }
  if (erro instanceof Error) {
    return erro;
  }
  return new Error(String(erro));
}

export async function apiGet<T>(path: string): Promise<T> {
  try {
    const headers: Record<string, string> = {};
    if (_authToken) {
      headers['Authorization'] = `Bearer ${_authToken}`;
    }
    const response = await fetchComTimeout(`${getApiBaseUrl()}${path}`, {
      headers,
    });
    return parseResponse<T>(response);
  } catch (erro) {
    throw tratarErroFetch(erro);
  }
}

export async function apiPost<T>(path: string, body: JsonValue): Promise<T> {
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (_authToken) {
      headers['Authorization'] = `Bearer ${_authToken}`;
    }
    const response = await fetchComTimeout(`${getApiBaseUrl()}${path}`, {
      method: 'POST',
      headers,
      body: JSON.stringify(body),
    });

    return parseResponse<T>(response);
  } catch (erro) {
    throw tratarErroFetch(erro);
  }
}

export async function apiPostFormData<T>(path: string, body: FormData): Promise<T> {
  try {
    const headers: Record<string, string> = {};
    if (_authToken) {
      headers['Authorization'] = `Bearer ${_authToken}`;
    }
    const response = await fetchComTimeout(`${getApiBaseUrl()}${path}`, {
      method: 'POST',
      headers,
      body,
    });

    return parseResponse<T>(response);
  } catch (erro) {
    throw tratarErroFetch(erro);
  }
}

export async function apiPatch<T>(path: string, body: JsonValue): Promise<T> {
  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (_authToken) {
      headers['Authorization'] = `Bearer ${_authToken}`;
    }
    const response = await fetchComTimeout(`${getApiBaseUrl()}${path}`, {
      method: 'PATCH',
      headers,
      body: JSON.stringify(body),
    });

    return parseResponse<T>(response);
  } catch (erro) {
    throw tratarErroFetch(erro);
  }
}

export async function apiDelete<T>(path: string): Promise<T> {
  try {
    const headers: Record<string, string> = {};
    if (_authToken) {
      headers['Authorization'] = `Bearer ${_authToken}`;
    }
    const response = await fetchComTimeout(`${getApiBaseUrl()}${path}`, {
      method: 'DELETE',
      headers,
    });

    return parseResponse<T>(response);
  } catch (erro) {
    throw tratarErroFetch(erro);
  }
}

