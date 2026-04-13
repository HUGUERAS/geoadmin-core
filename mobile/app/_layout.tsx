import { useEffect, useState } from 'react'
import { Stack } from 'expo-router'
import { StatusBar } from 'expo-status-bar'
import { ActivityIndicator, StyleSheet, Text, View } from 'react-native'
import { Colors } from '../constants/Colors'
import { initDB } from '../lib/db'
import { AuthProvider } from '../lib/auth'
import * as Font from 'expo-font'
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
    Font.loadAsync({
      ...Feather.font,
      ...MaterialIcons.font,
      ...MaterialCommunityIcons.font,
      ...Ionicons.font,
      ...FontAwesome.font,
      ...FontAwesome5.font,
    })
      .catch(() => {})
      .finally(() => setFontsLoaded(true))
  }, [])

  if (!fontsLoaded) {
    return (
      <View style={[s.loading, { backgroundColor: C.background }]}>
        <ActivityIndicator size="large" color={C.primary} />
        <Text style={[s.loadingText, { color: C.muted }]}>Preparando GeoAdmin Core...</Text>
      </View>
    )
  }

  return (
    <AuthProvider>
      <StatusBar style="light" backgroundColor={C.background} />
      <Stack
        screenOptions={{
          headerStyle:      { backgroundColor: C.card },
          headerTintColor:  C.text,
          headerTitleStyle: { fontWeight: '600' },
          contentStyle:     { backgroundColor: C.background },
        }}
      >
        <Stack.Screen name="login" options={{ headerShown: false }} />
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      </Stack>
    </AuthProvider>
  )
}

const s = StyleSheet.create({
  loading: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
    padding: 24,
  },
  loadingText: {
    fontSize: 14,
    fontWeight: '600',
  },
})
