export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.4"
  }
  public: {
    Tables: {
      area_clientes: {
        Row: {
          area_id: string
          atualizado_em: string
          cliente_id: string
          criado_em: string
          deleted_at: string | null
          id: string
          ordem: number
          papel: string
          principal: boolean
          recebe_magic_link: boolean
        }
        Insert: {
          area_id: string
          atualizado_em?: string
          cliente_id: string
          criado_em?: string
          deleted_at?: string | null
          id?: string
          ordem?: number
          papel?: string
          principal?: boolean
          recebe_magic_link?: boolean
        }
        Update: {
          area_id?: string
          atualizado_em?: string
          cliente_id?: string
          criado_em?: string
          deleted_at?: string | null
          id?: string
          ordem?: number
          papel?: string
          principal?: boolean
          recebe_magic_link?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "area_clientes_area_id_fkey"
            columns: ["area_id"]
            isOneToOne: false
            referencedRelation: "areas_projeto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "area_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "area_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
        ]
      }
      areas_projeto: {
        Row: {
          anexos: Json | null
          atualizado_em: string | null
          car: string | null
          ccir: string | null
          cliente_id: string | null
          codigo_lote: string | null
          comarca: string | null
          criado_em: string | null
          deleted_at: string | null
          estado: string | null
          geometria_esboco: Json | null
          geometria_final: Json | null
          id: string
          matricula: string | null
          municipio: string | null
          nome: string
          observacoes: string | null
          origem_tipo: string
          projeto_id: string
          proprietario_nome: string | null
          quadra: string | null
          resumo_esboco: Json | null
          resumo_final: Json | null
          setor: string | null
          status_documental: string | null
          status_operacional: string | null
        }
        Insert: {
          anexos?: Json | null
          atualizado_em?: string | null
          car?: string | null
          ccir?: string | null
          cliente_id?: string | null
          codigo_lote?: string | null
          comarca?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          estado?: string | null
          geometria_esboco?: Json | null
          geometria_final?: Json | null
          id?: string
          matricula?: string | null
          municipio?: string | null
          nome?: string
          observacoes?: string | null
          origem_tipo?: string
          projeto_id: string
          proprietario_nome?: string | null
          quadra?: string | null
          resumo_esboco?: Json | null
          resumo_final?: Json | null
          setor?: string | null
          status_documental?: string | null
          status_operacional?: string | null
        }
        Update: {
          anexos?: Json | null
          atualizado_em?: string | null
          car?: string | null
          ccir?: string | null
          cliente_id?: string | null
          codigo_lote?: string | null
          comarca?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          estado?: string | null
          geometria_esboco?: Json | null
          geometria_final?: Json | null
          id?: string
          matricula?: string | null
          municipio?: string | null
          nome?: string
          observacoes?: string | null
          origem_tipo?: string
          projeto_id?: string
          proprietario_nome?: string | null
          quadra?: string | null
          resumo_esboco?: Json | null
          resumo_final?: Json | null
          setor?: string | null
          status_documental?: string | null
          status_operacional?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "areas_projeto_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "areas_projeto_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "areas_projeto_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "areas_projeto_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "areas_projeto_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "areas_projeto_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      arquivos_projeto: {
        Row: {
          area_id: string | null
          atualizado_em: string
          base_oficial: boolean
          classificacao: string
          cliente_id: string | null
          criado_em: string
          deleted_at: string | null
          formato: string
          hash_arquivo: string | null
          id: string
          metadados_json: Json
          mime_type: string | null
          nome_arquivo: string
          nome_original: string | null
          origem: string
          projeto_id: string
          promocao_observacao: string | null
          promovido_em: string | null
          promovido_por: string | null
          storage_path: string
          tamanho_bytes: number | null
        }
        Insert: {
          area_id?: string | null
          atualizado_em?: string
          base_oficial?: boolean
          classificacao?: string
          cliente_id?: string | null
          criado_em?: string
          deleted_at?: string | null
          formato: string
          hash_arquivo?: string | null
          id?: string
          metadados_json?: Json
          mime_type?: string | null
          nome_arquivo: string
          nome_original?: string | null
          origem?: string
          projeto_id: string
          promocao_observacao?: string | null
          promovido_em?: string | null
          promovido_por?: string | null
          storage_path: string
          tamanho_bytes?: number | null
        }
        Update: {
          area_id?: string | null
          atualizado_em?: string
          base_oficial?: boolean
          classificacao?: string
          cliente_id?: string | null
          criado_em?: string
          deleted_at?: string | null
          formato?: string
          hash_arquivo?: string | null
          id?: string
          metadados_json?: Json
          mime_type?: string | null
          nome_arquivo?: string
          nome_original?: string | null
          origem?: string
          projeto_id?: string
          promocao_observacao?: string | null
          promovido_em?: string | null
          promovido_por?: string | null
          storage_path?: string
          tamanho_bytes?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "arquivos_projeto_area_id_fkey"
            columns: ["area_id"]
            isOneToOne: false
            referencedRelation: "areas_projeto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "arquivos_projeto_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "arquivos_projeto_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "arquivos_projeto_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "arquivos_projeto_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "arquivos_projeto_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "arquivos_projeto_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      camadas: {
        Row: {
          bloqueada: boolean | null
          cor_hex: string | null
          criado_em: string | null
          id: string
          nome: string
          projeto_id: string
          visivel: boolean | null
        }
        Insert: {
          bloqueada?: boolean | null
          cor_hex?: string | null
          criado_em?: string | null
          id?: string
          nome: string
          projeto_id: string
          visivel?: boolean | null
        }
        Update: {
          bloqueada?: boolean | null
          cor_hex?: string | null
          criado_em?: string | null
          id?: string
          nome?: string
          projeto_id?: string
          visivel?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "camadas_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "camadas_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "camadas_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "camadas_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      clientes: {
        Row: {
          atualizado_em: string | null
          cep: string | null
          conjuge_cpf: string | null
          conjuge_nome: string | null
          cpf: string | null
          cpf_cnpj: string | null
          criado_em: string | null
          deleted_at: string | null
          email: string | null
          endereco: string | null
          endereco_numero: string | null
          estado: string | null
          estado_civil: string | null
          formulario_em: string | null
          formulario_ok: boolean | null
          id: string
          magic_link_expira: string | null
          magic_link_token: string | null
          municipio: string | null
          nome: string
          profissao: string | null
          rg: string | null
          setor: string | null
          telefone: string | null
        }
        Insert: {
          atualizado_em?: string | null
          cep?: string | null
          conjuge_cpf?: string | null
          conjuge_nome?: string | null
          cpf?: string | null
          cpf_cnpj?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          email?: string | null
          endereco?: string | null
          endereco_numero?: string | null
          estado?: string | null
          estado_civil?: string | null
          formulario_em?: string | null
          formulario_ok?: boolean | null
          id?: string
          magic_link_expira?: string | null
          magic_link_token?: string | null
          municipio?: string | null
          nome: string
          profissao?: string | null
          rg?: string | null
          setor?: string | null
          telefone?: string | null
        }
        Update: {
          atualizado_em?: string | null
          cep?: string | null
          conjuge_cpf?: string | null
          conjuge_nome?: string | null
          cpf?: string | null
          cpf_cnpj?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          email?: string | null
          endereco?: string | null
          endereco_numero?: string | null
          estado?: string | null
          estado_civil?: string | null
          formulario_em?: string | null
          formulario_ok?: boolean | null
          id?: string
          magic_link_expira?: string | null
          magic_link_token?: string | null
          municipio?: string | null
          nome?: string
          profissao?: string | null
          rg?: string | null
          setor?: string | null
          telefone?: string | null
        }
        Relationships: []
      }
      confrontacoes_revisadas: {
        Row: {
          atualizado_em: string
          autor: string | null
          confronto_id: string
          criado_em: string
          deleted_at: string | null
          id: string
          observacao: string | null
          projeto_id: string
          status_revisao: string
          tipo_relacao: string
        }
        Insert: {
          atualizado_em?: string
          autor?: string | null
          confronto_id: string
          criado_em?: string
          deleted_at?: string | null
          id?: string
          observacao?: string | null
          projeto_id: string
          status_revisao?: string
          tipo_relacao?: string
        }
        Update: {
          atualizado_em?: string
          autor?: string | null
          confronto_id?: string
          criado_em?: string
          deleted_at?: string | null
          id?: string
          observacao?: string | null
          projeto_id?: string
          status_revisao?: string
          tipo_relacao?: string
        }
        Relationships: [
          {
            foreignKeyName: "confrontacoes_revisadas_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "confrontacoes_revisadas_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "confrontacoes_revisadas_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "confrontacoes_revisadas_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      confrontantes: {
        Row: {
          cpf: string | null
          criado_em: string | null
          deleted_at: string | null
          id: string
          lado: string
          matricula: string | null
          nome: string
          nome_imovel: string | null
          origem: string | null
          projeto_id: string
          tipo: string | null
          vertices_json: Json | null
        }
        Insert: {
          cpf?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          id?: string
          lado: string
          matricula?: string | null
          nome: string
          nome_imovel?: string | null
          origem?: string | null
          projeto_id: string
          tipo?: string | null
          vertices_json?: Json | null
        }
        Update: {
          cpf?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          id?: string
          lado?: string
          matricula?: string | null
          nome?: string
          nome_imovel?: string | null
          origem?: string | null
          projeto_id?: string
          tipo?: string | null
          vertices_json?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "confrontantes_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "confrontantes_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "confrontantes_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "confrontantes_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      documentos: {
        Row: {
          cliente_id: string | null
          criado_em: string | null
          deleted_at: string | null
          enviado_por: string | null
          id: string
          mime_type: string | null
          nome_arquivo: string
          projeto_id: string | null
          storage_path: string
          tamanho_bytes: number | null
          tipo: string
          visivel_cliente: boolean | null
        }
        Insert: {
          cliente_id?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          enviado_por?: string | null
          id?: string
          mime_type?: string | null
          nome_arquivo: string
          projeto_id?: string | null
          storage_path: string
          tamanho_bytes?: number | null
          tipo: string
          visivel_cliente?: boolean | null
        }
        Update: {
          cliente_id?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          enviado_por?: string | null
          id?: string
          mime_type?: string | null
          nome_arquivo?: string
          projeto_id?: string | null
          storage_path?: string
          tamanho_bytes?: number | null
          tipo?: string
          visivel_cliente?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "documentos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documentos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "documentos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documentos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documentos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "documentos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      documentos_gerados: {
        Row: {
          deleted_at: string | null
          gerado_em: string | null
          id: string
          projeto_id: string
          storage_path: string | null
          tipo: string
          versao: number | null
        }
        Insert: {
          deleted_at?: string | null
          gerado_em?: string | null
          id?: string
          projeto_id: string
          storage_path?: string | null
          tipo: string
          versao?: number | null
        }
        Update: {
          deleted_at?: string | null
          gerado_em?: string | null
          id?: string
          projeto_id?: string
          storage_path?: string | null
          tipo?: string
          versao?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "documentos_gerados_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documentos_gerados_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "documentos_gerados_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "documentos_gerados_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      eventos_cartograficos: {
        Row: {
          area_id: string | null
          arquivo_id: string | null
          autor: string | null
          classificacao_anterior: string | null
          classificacao_nova: string | null
          cliente_id: string | null
          criado_em: string
          deleted_at: string | null
          id: string
          observacao: string | null
          origem: string | null
          payload_json: Json
          projeto_id: string
          storage_path_anterior: string | null
          storage_path_novo: string | null
          tipo_evento: string
        }
        Insert: {
          area_id?: string | null
          arquivo_id?: string | null
          autor?: string | null
          classificacao_anterior?: string | null
          classificacao_nova?: string | null
          cliente_id?: string | null
          criado_em?: string
          deleted_at?: string | null
          id?: string
          observacao?: string | null
          origem?: string | null
          payload_json?: Json
          projeto_id: string
          storage_path_anterior?: string | null
          storage_path_novo?: string | null
          tipo_evento: string
        }
        Update: {
          area_id?: string | null
          arquivo_id?: string | null
          autor?: string | null
          classificacao_anterior?: string | null
          classificacao_nova?: string | null
          cliente_id?: string | null
          criado_em?: string
          deleted_at?: string | null
          id?: string
          observacao?: string | null
          origem?: string | null
          payload_json?: Json
          projeto_id?: string
          storage_path_anterior?: string | null
          storage_path_novo?: string | null
          tipo_evento?: string
        }
        Relationships: [
          {
            foreignKeyName: "eventos_cartograficos_area_id_fkey"
            columns: ["area_id"]
            isOneToOne: false
            referencedRelation: "areas_projeto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_cartograficos_arquivo_id_fkey"
            columns: ["arquivo_id"]
            isOneToOne: false
            referencedRelation: "arquivos_projeto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_cartograficos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_cartograficos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "eventos_cartograficos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_cartograficos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_cartograficos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "eventos_cartograficos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      eventos_magic_link: {
        Row: {
          area_id: string | null
          autor: string | null
          canal: string
          cliente_id: string | null
          criado_em: string
          deleted_at: string | null
          expira_em: string | null
          id: string
          payload_json: Json
          projeto_cliente_id: string | null
          projeto_id: string
          tipo_evento: string
          token: string | null
        }
        Insert: {
          area_id?: string | null
          autor?: string | null
          canal?: string
          cliente_id?: string | null
          criado_em?: string
          deleted_at?: string | null
          expira_em?: string | null
          id?: string
          payload_json?: Json
          projeto_cliente_id?: string | null
          projeto_id: string
          tipo_evento?: string
          token?: string | null
        }
        Update: {
          area_id?: string | null
          autor?: string | null
          canal?: string
          cliente_id?: string | null
          criado_em?: string
          deleted_at?: string | null
          expira_em?: string | null
          id?: string
          payload_json?: Json
          projeto_cliente_id?: string | null
          projeto_id?: string
          tipo_evento?: string
          token?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "eventos_magic_link_area_id_fkey"
            columns: ["area_id"]
            isOneToOne: false
            referencedRelation: "areas_projeto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_magic_link_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_magic_link_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "eventos_magic_link_projeto_cliente_id_fkey"
            columns: ["projeto_cliente_id"]
            isOneToOne: false
            referencedRelation: "projeto_clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_magic_link_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_magic_link_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "eventos_magic_link_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "eventos_magic_link_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      geometrias: {
        Row: {
          area_m2: number | null
          atualizado_em: string | null
          camada: string | null
          confrontacao_leste: string | null
          confrontacao_norte: string | null
          confrontacao_oeste: string | null
          confrontacao_sul: string | null
          criado_em: string | null
          deleted_at: string | null
          geometria: unknown
          id: string
          matricula_origem: string | null
          nome: string | null
          perimetro_m: number | null
          projeto_id: string
          tipo: string
        }
        Insert: {
          area_m2?: number | null
          atualizado_em?: string | null
          camada?: string | null
          confrontacao_leste?: string | null
          confrontacao_norte?: string | null
          confrontacao_oeste?: string | null
          confrontacao_sul?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          geometria: unknown
          id?: string
          matricula_origem?: string | null
          nome?: string | null
          perimetro_m?: number | null
          projeto_id: string
          tipo: string
        }
        Update: {
          area_m2?: number | null
          atualizado_em?: string | null
          camada?: string | null
          confrontacao_leste?: string | null
          confrontacao_norte?: string | null
          confrontacao_oeste?: string | null
          confrontacao_sul?: string | null
          criado_em?: string | null
          deleted_at?: string | null
          geometria?: unknown
          id?: string
          matricula_origem?: string | null
          nome?: string | null
          perimetro_m?: number | null
          projeto_id?: string
          tipo?: string
        }
        Relationships: [
          {
            foreignKeyName: "geometrias_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "geometrias_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "geometrias_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "geometrias_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      geometrias_referencia_cliente: {
        Row: {
          arquivo_nome: string | null
          atualizado_em: string | null
          cliente_id: string
          comparativo_json: Json | null
          deleted_at: string | null
          formato: string
          id: string
          nome: string
          origem_tipo: string
          projeto_id: string | null
          resumo_json: Json
          vertices_json: Json
        }
        Insert: {
          arquivo_nome?: string | null
          atualizado_em?: string | null
          cliente_id: string
          comparativo_json?: Json | null
          deleted_at?: string | null
          formato: string
          id?: string
          nome?: string
          origem_tipo: string
          projeto_id?: string | null
          resumo_json?: Json
          vertices_json?: Json
        }
        Update: {
          arquivo_nome?: string | null
          atualizado_em?: string | null
          cliente_id?: string
          comparativo_json?: Json | null
          deleted_at?: string | null
          formato?: string
          id?: string
          nome?: string
          origem_tipo?: string
          projeto_id?: string | null
          resumo_json?: Json
          vertices_json?: Json
        }
        Relationships: [
          {
            foreignKeyName: "geometrias_referencia_cliente_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "geometrias_referencia_cliente_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "geometrias_referencia_cliente_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "geometrias_referencia_cliente_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "geometrias_referencia_cliente_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "geometrias_referencia_cliente_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      normas_chunks: {
        Row: {
          criado_em: string | null
          documento: string
          embedding: string | null
          fonte: string
          id: string
          pagina: number | null
          texto: string
        }
        Insert: {
          criado_em?: string | null
          documento: string
          embedding?: string | null
          fonte: string
          id?: string
          pagina?: number | null
          texto: string
        }
        Update: {
          criado_em?: string | null
          documento?: string
          embedding?: string | null
          fonte?: string
          id?: string
          pagina?: number | null
          texto?: string
        }
        Relationships: []
      }
      perimetros: {
        Row: {
          criado_em: string | null
          deleted_at: string | null
          id: string
          nome: string
          projeto_id: string
          tipo: string
          vertices_json: Json
        }
        Insert: {
          criado_em?: string | null
          deleted_at?: string | null
          id?: string
          nome: string
          projeto_id: string
          tipo: string
          vertices_json: Json
        }
        Update: {
          criado_em?: string | null
          deleted_at?: string | null
          id?: string
          nome?: string
          projeto_id?: string
          tipo?: string
          vertices_json?: Json
        }
        Relationships: [
          {
            foreignKeyName: "perimetros_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "perimetros_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "perimetros_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "perimetros_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      pontos: {
        Row: {
          altitude_m: number | null
          camada: string | null
          codigo: string | null
          coletado_em: string | null
          coordenada: unknown
          cota: number | null
          criado_em: string | null
          deleted_at: string | null
          descricao: string | null
          este: number | null
          hdop: number | null
          id: string
          lat: number | null
          local_id: string | null
          lon: number | null
          nome: string
          norte: number | null
          num_amostras: number | null
          num_satelites: number | null
          operador: string | null
          origem: string | null
          pdop: number | null
          projeto_id: string
          qualidade_fix: number | null
          receptor_gnss: string | null
          satelites: number | null
          separacao_geoidal_m: number | null
          sigma_e: number | null
          sigma_n: number | null
          sigma_u: number | null
          sincronizado: boolean | null
          status_gnss: string | null
        }
        Insert: {
          altitude_m?: number | null
          camada?: string | null
          codigo?: string | null
          coletado_em?: string | null
          coordenada: unknown
          cota?: number | null
          criado_em?: string | null
          deleted_at?: string | null
          descricao?: string | null
          este?: number | null
          hdop?: number | null
          id?: string
          lat?: number | null
          local_id?: string | null
          lon?: number | null
          nome: string
          norte?: number | null
          num_amostras?: number | null
          num_satelites?: number | null
          operador?: string | null
          origem?: string | null
          pdop?: number | null
          projeto_id: string
          qualidade_fix?: number | null
          receptor_gnss?: string | null
          satelites?: number | null
          separacao_geoidal_m?: number | null
          sigma_e?: number | null
          sigma_n?: number | null
          sigma_u?: number | null
          sincronizado?: boolean | null
          status_gnss?: string | null
        }
        Update: {
          altitude_m?: number | null
          camada?: string | null
          codigo?: string | null
          coletado_em?: string | null
          coordenada?: unknown
          cota?: number | null
          criado_em?: string | null
          deleted_at?: string | null
          descricao?: string | null
          este?: number | null
          hdop?: number | null
          id?: string
          lat?: number | null
          local_id?: string | null
          lon?: number | null
          nome?: string
          norte?: number | null
          num_amostras?: number | null
          num_satelites?: number | null
          operador?: string | null
          origem?: string | null
          pdop?: number | null
          projeto_id?: string
          qualidade_fix?: number | null
          receptor_gnss?: string | null
          satelites?: number | null
          separacao_geoidal_m?: number | null
          sigma_e?: number | null
          sigma_n?: number | null
          sigma_u?: number | null
          sincronizado?: boolean | null
          status_gnss?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      projeto_clientes: {
        Row: {
          area_id: string | null
          atualizado_em: string
          cliente_id: string
          criado_em: string
          deleted_at: string | null
          id: string
          magic_link_expira: string | null
          magic_link_token: string | null
          ordem: number
          papel: string
          principal: boolean
          projeto_id: string
          recebe_magic_link: boolean
        }
        Insert: {
          area_id?: string | null
          atualizado_em?: string
          cliente_id: string
          criado_em?: string
          deleted_at?: string | null
          id?: string
          magic_link_expira?: string | null
          magic_link_token?: string | null
          ordem?: number
          papel?: string
          principal?: boolean
          projeto_id: string
          recebe_magic_link?: boolean
        }
        Update: {
          area_id?: string | null
          atualizado_em?: string
          cliente_id?: string
          criado_em?: string
          deleted_at?: string | null
          id?: string
          magic_link_expira?: string | null
          magic_link_token?: string | null
          ordem?: number
          papel?: string
          principal?: boolean
          projeto_id?: string
          recebe_magic_link?: boolean
        }
        Relationships: [
          {
            foreignKeyName: "projeto_clientes_area_id_fkey"
            columns: ["area_id"]
            isOneToOne: false
            referencedRelation: "areas_projeto"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projeto_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projeto_clientes_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
          {
            foreignKeyName: "projeto_clientes_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projeto_clientes_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projeto_clientes_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "projeto_clientes_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      projetos: {
        Row: {
          area_ha: number | null
          atualizado_em: string | null
          cep_imovel: string | null
          classe_imovel: string | null
          cliente_id: string | null
          comarca: string | null
          criado_em: string | null
          data_aprovacao: string | null
          data_entrega: string | null
          data_medicao: string | null
          data_protocolo: string | null
          deleted_at: string | null
          descricao: string | null
          distancia_asfalto_km: number | null
          distancia_sede_km: number | null
          endereco_imovel: string | null
          endereco_imovel_numero: string | null
          estado: string | null
          funcao_publica: boolean | null
          id: string
          matricula: string | null
          municipio: string | null
          nome: string
          nome_imovel: string | null
          numero_job: string | null
          possui_imovel_rural: boolean | null
          prazo_estimado: string | null
          renda_familiar: number | null
          srid: number | null
          status: string | null
          tempo_posse_anos: number | null
          tipo_processo: string | null
          valor_pago: number | null
          valor_servico: number | null
          zona_utm: string | null
        }
        Insert: {
          area_ha?: number | null
          atualizado_em?: string | null
          cep_imovel?: string | null
          classe_imovel?: string | null
          cliente_id?: string | null
          comarca?: string | null
          criado_em?: string | null
          data_aprovacao?: string | null
          data_entrega?: string | null
          data_medicao?: string | null
          data_protocolo?: string | null
          deleted_at?: string | null
          descricao?: string | null
          distancia_asfalto_km?: number | null
          distancia_sede_km?: number | null
          endereco_imovel?: string | null
          endereco_imovel_numero?: string | null
          estado?: string | null
          funcao_publica?: boolean | null
          id?: string
          matricula?: string | null
          municipio?: string | null
          nome: string
          nome_imovel?: string | null
          numero_job?: string | null
          possui_imovel_rural?: boolean | null
          prazo_estimado?: string | null
          renda_familiar?: number | null
          srid?: number | null
          status?: string | null
          tempo_posse_anos?: number | null
          tipo_processo?: string | null
          valor_pago?: number | null
          valor_servico?: number | null
          zona_utm?: string | null
        }
        Update: {
          area_ha?: number | null
          atualizado_em?: string | null
          cep_imovel?: string | null
          classe_imovel?: string | null
          cliente_id?: string | null
          comarca?: string | null
          criado_em?: string | null
          data_aprovacao?: string | null
          data_entrega?: string | null
          data_medicao?: string | null
          data_protocolo?: string | null
          deleted_at?: string | null
          descricao?: string | null
          distancia_asfalto_km?: number | null
          distancia_sede_km?: number | null
          endereco_imovel?: string | null
          endereco_imovel_numero?: string | null
          estado?: string | null
          funcao_publica?: boolean | null
          id?: string
          matricula?: string | null
          municipio?: string | null
          nome?: string
          nome_imovel?: string | null
          numero_job?: string | null
          possui_imovel_rural?: boolean | null
          prazo_estimado?: string | null
          renda_familiar?: number | null
          srid?: number | null
          status?: string | null
          tempo_posse_anos?: number | null
          tipo_processo?: string | null
          valor_pago?: number | null
          valor_servico?: number | null
          zona_utm?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "projetos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projetos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
        ]
      }
      spatial_ref_sys: {
        Row: {
          auth_name: string | null
          auth_srid: number | null
          proj4text: string | null
          srid: number
          srtext: string | null
        }
        Insert: {
          auth_name?: string | null
          auth_srid?: number | null
          proj4text?: string | null
          srid: number
          srtext?: string | null
        }
        Update: {
          auth_name?: string | null
          auth_srid?: number | null
          proj4text?: string | null
          srid?: number
          srtext?: string | null
        }
        Relationships: []
      }
      tecnico: {
        Row: {
          ativo: boolean | null
          codigo_incra: string | null
          cpf: string | null
          crea: string | null
          criado_em: string | null
          crt: string | null
          email: string | null
          estado: string | null
          id: string
          municipio: string | null
          nome: string
          rg: string | null
          telefone: string | null
        }
        Insert: {
          ativo?: boolean | null
          codigo_incra?: string | null
          cpf?: string | null
          crea?: string | null
          criado_em?: string | null
          crt?: string | null
          email?: string | null
          estado?: string | null
          id?: string
          municipio?: string | null
          nome: string
          rg?: string | null
          telefone?: string | null
        }
        Update: {
          ativo?: boolean | null
          codigo_incra?: string | null
          cpf?: string | null
          crea?: string | null
          criado_em?: string | null
          crt?: string | null
          email?: string | null
          estado?: string | null
          id?: string
          municipio?: string | null
          nome?: string
          rg?: string | null
          telefone?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      geography_columns: {
        Row: {
          coord_dimension: number | null
          f_geography_column: unknown
          f_table_catalog: unknown
          f_table_name: unknown
          f_table_schema: unknown
          srid: number | null
          type: string | null
        }
        Relationships: []
      }
      geometry_columns: {
        Row: {
          coord_dimension: number | null
          f_geometry_column: unknown
          f_table_catalog: string | null
          f_table_name: unknown
          f_table_schema: unknown
          srid: number | null
          type: string | null
        }
        Insert: {
          coord_dimension?: number | null
          f_geometry_column?: unknown
          f_table_catalog?: string | null
          f_table_name?: unknown
          f_table_schema?: unknown
          srid?: number | null
          type?: string | null
        }
        Update: {
          coord_dimension?: number | null
          f_geometry_column?: unknown
          f_table_catalog?: string | null
          f_table_name?: unknown
          f_table_schema?: unknown
          srid?: number | null
          type?: string | null
        }
        Relationships: []
      }
      vw_alertas_prazo: {
        Row: {
          cliente_nome: string | null
          dias_atraso: number | null
          id: string | null
          nome: string | null
          numero_job: string | null
          prazo_estimado: string | null
          situacao_prazo: string | null
          status: string | null
          telefone: string | null
        }
        Relationships: []
      }
      vw_formulario_cliente: {
        Row: {
          area_ha: number | null
          cep: string | null
          cep_imovel: string | null
          cliente_cpf: string | null
          cliente_estado: string | null
          cliente_id: string | null
          cliente_municipio: string | null
          cliente_nome: string | null
          cliente_rg: string | null
          comarca: string | null
          conjuge_cpf: string | null
          conjuge_nome: string | null
          email: string | null
          endereco: string | null
          endereco_imovel: string | null
          endereco_imovel_numero: string | null
          endereco_numero: string | null
          estado_civil: string | null
          formulario_em: string | null
          formulario_ok: boolean | null
          imovel_estado: string | null
          imovel_municipio: string | null
          magic_link_expira: string | null
          magic_link_token: string | null
          matricula: string | null
          nome_imovel: string | null
          profissao: string | null
          projeto_id: string | null
          projeto_nome: string | null
          telefone: string | null
        }
        Relationships: []
      }
      vw_pontos_geo: {
        Row: {
          altitude_m: number | null
          codigo: string | null
          descricao: string | null
          id: string | null
          lat: number | null
          lon: number | null
          nome: string | null
          projeto_id: string | null
        }
        Insert: {
          altitude_m?: number | null
          codigo?: string | null
          descricao?: string | null
          id?: string | null
          lat?: never
          lon?: never
          nome?: string | null
          projeto_id?: string | null
        }
        Update: {
          altitude_m?: number | null
          codigo?: string | null
          descricao?: string | null
          id?: string | null
          lat?: never
          lon?: never
          nome?: string | null
          projeto_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      vw_pontos_utm: {
        Row: {
          altitude_m: number | null
          camada: string | null
          codigo: string | null
          coletado_em: string | null
          deleted_at: string | null
          descricao: string | null
          epsg_utm: number | null
          este_utm: number | null
          hdop: number | null
          id: string | null
          latitude: number | null
          longitude: number | null
          nome: string | null
          norte_utm: number | null
          num_amostras: number | null
          projeto_id: string | null
          qualidade_fix: number | null
          zona_utm: string | null
        }
        Relationships: [
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "projetos"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_alertas_prazo"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["projeto_id"]
          },
          {
            foreignKeyName: "pontos_projeto_id_fkey"
            columns: ["projeto_id"]
            isOneToOne: false
            referencedRelation: "vw_projetos_completo"
            referencedColumns: ["id"]
          },
        ]
      }
      vw_projeto_clientes: {
        Row: {
          area_id: string | null
          cliente_cpf: string | null
          cliente_id: string | null
          cliente_nome: string | null
          email: string | null
          ordem: number | null
          principal: boolean | null
          projeto_id: string | null
          projeto_nome: string | null
          recebe_magic_link: boolean | null
          telefone: string | null
          vinculo: string | null
        }
        Relationships: []
      }
      vw_projetos_completo: {
        Row: {
          area_ha: number | null
          atualizado_em: string | null
          cep_imovel: string | null
          classe_imovel: string | null
          cliente_email: string | null
          cliente_estado: string | null
          cliente_id: string | null
          cliente_municipio: string | null
          cliente_nome: string | null
          cliente_telefone: string | null
          comarca: string | null
          criado_em: string | null
          data_aprovacao: string | null
          data_entrega: string | null
          data_medicao: string | null
          data_protocolo: string | null
          deleted_at: string | null
          descricao: string | null
          distancia_asfalto_km: number | null
          distancia_sede_km: number | null
          endereco_imovel: string | null
          endereco_imovel_numero: string | null
          estado: string | null
          funcao_publica: boolean | null
          id: string | null
          matricula: string | null
          municipio: string | null
          nome: string | null
          nome_imovel: string | null
          numero_job: string | null
          possui_imovel_rural: boolean | null
          prazo_estimado: string | null
          projeto_nome: string | null
          renda_familiar: number | null
          srid: number | null
          status: string | null
          tempo_posse_anos: number | null
          tipo_processo: string | null
          total_pontos: number | null
          valor_pago: number | null
          valor_servico: number | null
          zona_utm: string | null
        }
        Relationships: [
          {
            foreignKeyName: "projetos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "clientes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projetos_cliente_id_fkey"
            columns: ["cliente_id"]
            isOneToOne: false
            referencedRelation: "vw_formulario_cliente"
            referencedColumns: ["cliente_id"]
          },
        ]
      }
    }
    Functions: {
      _postgis_deprecate: {
        Args: { newname: string; oldname: string; version: string }
        Returns: undefined
      }
      _postgis_index_extent: {
        Args: { col: string; tbl: unknown }
        Returns: unknown
      }
      _postgis_pgsql_version: { Args: never; Returns: string }
      _postgis_scripts_pgsql_version: { Args: never; Returns: string }
      _postgis_selectivity: {
        Args: { att_name: string; geom: unknown; mode?: string; tbl: unknown }
        Returns: number
      }
      _postgis_stats: {
        Args: { ""?: string; att_name: string; tbl: unknown }
        Returns: string
      }
      _st_3dintersects: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_contains: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_containsproperly: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_coveredby:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      _st_covers:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      _st_crosses: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_dwithin: {
        Args: {
          geog1: unknown
          geog2: unknown
          tolerance: number
          use_spheroid?: boolean
        }
        Returns: boolean
      }
      _st_equals: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      _st_intersects: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_linecrossingdirection: {
        Args: { line1: unknown; line2: unknown }
        Returns: number
      }
      _st_longestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      _st_maxdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      _st_orderingequals: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_overlaps: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_sortablehash: { Args: { geom: unknown }; Returns: number }
      _st_touches: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_voronoi: {
        Args: {
          clip?: unknown
          g1: unknown
          return_polygons?: boolean
          tolerance?: number
        }
        Returns: unknown
      }
      _st_within: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      addauth: { Args: { "": string }; Returns: boolean }
      addgeometrycolumn:
        | {
            Args: {
              catalog_name: string
              column_name: string
              new_dim: number
              new_srid_in: number
              new_type: string
              schema_name: string
              table_name: string
              use_typmod?: boolean
            }
            Returns: string
          }
        | {
            Args: {
              column_name: string
              new_dim: number
              new_srid: number
              new_type: string
              schema_name: string
              table_name: string
              use_typmod?: boolean
            }
            Returns: string
          }
        | {
            Args: {
              column_name: string
              new_dim: number
              new_srid: number
              new_type: string
              table_name: string
              use_typmod?: boolean
            }
            Returns: string
          }
      buscar_normas: {
        Args: { match_count?: number; query_embedding: string }
        Returns: {
          documento: string
          fonte: string
          id: string
          pagina: number
          similaridade: number
          texto: string
        }[]
      }
      disablelongtransactions: { Args: never; Returns: string }
      dropgeometrycolumn:
        | {
            Args: {
              catalog_name: string
              column_name: string
              schema_name: string
              table_name: string
            }
            Returns: string
          }
        | {
            Args: {
              column_name: string
              schema_name: string
              table_name: string
            }
            Returns: string
          }
        | { Args: { column_name: string; table_name: string }; Returns: string }
      dropgeometrytable:
        | {
            Args: {
              catalog_name: string
              schema_name: string
              table_name: string
            }
            Returns: string
          }
        | { Args: { schema_name: string; table_name: string }; Returns: string }
        | { Args: { table_name: string }; Returns: string }
      enablelongtransactions: { Args: never; Returns: string }
      equals: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      geometry: { Args: { "": string }; Returns: unknown }
      geometry_above: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_below: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_cmp: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      geometry_contained_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_contains: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_contains_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_distance_box: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      geometry_distance_centroid: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      geometry_eq: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_ge: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_gt: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_le: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_left: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_lt: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overabove: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overbelow: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overlaps: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overlaps_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overleft: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overright: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_right: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_same: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_same_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_within: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geomfromewkt: { Args: { "": string }; Returns: unknown }
      gettransactionid: { Args: never; Returns: unknown }
      longtransactionsenabled: { Args: never; Returns: boolean }
      populate_geometry_columns:
        | { Args: { tbl_oid: unknown; use_typmod?: boolean }; Returns: number }
        | { Args: { use_typmod?: boolean }; Returns: string }
      postgis_constraint_dims: {
        Args: { geomcolumn: string; geomschema: string; geomtable: string }
        Returns: number
      }
      postgis_constraint_srid: {
        Args: { geomcolumn: string; geomschema: string; geomtable: string }
        Returns: number
      }
      postgis_constraint_type: {
        Args: { geomcolumn: string; geomschema: string; geomtable: string }
        Returns: string
      }
      postgis_extensions_upgrade: { Args: never; Returns: string }
      postgis_full_version: { Args: never; Returns: string }
      postgis_geos_version: { Args: never; Returns: string }
      postgis_lib_build_date: { Args: never; Returns: string }
      postgis_lib_revision: { Args: never; Returns: string }
      postgis_lib_version: { Args: never; Returns: string }
      postgis_libjson_version: { Args: never; Returns: string }
      postgis_liblwgeom_version: { Args: never; Returns: string }
      postgis_libprotobuf_version: { Args: never; Returns: string }
      postgis_libxml_version: { Args: never; Returns: string }
      postgis_proj_version: { Args: never; Returns: string }
      postgis_scripts_build_date: { Args: never; Returns: string }
      postgis_scripts_installed: { Args: never; Returns: string }
      postgis_scripts_released: { Args: never; Returns: string }
      postgis_svn_version: { Args: never; Returns: string }
      postgis_type_name: {
        Args: {
          coord_dimension: number
          geomname: string
          use_new_name?: boolean
        }
        Returns: string
      }
      postgis_version: { Args: never; Returns: string }
      postgis_wagyu_version: { Args: never; Returns: string }
      st_3dclosestpoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_3ddistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_3dintersects: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_3dlongestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_3dmakebox: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_3dmaxdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_3dshortestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_addpoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_angle:
        | { Args: { line1: unknown; line2: unknown }; Returns: number }
        | {
            Args: { pt1: unknown; pt2: unknown; pt3: unknown; pt4?: unknown }
            Returns: number
          }
      st_area:
        | { Args: { geog: unknown; use_spheroid?: boolean }; Returns: number }
        | { Args: { "": string }; Returns: number }
      st_asencodedpolyline: {
        Args: { geom: unknown; nprecision?: number }
        Returns: string
      }
      st_asewkt: { Args: { "": string }; Returns: string }
      st_asgeojson:
        | {
            Args: { geog: unknown; maxdecimaldigits?: number; options?: number }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; options?: number }
            Returns: string
          }
        | {
            Args: {
              geom_column?: string
              maxdecimaldigits?: number
              pretty_bool?: boolean
              r: Record<string, unknown>
            }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
      st_asgml:
        | {
            Args: {
              geog: unknown
              id?: string
              maxdecimaldigits?: number
              nprefix?: string
              options?: number
            }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; options?: number }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
        | {
            Args: {
              geog: unknown
              id?: string
              maxdecimaldigits?: number
              nprefix?: string
              options?: number
              version: number
            }
            Returns: string
          }
        | {
            Args: {
              geom: unknown
              id?: string
              maxdecimaldigits?: number
              nprefix?: string
              options?: number
              version: number
            }
            Returns: string
          }
      st_askml:
        | {
            Args: { geog: unknown; maxdecimaldigits?: number; nprefix?: string }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; nprefix?: string }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
      st_aslatlontext: {
        Args: { geom: unknown; tmpl?: string }
        Returns: string
      }
      st_asmarc21: { Args: { format?: string; geom: unknown }; Returns: string }
      st_asmvtgeom: {
        Args: {
          bounds: unknown
          buffer?: number
          clip_geom?: boolean
          extent?: number
          geom: unknown
        }
        Returns: unknown
      }
      st_assvg:
        | {
            Args: { geog: unknown; maxdecimaldigits?: number; rel?: number }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; rel?: number }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
      st_astext: { Args: { "": string }; Returns: string }
      st_astwkb:
        | {
            Args: {
              geom: unknown
              prec?: number
              prec_m?: number
              prec_z?: number
              with_boxes?: boolean
              with_sizes?: boolean
            }
            Returns: string
          }
        | {
            Args: {
              geom: unknown[]
              ids: number[]
              prec?: number
              prec_m?: number
              prec_z?: number
              with_boxes?: boolean
              with_sizes?: boolean
            }
            Returns: string
          }
      st_asx3d: {
        Args: { geom: unknown; maxdecimaldigits?: number; options?: number }
        Returns: string
      }
      st_azimuth:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: number }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: number }
      st_boundingdiagonal: {
        Args: { fits?: boolean; geom: unknown }
        Returns: unknown
      }
      st_buffer:
        | {
            Args: { geom: unknown; options?: string; radius: number }
            Returns: unknown
          }
        | {
            Args: { geom: unknown; quadsegs: number; radius: number }
            Returns: unknown
          }
      st_centroid: { Args: { "": string }; Returns: unknown }
      st_clipbybox2d: {
        Args: { box: unknown; geom: unknown }
        Returns: unknown
      }
      st_closestpoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_collect: { Args: { geom1: unknown; geom2: unknown }; Returns: unknown }
      st_concavehull: {
        Args: {
          param_allow_holes?: boolean
          param_geom: unknown
          param_pctconvex: number
        }
        Returns: unknown
      }
      st_contains: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_containsproperly: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_coorddim: { Args: { geometry: unknown }; Returns: number }
      st_coveredby:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_covers:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_crosses: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_curvetoline: {
        Args: { flags?: number; geom: unknown; tol?: number; toltype?: number }
        Returns: unknown
      }
      st_delaunaytriangles: {
        Args: { flags?: number; g1: unknown; tolerance?: number }
        Returns: unknown
      }
      st_difference: {
        Args: { geom1: unknown; geom2: unknown; gridsize?: number }
        Returns: unknown
      }
      st_disjoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_distance:
        | {
            Args: { geog1: unknown; geog2: unknown; use_spheroid?: boolean }
            Returns: number
          }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: number }
      st_distancesphere:
        | { Args: { geom1: unknown; geom2: unknown }; Returns: number }
        | {
            Args: { geom1: unknown; geom2: unknown; radius: number }
            Returns: number
          }
      st_distancespheroid: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_dwithin: {
        Args: {
          geog1: unknown
          geog2: unknown
          tolerance: number
          use_spheroid?: boolean
        }
        Returns: boolean
      }
      st_equals: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_expand:
        | { Args: { box: unknown; dx: number; dy: number }; Returns: unknown }
        | {
            Args: { box: unknown; dx: number; dy: number; dz?: number }
            Returns: unknown
          }
        | {
            Args: {
              dm?: number
              dx: number
              dy: number
              dz?: number
              geom: unknown
            }
            Returns: unknown
          }
      st_force3d: { Args: { geom: unknown; zvalue?: number }; Returns: unknown }
      st_force3dm: {
        Args: { geom: unknown; mvalue?: number }
        Returns: unknown
      }
      st_force3dz: {
        Args: { geom: unknown; zvalue?: number }
        Returns: unknown
      }
      st_force4d: {
        Args: { geom: unknown; mvalue?: number; zvalue?: number }
        Returns: unknown
      }
      st_generatepoints:
        | { Args: { area: unknown; npoints: number }; Returns: unknown }
        | {
            Args: { area: unknown; npoints: number; seed: number }
            Returns: unknown
          }
      st_geogfromtext: { Args: { "": string }; Returns: unknown }
      st_geographyfromtext: { Args: { "": string }; Returns: unknown }
      st_geohash:
        | { Args: { geog: unknown; maxchars?: number }; Returns: string }
        | { Args: { geom: unknown; maxchars?: number }; Returns: string }
      st_geomcollfromtext: { Args: { "": string }; Returns: unknown }
      st_geometricmedian: {
        Args: {
          fail_if_not_converged?: boolean
          g: unknown
          max_iter?: number
          tolerance?: number
        }
        Returns: unknown
      }
      st_geometryfromtext: { Args: { "": string }; Returns: unknown }
      st_geomfromewkt: { Args: { "": string }; Returns: unknown }
      st_geomfromgeojson:
        | { Args: { "": Json }; Returns: unknown }
        | { Args: { "": Json }; Returns: unknown }
        | { Args: { "": string }; Returns: unknown }
      st_geomfromgml: { Args: { "": string }; Returns: unknown }
      st_geomfromkml: { Args: { "": string }; Returns: unknown }
      st_geomfrommarc21: { Args: { marc21xml: string }; Returns: unknown }
      st_geomfromtext: { Args: { "": string }; Returns: unknown }
      st_gmltosql: { Args: { "": string }; Returns: unknown }
      st_hasarc: { Args: { geometry: unknown }; Returns: boolean }
      st_hausdorffdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_hexagon: {
        Args: { cell_i: number; cell_j: number; origin?: unknown; size: number }
        Returns: unknown
      }
      st_hexagongrid: {
        Args: { bounds: unknown; size: number }
        Returns: Record<string, unknown>[]
      }
      st_interpolatepoint: {
        Args: { line: unknown; point: unknown }
        Returns: number
      }
      st_intersection: {
        Args: { geom1: unknown; geom2: unknown; gridsize?: number }
        Returns: unknown
      }
      st_intersects:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_isvaliddetail: {
        Args: { flags?: number; geom: unknown }
        Returns: Database["public"]["CompositeTypes"]["valid_detail"]
        SetofOptions: {
          from: "*"
          to: "valid_detail"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      st_length:
        | { Args: { geog: unknown; use_spheroid?: boolean }; Returns: number }
        | { Args: { "": string }; Returns: number }
      st_letters: { Args: { font?: Json; letters: string }; Returns: unknown }
      st_linecrossingdirection: {
        Args: { line1: unknown; line2: unknown }
        Returns: number
      }
      st_linefromencodedpolyline: {
        Args: { nprecision?: number; txtin: string }
        Returns: unknown
      }
      st_linefromtext: { Args: { "": string }; Returns: unknown }
      st_linelocatepoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_linetocurve: { Args: { geometry: unknown }; Returns: unknown }
      st_locatealong: {
        Args: { geometry: unknown; leftrightoffset?: number; measure: number }
        Returns: unknown
      }
      st_locatebetween: {
        Args: {
          frommeasure: number
          geometry: unknown
          leftrightoffset?: number
          tomeasure: number
        }
        Returns: unknown
      }
      st_locatebetweenelevations: {
        Args: { fromelevation: number; geometry: unknown; toelevation: number }
        Returns: unknown
      }
      st_longestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_makebox2d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_makeline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_makevalid: {
        Args: { geom: unknown; params: string }
        Returns: unknown
      }
      st_maxdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_minimumboundingcircle: {
        Args: { inputgeom: unknown; segs_per_quarter?: number }
        Returns: unknown
      }
      st_mlinefromtext: { Args: { "": string }; Returns: unknown }
      st_mpointfromtext: { Args: { "": string }; Returns: unknown }
      st_mpolyfromtext: { Args: { "": string }; Returns: unknown }
      st_multilinestringfromtext: { Args: { "": string }; Returns: unknown }
      st_multipointfromtext: { Args: { "": string }; Returns: unknown }
      st_multipolygonfromtext: { Args: { "": string }; Returns: unknown }
      st_node: { Args: { g: unknown }; Returns: unknown }
      st_normalize: { Args: { geom: unknown }; Returns: unknown }
      st_offsetcurve: {
        Args: { distance: number; line: unknown; params?: string }
        Returns: unknown
      }
      st_orderingequals: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_overlaps: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_perimeter: {
        Args: { geog: unknown; use_spheroid?: boolean }
        Returns: number
      }
      st_pointfromtext: { Args: { "": string }; Returns: unknown }
      st_pointm: {
        Args: {
          mcoordinate: number
          srid?: number
          xcoordinate: number
          ycoordinate: number
        }
        Returns: unknown
      }
      st_pointz: {
        Args: {
          srid?: number
          xcoordinate: number
          ycoordinate: number
          zcoordinate: number
        }
        Returns: unknown
      }
      st_pointzm: {
        Args: {
          mcoordinate: number
          srid?: number
          xcoordinate: number
          ycoordinate: number
          zcoordinate: number
        }
        Returns: unknown
      }
      st_polyfromtext: { Args: { "": string }; Returns: unknown }
      st_polygonfromtext: { Args: { "": string }; Returns: unknown }
      st_project: {
        Args: { azimuth: number; distance: number; geog: unknown }
        Returns: unknown
      }
      st_quantizecoordinates: {
        Args: {
          g: unknown
          prec_m?: number
          prec_x: number
          prec_y?: number
          prec_z?: number
        }
        Returns: unknown
      }
      st_reduceprecision: {
        Args: { geom: unknown; gridsize: number }
        Returns: unknown
      }
      st_relate: { Args: { geom1: unknown; geom2: unknown }; Returns: string }
      st_removerepeatedpoints: {
        Args: { geom: unknown; tolerance?: number }
        Returns: unknown
      }
      st_segmentize: {
        Args: { geog: unknown; max_segment_length: number }
        Returns: unknown
      }
      st_setsrid:
        | { Args: { geog: unknown; srid: number }; Returns: unknown }
        | { Args: { geom: unknown; srid: number }; Returns: unknown }
      st_sharedpaths: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_shortestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_simplifypolygonhull: {
        Args: { geom: unknown; is_outer?: boolean; vertex_fraction: number }
        Returns: unknown
      }
      st_split: { Args: { geom1: unknown; geom2: unknown }; Returns: unknown }
      st_square: {
        Args: { cell_i: number; cell_j: number; origin?: unknown; size: number }
        Returns: unknown
      }
      st_squaregrid: {
        Args: { bounds: unknown; size: number }
        Returns: Record<string, unknown>[]
      }
      st_srid:
        | { Args: { geog: unknown }; Returns: number }
        | { Args: { geom: unknown }; Returns: number }
      st_subdivide: {
        Args: { geom: unknown; gridsize?: number; maxvertices?: number }
        Returns: unknown[]
      }
      st_swapordinates: {
        Args: { geom: unknown; ords: unknown }
        Returns: unknown
      }
      st_symdifference: {
        Args: { geom1: unknown; geom2: unknown; gridsize?: number }
        Returns: unknown
      }
      st_symmetricdifference: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_tileenvelope: {
        Args: {
          bounds?: unknown
          margin?: number
          x: number
          y: number
          zoom: number
        }
        Returns: unknown
      }
      st_touches: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_transform:
        | {
            Args: { from_proj: string; geom: unknown; to_proj: string }
            Returns: unknown
          }
        | {
            Args: { from_proj: string; geom: unknown; to_srid: number }
            Returns: unknown
          }
        | { Args: { geom: unknown; to_proj: string }; Returns: unknown }
      st_triangulatepolygon: { Args: { g1: unknown }; Returns: unknown }
      st_union:
        | { Args: { geom1: unknown; geom2: unknown }; Returns: unknown }
        | {
            Args: { geom1: unknown; geom2: unknown; gridsize: number }
            Returns: unknown
          }
      st_voronoilines: {
        Args: { extend_to?: unknown; g1: unknown; tolerance?: number }
        Returns: unknown
      }
      st_voronoipolygons: {
        Args: { extend_to?: unknown; g1: unknown; tolerance?: number }
        Returns: unknown
      }
      st_within: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_wkbtosql: { Args: { wkb: string }; Returns: unknown }
      st_wkttosql: { Args: { "": string }; Returns: unknown }
      st_wrapx: {
        Args: { geom: unknown; move: number; wrap: number }
        Returns: unknown
      }
      unlockrows: { Args: { "": string }; Returns: number }
      updategeometrysrid: {
        Args: {
          catalogn_name: string
          column_name: string
          new_srid_in: number
          schema_name: string
          table_name: string
        }
        Returns: string
      }
      utm_srid_por_zona: { Args: { zona: string }; Returns: number }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      geometry_dump: {
        path: number[] | null
        geom: unknown
      }
      valid_detail: {
        valid: boolean | null
        reason: string | null
        location: unknown
      }
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
