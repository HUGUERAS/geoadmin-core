import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react'

import { apiGet, apiPost, definirToken } from './api'
import {
  carregarSessaoAuth,
  limparSessaoAuth,
  salvarSessaoAuth,
  type SessaoAuth,
  type UsuarioSessao,
} from './auth-storage'

type LoginPayload = {
  access_token: string
  refresh_token: string | null
  expires_at?: number | null
  expires_in?: number | null
  token_type?: string | null
  user: UsuarioSessao
}

type AuthContextValue = {
  carregando: boolean
  autenticado: boolean
  sessao: SessaoAuth | null
  usuario: UsuarioSessao | null
  entrar: (email: string, senha: string) => Promise<void>
  sair: () => Promise<void>
  revalidar: () => Promise<void>
}

const AuthContext = createContext<AuthContextValue | null>(null)

function normalizarSessao(payload: LoginPayload): SessaoAuth {
  return {
    access_token: payload.access_token,
    refresh_token: payload.refresh_token ?? null,
    expires_at: payload.expires_at ?? null,
    expires_in: payload.expires_in ?? null,
    token_type: payload.token_type ?? 'bearer',
    user: payload.user,
  }
}

async function obterSessaoRenovada(refreshToken: string): Promise<SessaoAuth> {
  const resposta = await apiPost<LoginPayload>('/auth/refresh', {
    refresh_token: refreshToken,
  })
  return normalizarSessao(resposta)
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [carregando, setCarregando] = useState(true)
  const [sessao, setSessao] = useState<SessaoAuth | null>(null)

  const aplicarSessao = useCallback(async (novaSessao: SessaoAuth | null) => {
    definirToken(novaSessao?.access_token ?? null)
    setSessao(novaSessao)
    if (novaSessao) {
      await salvarSessaoAuth(novaSessao)
    } else {
      await limparSessaoAuth()
    }
  }, [])

  const limparSessao = useCallback(async () => {
    await aplicarSessao(null)
  }, [aplicarSessao])

  const revalidar = useCallback(async () => {
    const salva = await carregarSessaoAuth()
    if (!salva) {
      await limparSessao()
      return
    }

    definirToken(salva.access_token)

    try {
      const resposta = await apiGet<{ user: UsuarioSessao }>('/auth/me')
      const atualizada = {
        ...salva,
        user: resposta.user ?? salva.user,
      }
      await aplicarSessao(atualizada)
      return
    } catch {}

    if (!salva.refresh_token) {
      await limparSessao()
      return
    }

    try {
      const renovada = await obterSessaoRenovada(salva.refresh_token)
      await aplicarSessao(renovada)
    } catch {
      await limparSessao()
    }
  }, [aplicarSessao, limparSessao])

  useEffect(() => {
    let ativo = true

    const bootstrap = async () => {
      try {
        await revalidar()
      } finally {
        if (ativo) {
          setCarregando(false)
        }
      }
    }

    bootstrap().catch(() => {
      if (ativo) {
        setCarregando(false)
      }
    })

    return () => {
      ativo = false
    }
  }, [revalidar])

  const entrar = useCallback(async (email: string, senha: string) => {
    const resposta = await apiPost<LoginPayload>('/auth/login', { email, senha })
    await aplicarSessao(normalizarSessao(resposta))
  }, [aplicarSessao])

  const sair = useCallback(async () => {
    await limparSessao()
  }, [limparSessao])

  const valor = useMemo<AuthContextValue>(() => ({
    carregando,
    autenticado: Boolean(sessao?.access_token),
    sessao,
    usuario: sessao?.user ?? null,
    entrar,
    sair,
    revalidar,
  }), [carregando, entrar, revalidar, sair, sessao])

  return <AuthContext.Provider value={valor}>{children}</AuthContext.Provider>
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth deve ser usado dentro de AuthProvider')
  }
  return context
}
