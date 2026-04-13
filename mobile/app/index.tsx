import { ActivityIndicator, Text, View } from 'react-native'
import { Redirect } from 'expo-router'

import { Colors } from '../constants/Colors'
import { useAuth } from '../lib/auth'

export default function Index() {
  const { autenticado, carregando } = useAuth()
  const C = Colors.dark

  if (carregando) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', gap: 12, backgroundColor: C.background }}>
        <ActivityIndicator size="large" color={C.primary} />
        <Text style={{ color: C.muted, fontWeight: '600' }}>Restaurando sessão...</Text>
      </View>
    )
  }

  return <Redirect href={autenticado ? '/(tabs)/projeto' : '/login'} />
}
