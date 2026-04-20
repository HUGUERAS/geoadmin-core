import { useEffect, useState } from 'react'
import { Stack } from 'expo-router'
import { StatusBar } from 'react-native'
import { Colors } from '../constants/Colors'
import { initDB } from '../lib/db'
import {
  Feather,
  MaterialIcons,
  MaterialCommunityIcons,
  Ionicons,
  FontAwesome,
  FontAwesome5,
} from '@expo/vector-icons'

export default function RootLayout() {
  const C = Colors.dark
  const [fontsLoaded, setFontsLoaded] = useState(false)

  useEffect(() => {
    initDB().catch(console.error)

    async function carregarFontes() {
      try {
        const modulo = require('expo-font')
        const font = modulo.default ?? modulo
        await font.loadAsync({
          ...Feather.font,
          ...MaterialIcons.font,
          ...MaterialCommunityIcons.font,
          ...Ionicons.font,
          ...FontAwesome.font,
          ...FontAwesome5.font,
        })
      } catch {
      } finally {
        setFontsLoaded(true)
      }
    }

    carregarFontes().catch(() => setFontsLoaded(true))
  }, [])

  return (
    <>
      <StatusBar barStyle="light-content" backgroundColor={C.background} />
      <Stack
        screenOptions={{
          headerStyle:      { backgroundColor: C.card },
          headerTintColor:  C.text,
          headerTitleStyle: { fontWeight: '600' },
          contentStyle:     { backgroundColor: C.background },
        }}
      >
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      </Stack>
    </>
  )
}
