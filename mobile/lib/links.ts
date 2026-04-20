import { Linking } from 'react-native'

export async function podeAbrirUrl(url: string): Promise<boolean> {
  return Linking.canOpenURL(url)
}

export async function abrirUrl(url: string): Promise<void> {
  await Linking.openURL(url)
}