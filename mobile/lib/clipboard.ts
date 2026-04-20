export async function copiarTexto(texto: string): Promise<void> {
  const clipboardWeb = typeof navigator !== 'undefined' ? navigator.clipboard : undefined
  if (clipboardWeb?.writeText) {
    await clipboardWeb.writeText(texto)
    return
  }

  try {
    const modulo = require('expo-clipboard')
    if (typeof modulo.setStringAsync === 'function') {
      await modulo.setStringAsync(texto)
      return
    }
    if (typeof modulo.setString === 'function') {
      modulo.setString(texto)
      return
    }
  } catch {
  }

  throw new Error('Clipboard indisponivel neste ambiente.')
}