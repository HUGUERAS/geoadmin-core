# GeoAdmin Pro - Mapa Mental

Este arquivo serve como visao rapida do produto em formato compativel com Markdown e Obsidian.

Se o visualizador suportar Mermaid, o mapa abaixo pode ser renderizado como diagrama.

```mermaid
mindmap
  root((GeoAdmin Pro))
    Mobile App
      Projetos
        Lista
          GET /projetos
        Novo projeto
          POST /projetos
          POST /projetos/{id}/arquivos
        Detalhe do projeto
          GET /projetos/{id}
          POST /projetos/{id}/magic-link
          POST /projetos/{id}/gerar-documentos
          POST /projetos/{id}/magic-links/lote
          POST /projetos/{id}/areas/importar-arquivo
          POST /projetos/{id}/confrontacoes/revisar
          POST /projetos/{id}/arquivos/{arquivo_id}/promover
          POST /projetos/{id}/arquivos/migrar-legado
          GET /projetos/{id}/confrontacoes/cartas
          GET /projetos/{id}/metrica/manifesto
      Mapa CAD
        Contexto por projeto
          GET /projetos/{id}
        Persistencia do perimetro
          POST /perimetros/
        Ferramentas em contexto
          area local
          inverso local
          irradiacao local
          intersecao local
          distpl local
          deflexao local
          mediaPts local
          conversao local
          rotacao local
          subdivisao local
      Calculos
        Hub tecnico
          GET /projetos/{id}
        Ferramentas remotas
          POST /geo/inverso
          POST /geo/area
          POST /geo/converter/utm-geo
          POST /geo/converter/geo-utm
          POST /geo/intersecao
          POST /geo/distancia-ponto-linha
          POST /geo/rotacao
          POST /geo/subdivisao
        Ferramentas locais
          deflexao
          media
          irradiacao
          linha
          polilinha
          pontos
          nomenclatura
      Clientes
        Lista
          GET /clientes
        Detalhe
          GET /clientes/{id}
          PATCH /clientes/{id}
          POST /clientes/{id}/confrontantes
          PATCH /clientes/{id}/confrontantes/{confrontante_id}
          DELETE /clientes/{id}/confrontantes/{confrontante_id}
          POST /clientes/{id}/geometria-referencia/manual
          POST /clientes/{id}/geometria-referencia/importar-texto
          POST /clientes/{id}/geometria-referencia/importar
          DELETE /clientes/{id}/geometria-referencia
      Bluetooth GNSS
        Coleta local
        Sync
          POST /pontos/sync
    Backend
      main.py
        include_router projetos
        include_router clientes
        include_router exportacao
        include_router documentos
        include_router pontos
        include_router perimetros
        include_router geo
        include_router importar
        include_router catalogo
      Routers criticos
        projetos.py
        documentos.py
        clientes/routes.py
        geo.py
        perimetros.py
        exportacao/routes.py
        pontos.py
    Fluxos criticos
      Criar projeto
      Enviar magic link
      Gerar documentos GPRF
      Importar lotes
      Revisar confrontacoes
      Promover base oficial
      Sincronizar pontos offline
      Preparar pacote do Metrica
    Governanca
      docs/GOVERNANCA_SEGURANCA.md
      security-backend-reviewer
      security-frontend-docs-reviewer
      geoadmin-security-baseline
      geoadmin-security-review
    Pontos de atencao
      mistura fetch direto e api.ts
      POST /metrica/preparar abre via URL
      GET /projetos/{id} virou contrato critico
      CAD depende de bastante logica local
```

## Leitura rapida em arvore

- GeoAdmin Pro
  - Mobile App
    - Projetos
      - Lista
      - Novo projeto
      - Painel do projeto
    - Mapa / CAD
      - Visualizacao
      - Edicao de perimetro
      - Ferramentas em contexto
    - Calculos
      - Hub tecnico
      - Ferramentas remotas
      - Ferramentas locais
    - Clientes
      - Lista
      - Hub documental
    - Bluetooth GNSS
      - Coleta local
      - Sincronizacao
  - Backend
    - Projetos
    - Clientes
    - Documentos
    - Exportacao
    - Pontos
    - Perimetros
    - Geo
  - Fluxos criticos
    - Criacao de projeto
    - Magic link
    - GPRF
    - Lotes
    - Confrontacoes
    - Base oficial
    - Sync offline
    - Metrica
  - Governanca
    - Seguranca
    - Skills
    - Agentes
  - Pontos de atencao
    - padronizacao do cliente HTTP
    - alinhamento do fluxo Metrica
    - contrato do detalhe do projeto

## Documentos relacionados

- [Mapa de telas e rotas](./MAPA_TELAS_E_ROTAS.md)
- [Governanca de seguranca](./GOVERNANCA_SEGURANCA.md)
- [Spec Fase 1 FreeCAD + LibreOffice](./specs/fase-1-freecad-libreoffice/README.md)
