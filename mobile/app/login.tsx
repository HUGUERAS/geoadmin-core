import { useState } from 'react'
import {
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native'
import { Redirect } from 'expo-router'
import { Feather } from '@expo/vector-icons'

import { Colors } from '../constants/Colors'
import { useAuth } from '../lib/auth'


export default function LoginScreen() {
  const C = Colors.dark
  const { autenticado, carregando, entrar } = useAuth()
  const [email, setEmail] = useState('')
  const [senha, setSenha] = useState('')
  const [enviando, setEnviando] = useState(false)
  const [erro, setErro] = useState('')
  const [mostrarSenha, setMostrarSenha] = useState(false)

  if (carregando) {
    return (
      <View style={[s.container, { backgroundColor: C.background }]}>
        <ActivityIndicator size="large" color={C.primary} />
        <Text style={[s.loadingText, { color: C.muted }]}>Restaurando sessão...</Text>
      </View>
    )
  }

  if (autenticado) {
    return <Redirect href="/(tabs)/projeto" />
  }

  const submit = async () => {
    if (!email.trim() || !senha.trim()) {
      setErro('Informe e-mail e senha para entrar.')
      return
    }

    try {
      setErro('')
      setEnviando(true)
      await entrar(email.trim(), senha)
    } catch (e: any) {
      setErro(e?.message ?? 'Não foi possível autenticar. Confira as credenciais.')
    } finally {
      setEnviando(false)
    }
  }

  return (
    <KeyboardAvoidingView
      style={[s.container, { backgroundColor: C.background }]}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <View style={[s.card, { backgroundColor: C.card, borderColor: C.cardBorder }]}>
        <View style={s.logoRow}>
          <View style={[s.logoBadge, { backgroundColor: `${C.primary}18` }]}>
            <Feather name="map-pin" size={20} color={C.primary} />
          </View>
          <Text style={[s.eyebrow, { color: C.primary }]}>GeoAdmin Core</Text>
        </View>

        <Text style={[s.title, { color: C.text }]}>Entrada do topógrafo</Text>
        <Text style={[s.subtitle, { color: C.muted }]}>
          Faça login uma vez e o app restaura sua sessão automaticamente nas próximas aberturas.
        </Text>

        <View style={s.form}>
          <View style={s.fieldGap}>
            <Text style={[s.label, { color: C.text }]}>E-mail</Text>
            <TextInput
              value={email}
              onChangeText={setEmail}
              placeholder="voce@empresa.com"
              placeholderTextColor={C.muted}
              autoCapitalize="none"
              autoCorrect={false}
              keyboardType="email-address"
              style={[s.input, { backgroundColor: C.background, borderColor: C.cardBorder, color: C.text }]}
            />
          </View>

          <View style={s.fieldGap}>
            <Text style={[s.label, { color: C.text }]}>Senha</Text>
            <View style={[s.passwordBox, { backgroundColor: C.background, borderColor: C.cardBorder }]}>
              <TextInput
                value={senha}
                onChangeText={setSenha}
                placeholder="Sua senha de acesso"
                placeholderTextColor={C.muted}
                secureTextEntry={!mostrarSenha}
                autoCapitalize="none"
                style={[s.passwordInput, { color: C.text }]}
              />
              <TouchableOpacity onPress={() => setMostrarSenha((state) => !state)} accessibilityRole="button">
                <Feather name={mostrarSenha ? 'eye-off' : 'eye'} size={18} color={C.muted} />
              </TouchableOpacity>
            </View>
          </View>

          {erro ? <Text style={[s.error, { color: C.danger }]}>{erro}</Text> : null}

          <TouchableOpacity
            onPress={submit}
            disabled={enviando}
            style={[s.submit, { backgroundColor: C.primary, opacity: enviando ? 0.7 : 1 }]}
            accessibilityRole="button"
            accessibilityLabel="Entrar no GeoAdmin"
          >
            {enviando ? (
              <ActivityIndicator color={C.primaryText} />
            ) : (
              <>
                <Feather name="log-in" size={16} color={C.primaryText} />
                <Text style={[s.submitText, { color: C.primaryText }]}>Entrar</Text>
              </>
            )}
          </TouchableOpacity>
        </View>
      </View>
    </KeyboardAvoidingView>
  )
}

const s = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    gap: 12,
  },
  card: {
    width: '100%',
    maxWidth: 420,
    borderRadius: 24,
    borderWidth: 1,
    padding: 24,
    gap: 16,
  },
  logoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  logoBadge: {
    width: 42,
    height: 42,
    borderRadius: 999,
    alignItems: 'center',
    justifyContent: 'center',
  },
  eyebrow: {
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1,
    textTransform: 'uppercase',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
  },
  subtitle: {
    fontSize: 14,
    lineHeight: 22,
  },
  form: {
    gap: 16,
  },
  fieldGap: {
    gap: 8,
  },
  label: {
    fontSize: 13,
    fontWeight: '700',
  },
  input: {
    borderWidth: 1,
    borderRadius: 14,
    paddingHorizontal: 14,
    paddingVertical: 13,
    fontSize: 15,
  },
  passwordBox: {
    borderWidth: 1,
    borderRadius: 14,
    paddingHorizontal: 14,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  passwordInput: {
    flex: 1,
    paddingVertical: 13,
    fontSize: 15,
  },
  error: {
    fontSize: 13,
    lineHeight: 19,
    fontWeight: '600',
  },
  submit: {
    borderRadius: 14,
    paddingHorizontal: 16,
    paddingVertical: 14,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 8,
  },
  submitText: {
    fontSize: 15,
    fontWeight: '800',
  },
  loadingText: {
    fontSize: 14,
    fontWeight: '600',
  },
})
