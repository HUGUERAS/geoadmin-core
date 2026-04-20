import { useEffect, useState } from 'react'
import { View, Text, StyleSheet, ActivityIndicator, TouchableOpacity } from 'react-native'
import { useRouter } from 'expo-router'
import { Feather } from '@expo/vector-icons'
import { Colors } from '../../../constants/Colors'
import { initDB, obterUltimoProjetoMapa } from '../../../lib/db'
import { apiGet } from '../../../lib/api'
import { ScreenHeader } from '../../../components/ScreenHeader'

export default function MapaScreen() {
  const C = Colors.dark
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [erro, setErro] = useState('')

  useEffect(() => {
    let ativo = true
      ; (async () => {
        try {
          await initDB()
          const ultimoProjetoId = await obterUltimoProjetoMapa()
          if (!ativo) return
          if (ultimoProjetoId) {
            router.replace(`/(tabs)/mapa/${ultimoProjetoId}` as any)
            return
          }

          const resposta = await apiGet<{ projetos?: Array<{ id?: string | null }> }>('/projetos?limite=1')
          const projetoRecenteId = resposta?.projetos?.[0]?.id
          if (!ativo) return
          if (projetoRecenteId) {
            router.replace(`/(tabs)/mapa/${projetoRecenteId}` as any)
            return
          }
        } catch (error: any) {
          if (ativo) {
            setErro(error?.message || 'Não foi possível carregar um projeto para iniciar o mapa.')
          }
        } finally {
          if (ativo) {
            setLoading(false)
          }
        }
      })()
    return () => { ativo = false }
  }, [router])

  if (loading) {
    return (
      <View style={[s.container, s.centro, { backgroundColor: C.background }]}>
        <ActivityIndicator color={C.primary} size="large" />
        <Text style={[s.sub, { color: C.muted }]}>Recuperando último projeto do mapa...</Text>
      </View>
    )
  }

  return (
    <View style={[s.container, { backgroundColor: C.background }]}>
      <ScreenHeader titulo="Mapa / CAD" />
      <View style={s.centro}>
        <Feather name="map" size={48} color={C.muted} />
        <Text style={[s.msg, { color: C.muted }]}>Nenhum projeto recente no mapa</Text>
        <Text style={[s.sub, { color: C.muted }]}>
          {erro || `Abra um projeto ou cliente e toque em\n"Ver no mapa"`}
        </Text>
        <TouchableOpacity style={[s.acao, { borderColor: C.primary }]} onPress={() => router.replace('/(tabs)/projeto' as any)}>
          <Text style={[s.acaoTxt, { color: C.primary }]}>Abrir projetos</Text>
        </TouchableOpacity>
      </View>
    </View>
  )
}

const s = StyleSheet.create({
  container: { flex: 1 },
  header: { padding: 20, borderBottomWidth: 0.5 },
  titulo: { fontSize: 24, fontWeight: '700' },
  centro: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 12, paddingHorizontal: 24 },
  msg: { fontSize: 16, fontWeight: '600', textAlign: 'center' },
  sub: { fontSize: 13, textAlign: 'center', lineHeight: 20 },
  acao: { marginTop: 8, paddingHorizontal: 16, paddingVertical: 10, borderWidth: 1, borderRadius: 10 },
  acaoTxt: { fontSize: 13, fontWeight: '700' },
})
