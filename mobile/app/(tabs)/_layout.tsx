import { Tabs } from 'expo-router'
import { ActivityIndicator, Text, View } from 'react-native'
import { Redirect } from 'expo-router'
import { Feather } from '@expo/vector-icons'
import { Colors } from '../../constants/Colors'
import { useAuth } from '../../lib/auth'

export default function TabLayout() {
  const C = Colors.dark
  const { autenticado, carregando } = useAuth()

  if (carregando) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', gap: 12, backgroundColor: C.background }}>
        <ActivityIndicator size="large" color={C.primary} />
        <Text style={{ color: C.muted, fontWeight: '600' }}>Carregando sessão...</Text>
      </View>
    )
  }

  if (!autenticado) {
    return <Redirect href="/login" />
  }

  return (
    <Tabs screenOptions={{
      tabBarStyle: {
        backgroundColor: C.card,
        borderTopColor: C.cardBorder,
        borderTopWidth: 0.5,
        paddingBottom: 8,
        paddingTop: 8,
      },
      tabBarActiveTintColor: C.primary,
      tabBarInactiveTintColor: C.muted,
      tabBarLabelStyle: { fontSize: 11, fontWeight: '500' },
      headerStyle: { backgroundColor: C.card },
      headerTintColor: C.text,
      headerTitleStyle: { fontWeight: '700', fontSize: 18 },
    }}>
      <Tabs.Screen name="projeto/index" options={{
        title: 'Projetos',
        tabBarIcon: ({ color }) => <Feather name="folder" size={22} color={color} />,
        headerShown: false,
      }} />
      <Tabs.Screen name="projeto/novo" options={{ href: null, headerShown: false }} />
      <Tabs.Screen name="projeto/[id]" options={{ href: null, headerShown: false }} />
      <Tabs.Screen name="mapa/index" options={{
        title: 'Mapa',
        tabBarIcon: ({ color }) => <Feather name="map" size={22} color={color} />,
        headerShown: false,
      }} />
      <Tabs.Screen name="mapa/[id]" options={{ href: null, headerShown: false }} />
      <Tabs.Screen name="calculos/index" options={{
        title: 'Cálculos',
        tabBarIcon: ({ color }) => <Feather name="cpu" size={22} color={color} />,
        headerShown: false,
      }} />
      <Tabs.Screen name="calculos/inverso" options={{ href: null }} />
      <Tabs.Screen name="calculos/area" options={{ href: null }} />
      <Tabs.Screen name="calculos/conversao" options={{ href: null }} />
      <Tabs.Screen name="calculos/deflexao" options={{ href: null }} />
      <Tabs.Screen name="calculos/intersecao" options={{ href: null }} />
      <Tabs.Screen name="calculos/distancia" options={{ href: null }} />
      <Tabs.Screen name="calculos/rotacao" options={{ href: null }} />
      <Tabs.Screen name="calculos/media" options={{ href: null }} />
      <Tabs.Screen name="calculos/irradiacao" options={{ href: null }} />
      <Tabs.Screen name="calculos/subdivisao" options={{ href: null }} />
      <Tabs.Screen name="calculos/pontos" options={{ href: null }} />
      <Tabs.Screen name="calculos/linha" options={{ href: null }} />
      <Tabs.Screen name="calculos/polilinha" options={{ href: null }} />
      <Tabs.Screen name="calculos/nomenclatura" options={{ href: null }} />
      <Tabs.Screen name="clientes/index" options={{
        title: 'Clientes',
        tabBarIcon: ({ color }) => <Feather name="users" size={22} color={color} />,
        headerShown: false,
      }} />
      <Tabs.Screen name="clientes/[id]" options={{ href: null, headerShown: false }} />
    </Tabs>
  )
}
