import { Platform } from 'react-native'

const CHAVE_SESSAO = 'geoadmin.auth.sessao'

export type UsuarioSessao = {
  id: string
  email?: string | null
  role?: string | null
  nome?: string | null
}

export type SessaoAuth = {
  access_token: string
  refresh_token: string | null
  expires_at?: number | null
  expires_in?: number | null
  token_type?: string | null
  user: UsuarioSessao
}

async function salvarNoSecureStore(valor: string): Promise<void> {
  const SecureStore = await import('expo-secure-store')
  await SecureStore.setItemAsync(CHAVE_SESSAO, valor)
}

async function carregarDoSecureStore(): Promise<string | null> {
  const SecureStore = await import('expo-secure-store')
  return SecureStore.getItemAsync(CHAVE_SESSAO)
}

async function limparDoSecureStore(): Promise<void> {
  const SecureStore = await import('expo-secure-store')
  await SecureStore.deleteItemAsync(CHAVE_SESSAO)
}

export async function salvarSessaoAuth(sessao: SessaoAuth): Promise<void> {
  const serializado = JSON.stringify(sessao)
  if (Platform.OS === 'web') {
    if (typeof window !== 'undefined') {
      window.localStorage.setItem(CHAVE_SESSAO, serializado)
    }
    return
  }
  await salvarNoSecureStore(serializado)
}

export async function carregarSessaoAuth(): Promise<SessaoAuth | null> {
  let bruto: string | null = null
  if (Platform.OS === 'web') {
    if (typeof window === 'undefined') {
      return null
    }
    bruto = window.localStorage.getItem(CHAVE_SESSAO)
  } else {
    bruto = await carregarDoSecureStore()
  }

  if (!bruto) return null

  try {
    return JSON.parse(bruto) as SessaoAuth
  } catch {
    return null
  }
}

export async function limparSessaoAuth(): Promise<void> {
  if (Platform.OS === 'web') {
    if (typeof window !== 'undefined') {
      window.localStorage.removeItem(CHAVE_SESSAO)
    }
    return
  }
  await limparDoSecureStore()
}
