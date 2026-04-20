export type ArquivoSelecionado = {
  uri: string
  name: string
  mimeType?: string | null
  file?: File
}

export type ResultadoSelecaoArquivo = {
  canceled: boolean
  assets?: ArquivoSelecionado[]
}

type OpcoesSelecaoArquivo = {
  type?: string | string[]
  copyToCacheDirectory?: boolean
  base64?: boolean
}

export async function selecionarDocumento(
  opcoes: OpcoesSelecaoArquivo = {},
): Promise<ResultadoSelecaoArquivo> {
  try {
    const modulo = require('expo-document-picker')
    return await modulo.getDocumentAsync(opcoes)
  } catch {
    throw new Error('Seletor de arquivos indisponivel neste ambiente.')
  }
}