/**
 * mobile/lib/db.web.ts
 * Persistencia real para web usando IndexedDB.
 */

import { SyncStatus, PontoLocal } from '../types/ponto'

export { SyncStatus, PontoLocal }

const NOME_BANCO = 'geoadmin_pro_web'
const VERSAO_BANCO = 1
const STORE_PONTOS = 'pontos_locais'
const STORE_APP_CONFIG = 'app_config'
const STORE_PROJETOS_CACHE = 'projetos_cache'
const CHAVE_ULTIMO_PROJETO_MAPA = 'ultimo_projeto_mapa'

type RegistroPontoWeb = PontoLocal

type RegistroProjetoCacheWeb = {
  id: string
  dados: string
  cached_em: string
}

type RegistroAppConfigWeb = {
  chave: string
  valor: string
  atualizado_em: string
}

let _dbPromise: Promise<IDBDatabase> | null = null

function _agoraIso(): string {
  return new Date().toISOString()
}

function _normalizarPonto(ponto: Omit<PontoLocal, 'sync_status' | 'sync_tentativas'>): RegistroPontoWeb {
  return {
    ...ponto,
    sync_status: 'pending',
    sync_tentativas: 0,
  }
}

function _abrirBanco(): Promise<IDBDatabase> {
  if (typeof indexedDB === 'undefined') {
    return Promise.reject(new Error('IndexedDB indisponivel neste ambiente web'))
  }

  if (!_dbPromise) {
    _dbPromise = new Promise((resolve, reject) => {
      const requisicao = indexedDB.open(NOME_BANCO, VERSAO_BANCO)

      requisicao.onupgradeneeded = () => {
        const db = requisicao.result

        if (!db.objectStoreNames.contains(STORE_PONTOS)) {
          const pontos = db.createObjectStore(STORE_PONTOS, { keyPath: 'id' })
          pontos.createIndex('projeto_id', 'projeto_id', { unique: false })
          pontos.createIndex('sync_status', 'sync_status', { unique: false })
          pontos.createIndex('coletado_em', 'coletado_em', { unique: false })
        }

        if (!db.objectStoreNames.contains(STORE_APP_CONFIG)) {
          db.createObjectStore(STORE_APP_CONFIG, { keyPath: 'chave' })
        }

        if (!db.objectStoreNames.contains(STORE_PROJETOS_CACHE)) {
          const projetos = db.createObjectStore(STORE_PROJETOS_CACHE, { keyPath: 'id' })
          projetos.createIndex('cached_em', 'cached_em', { unique: false })
        }
      }

      requisicao.onsuccess = () => resolve(requisicao.result)
      requisicao.onerror = () => reject(requisicao.error ?? new Error('Falha ao abrir IndexedDB'))
      requisicao.onblocked = () => reject(new Error('IndexedDB bloqueado por outra aba'))
    })
  }

  return _dbPromise
}

function _transacao<T>(stores: string[], mode: IDBTransactionMode, executador: (db: IDBDatabase, tx: IDBTransaction) => Promise<T>): Promise<T> {
  return _abrirBanco().then((db) => {
    const tx = db.transaction(stores, mode)
    return executador(db, tx)
  })
}

function _aguardarRequisicao<T>(requisicao: IDBRequest<T>): Promise<T> {
  return new Promise((resolve, reject) => {
    requisicao.onsuccess = () => resolve(requisicao.result)
    requisicao.onerror = () => reject(requisicao.error ?? new Error('Falha no IndexedDB'))
  })
}

function _guardar<T>(store: IDBObjectStore, valor: T): Promise<IDBValidKey> {
  return _aguardarRequisicao(store.put(valor))
}

function _buscar<T>(store: IDBObjectStore, chave: IDBValidKey): Promise<T | undefined> {
  return _aguardarRequisicao(store.get(chave))
}

function _buscarTodos<T>(store: IDBObjectStore): Promise<T[]> {
  return _aguardarRequisicao(store.getAll())
}

async function _garantirConfiguracaoLegadaMigrada(): Promise<void> {
  if (typeof localStorage === 'undefined') {
    return
  }

  try {
    const ultimoProjeto = localStorage.getItem('ultimo_projeto_mapa')
    const projetosCacheRaw = localStorage.getItem('projetos_cache')

    const db = await _abrirBanco()
    const storeConfig = db.transaction([STORE_APP_CONFIG], 'readwrite').objectStore(STORE_APP_CONFIG)
    const storeProjetos = db.transaction([STORE_PROJETOS_CACHE], 'readwrite').objectStore(STORE_PROJETOS_CACHE)

    if (ultimoProjeto) {
      await _aguardarRequisicao(storeConfig.put({
        chave: CHAVE_ULTIMO_PROJETO_MAPA,
        valor: ultimoProjeto,
        atualizado_em: _agoraIso(),
      }))
      localStorage.removeItem('ultimo_projeto_mapa')
    }

    if (projetosCacheRaw) {
      const projetos = JSON.parse(projetosCacheRaw)
      if (Array.isArray(projetos)) {
        for (const projeto of projetos) {
          if (!projeto?.id) {
            continue
          }
          await _aguardarRequisicao(storeProjetos.put({
            id: String(projeto.id),
            dados: JSON.stringify(projeto),
            cached_em: _agoraIso(),
          }))
        }
      }
      localStorage.removeItem('projetos_cache')
    }

    const chavesParaRemover: string[] = []
    for (let indice = 0; indice < localStorage.length; indice += 1) {
      const chave = localStorage.key(indice)
      if (chave && chave.startsWith('projeto_cache_')) {
        chavesParaRemover.push(chave)
      }
    }

    for (const chave of chavesParaRemover) {
      const raw = localStorage.getItem(chave)
      if (!raw) {
        continue
      }
      try {
        const projeto = JSON.parse(raw)
        const id = chave.replace('projeto_cache_', '') || projeto?.id
        if (id) {
          await _aguardarRequisicao(storeProjetos.put({
            id: String(id),
            dados: JSON.stringify(projeto),
            cached_em: _agoraIso(),
          }))
        }
      } catch {
        // Ignora legado corrompido sem travar a inicializacao.
      }
      localStorage.removeItem(chave)
    }
  } catch (erro) {
    console.warn('Falha ao migrar cache legado para IndexedDB:', erro)
  }
}

async function _lerTodosPontos(): Promise<RegistroPontoWeb[]> {
  const db = await _abrirBanco()
  const tx = db.transaction([STORE_PONTOS], 'readonly')
  const store = tx.objectStore(STORE_PONTOS)
  return await _buscarTodos<RegistroPontoWeb>(store)
}

async function _salvarPontoBruto(ponto: RegistroPontoWeb): Promise<void> {
  const db = await _abrirBanco()
  const tx = db.transaction([STORE_PONTOS], 'readwrite')
  const store = tx.objectStore(STORE_PONTOS)
  await _guardar(store, ponto)
  await new Promise<void>((resolve, reject) => {
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error ?? new Error('Falha ao persistir ponto no IndexedDB'))
    tx.onabort = () => reject(tx.error ?? new Error('Transacao abortada no IndexedDB'))
  })
}

async function _atualizarPonto(id: string, atualizador: (ponto: RegistroPontoWeb) => RegistroPontoWeb | null): Promise<void> {
  const db = await _abrirBanco()
  const tx = db.transaction([STORE_PONTOS], 'readwrite')
  const store = tx.objectStore(STORE_PONTOS)
  const atual = await _buscar<RegistroPontoWeb>(store, id)
  if (!atual) {
    return
  }
  const novo = atualizador(atual)
  if (!novo) {
    return
  }
  await _guardar(store, novo)
  await new Promise<void>((resolve, reject) => {
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error ?? new Error('Falha ao atualizar ponto no IndexedDB'))
    tx.onabort = () => reject(tx.error ?? new Error('Transacao abortada no IndexedDB'))
  })
}

export async function initDB(): Promise<void> {
  await _abrirBanco()
  await _garantirConfiguracaoLegadaMigrada()
}

export async function salvarPonto(p: Omit<PontoLocal, 'sync_status' | 'sync_tentativas'>): Promise<string> {
  const ponto = _normalizarPonto(p)
  await _salvarPontoBruto(ponto)
  return ponto.id
}

export async function listarPendentes(projeto_id?: string): Promise<PontoLocal[]> {
  const pontos = await _lerTodosPontos()
  return pontos
    .filter((ponto) => ponto.sync_status !== 'synced')
    .filter((ponto) => (projeto_id ? ponto.projeto_id === projeto_id : true))
    .sort((a, b) => a.coletado_em.localeCompare(b.coletado_em))
}

export async function listarPorProjeto(projeto_id: string): Promise<PontoLocal[]> {
  const pontos = await _lerTodosPontos()
  return pontos
    .filter((ponto) => ponto.projeto_id === projeto_id)
    .sort((a, b) => b.coletado_em.localeCompare(a.coletado_em))
}

export async function marcarSincronizado(id: string): Promise<void> {
  await _atualizarPonto(id, (ponto) => ({
    ...ponto,
    sync_status: 'synced',
    sync_em: _agoraIso(),
  }))
}

export async function marcarErro(id: string): Promise<void> {
  await _atualizarPonto(id, (ponto) => ({
    ...ponto,
    sync_status: 'error',
    sync_tentativas: (ponto.sync_tentativas ?? 0) + 1,
    sync_em: undefined,
  }))
}

export async function marcarResultadosBatch(sincronizados: string[], erros: string[]): Promise<void> {
  if (sincronizados.length === 0 && erros.length === 0) {
    return
  }

  const idsSincronizados = new Set(sincronizados)
  const idsErro = new Set(erros)
  const pontos = await _lerTodosPontos()
  const agora = _agoraIso()
  const atualizados = pontos.map((ponto) => {
    if (idsSincronizados.has(ponto.id)) {
      return {
        ...ponto,
        sync_status: 'synced' as SyncStatus,
        sync_em: agora,
      }
    }
    if (idsErro.has(ponto.id)) {
      return {
        ...ponto,
        sync_status: 'error' as SyncStatus,
        sync_tentativas: (ponto.sync_tentativas ?? 0) + 1,
        sync_em: undefined,
      }
    }
    return ponto
  })

  const db = await _abrirBanco()
  const tx = db.transaction([STORE_PONTOS], 'readwrite')
  const store = tx.objectStore(STORE_PONTOS)
  for (const ponto of atualizados) {
    await _guardar(store, ponto)
  }
  await new Promise<void>((resolve, reject) => {
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error ?? new Error('Falha ao marcar resultados em batch'))
    tx.onabort = () => reject(tx.error ?? new Error('Transacao abortada no IndexedDB'))
  })
}

export async function contarPendentes(projeto_id?: string): Promise<number> {
  const pendentes = await listarPendentes(projeto_id)
  return pendentes.length
}

export async function ultimoNomePonto(projeto_id: string): Promise<string> {
  const pontos = await listarPorProjeto(projeto_id)
  if (pontos.length === 0) {
    return 'PT0001'
  }
  const ultimo = pontos[0]
  const match = ultimo.nome.match(/(\d+)$/)
  if (!match) {
    return 'PT0001'
  }
  const proximo = parseInt(match[1], 10) + 1
  return ultimo.nome.replace(/\d+$/, String(proximo).padStart(match[1].length, '0'))
}

export async function initAppConfig(): Promise<void> {
  await _abrirBanco()
}

export async function salvarUltimoProjetoMapa(projeto_id: string): Promise<void> {
  const db = await _abrirBanco()
  const tx = db.transaction([STORE_APP_CONFIG], 'readwrite')
  const store = tx.objectStore(STORE_APP_CONFIG)
  await _guardar(store, {
    chave: CHAVE_ULTIMO_PROJETO_MAPA,
    valor: projeto_id,
    atualizado_em: _agoraIso(),
  })
  await new Promise<void>((resolve, reject) => {
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error ?? new Error('Falha ao salvar ultimo projeto do mapa'))
    tx.onabort = () => reject(tx.error ?? new Error('Transacao abortada no IndexedDB'))
  })
}

export async function obterUltimoProjetoMapa(): Promise<string | null> {
  const db = await _abrirBanco()
  const tx = db.transaction([STORE_APP_CONFIG], 'readonly')
  const store = tx.objectStore(STORE_APP_CONFIG)
  const registro = await _buscar<RegistroAppConfigWeb>(store, CHAVE_ULTIMO_PROJETO_MAPA)
  return registro?.valor ?? null
}

export async function initProjetosCache(): Promise<void> {
  await _abrirBanco()
}

export async function cacheProjetos(projetos: any[]): Promise<void> {
  const db = await _abrirBanco()
  const tx = db.transaction([STORE_PROJETOS_CACHE], 'readwrite')
  const store = tx.objectStore(STORE_PROJETOS_CACHE)
  const agora = _agoraIso()
  for (const projeto of projetos) {
    if (!projeto?.id) {
      continue
    }
    await _guardar(store, {
      id: String(projeto.id),
      dados: JSON.stringify(projeto),
      cached_em: agora,
    })
  }
  await new Promise<void>((resolve, reject) => {
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error ?? new Error('Falha ao salvar cache de projetos'))
    tx.onabort = () => reject(tx.error ?? new Error('Transacao abortada no IndexedDB'))
  })
}

export async function getCachedProjetos(): Promise<any[]> {
  const db = await _abrirBanco()
  const tx = db.transaction([STORE_PROJETOS_CACHE], 'readonly')
  const store = tx.objectStore(STORE_PROJETOS_CACHE)
  const registros = await _buscarTodos<RegistroProjetoCacheWeb>(store)
  return registros
    .sort((a, b) => b.cached_em.localeCompare(a.cached_em))
    .map((registro) => {
      try {
        return JSON.parse(registro.dados)
      } catch (erro) {
        console.warn('Erro ao parsear projeto do cache web:', erro)
        return null
      }
    })
    .filter(Boolean)
}

export async function cacheProjetoDetalhe(id: string, projeto: any): Promise<void> {
  const db = await _abrirBanco()
  const tx = db.transaction([STORE_PROJETOS_CACHE], 'readwrite')
  const store = tx.objectStore(STORE_PROJETOS_CACHE)
  await _guardar(store, {
    id,
    dados: JSON.stringify(projeto),
    cached_em: _agoraIso(),
  })
  await new Promise<void>((resolve, reject) => {
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error ?? new Error('Falha ao salvar detalhe do projeto no cache'))
    tx.onabort = () => reject(tx.error ?? new Error('Transacao abortada no IndexedDB'))
  })
}

export async function getCachedProjetoDetalhe(id: string): Promise<any | null> {
  const db = await _abrirBanco()
  const tx = db.transaction([STORE_PROJETOS_CACHE], 'readonly')
  const store = tx.objectStore(STORE_PROJETOS_CACHE)
  const registro = await _buscar<RegistroProjetoCacheWeb>(store, id)
  if (!registro) {
    return null
  }
  try {
    return JSON.parse(registro.dados)
  } catch (erro) {
    console.warn(`Erro ao parsear projeto ${id} do cache web:`, erro)
    return null
  }
}

export async function contarErros(projeto_id?: string): Promise<number> {
  const pontos = await _lerTodosPontos()
  return pontos
    .filter((ponto) => ponto.sync_status === 'error')
    .filter((ponto) => (projeto_id ? ponto.projeto_id === projeto_id : true))
    .length
}

export async function resetarErros(projeto_id?: string): Promise<void> {
  const pontos = await _lerTodosPontos()
  const filtrados = pontos.map((ponto) => {
    if (ponto.sync_status !== 'error') {
      return ponto
    }
    if (projeto_id && ponto.projeto_id !== projeto_id) {
      return ponto
    }
    return {
      ...ponto,
      sync_status: 'pending' as SyncStatus,
      sync_tentativas: 0,
      sync_em: undefined,
    }
  })

  const db = await _abrirBanco()
  const tx = db.transaction([STORE_PONTOS], 'readwrite')
  const store = tx.objectStore(STORE_PONTOS)
  for (const ponto of filtrados) {
    await _guardar(store, ponto)
  }
  await new Promise<void>((resolve, reject) => {
    tx.oncomplete = () => resolve()
    tx.onerror = () => reject(tx.error ?? new Error('Falha ao resetar erros no IndexedDB'))
    tx.onabort = () => reject(tx.error ?? new Error('Transacao abortada no IndexedDB'))
  })
}
