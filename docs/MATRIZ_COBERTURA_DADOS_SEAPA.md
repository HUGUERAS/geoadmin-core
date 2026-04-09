# GeoAdmin Pro — Matriz de Cobertura de Dados SEAPA

## Objetivo

Este documento responde, com base em evidência local, se o modelo atual de banco e contratos do `GeoAdmin Pro` consegue suprir os formulários da pasta:

- `D:\TRABALHO\pastas de trabalho\regularização na SEAPA`

## Fontes auditadas

### Formulários reais lidos

- `01_GPRF_RequerimentodeTitulacao_2023-675.docx`
- `02_GPRF_RequerimentoOrdemdeServico_2023-9b3.docx`
- `03_GPRF_RequerimentoDiverso_2023-8f6.docx`
- `03-Declaracaoderespeitodelimites-f1c.docx`
- `05_GPRF_DeclaracaodeFuncaoPublica_2023-5d0.docx`
- `06-GPRF-DeclaracaoImovelRural_2023-b5c.docx`
- `07_GPRF_DeclaracaodeResidencia_2023-f80.docx`
- `14_GPRF_FichadeVistoria_2023-db9.docx`
- `produto final modelo/Declaracaoderespeitodelimites seapa.docx`
- `produto final modelo/MAPAMODELO_rev1-PLANTA-Model-85a.pdf`

### Schema e contratos comparados

- [infra/supabase/database.types.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\infra\supabase\database.types.ts)
- [backend/schemas/contratos_v1.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\schemas\contratos_v1.py)
- [mobile/types/contratos-v1.ts](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\mobile\types\contratos-v1.ts)
- [backend/integracoes/gerador_documentos.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\integracoes\gerador_documentos.py)

## Resposta curta

**Não ainda, não com certeza total de dados.**

O banco atual do `GeoAdmin Pro` já cobre muito bem o **cadastro civil básico**, a **identificação principal do imóvel**, os **confrontantes básicos**, a **geometria/cartografia essencial** e parte do **fluxo documental**.

Mas ele **ainda não cobre integralmente, de forma estruturada e auditável**, todos os dados exigidos pelos formulários SEAPA e pela ficha de vistoria.

## Critério de leitura

- `Coberto`: o dado já existe de forma estruturada no schema atual
- `Parcial`: o dado existe em parte, ou existe só em view/template/derivação
- `Não coberto`: o dado não está estruturado hoje no banco oficial

## Blocos de dados

### 1. Identificação civil do requerente

Campos identificados nos formulários:

- nome do requerente
- CPF/CNPJ
- RG
- estado civil
- profissão
- telefone
- e-mail
- endereço
- número
- setor
- município
- estado
- CEP
- cônjuge

Cobertura atual: **Coberto**

Base de evidência:

- `clientes.nome`
- `clientes.cpf` / `clientes.cpf_cnpj`
- `clientes.rg`
- `clientes.estado_civil`
- `clientes.profissao`
- `clientes.telefone`
- `clientes.email`
- `clientes.endereco`
- `clientes.endereco_numero`
- `clientes.setor`
- `clientes.municipio`
- `clientes.estado`
- `clientes.cep`
- `clientes.conjuge_nome`
- `clientes.conjuge_cpf`

Conclusão:

- este bloco já consegue sustentar bem:
  - requerimento de titulação
  - requerimento diverso
  - declaração de função pública
  - declaração de não possuir imóvel rural
  - declaração de residência

### 2. Identificação principal do imóvel

Campos identificados:

- nome do imóvel
- município do imóvel
- estado
- comarca
- matrícula
- endereço do imóvel
- número do imóvel
- CEP do imóvel
- área do imóvel

Cobertura atual: **Coberto**

Base de evidência:

- `projetos.nome_imovel`
- `projetos.municipio`
- `projetos.estado`
- `projetos.comarca`
- `projetos.matricula`
- `projetos.endereco_imovel`
- `projetos.endereco_imovel_numero`
- `projetos.cep_imovel`
- `projetos.area_ha`
- `areas_projeto.nome`
- `areas_projeto.municipio`
- `areas_projeto.estado`
- `areas_projeto.comarca`
- `areas_projeto.matricula`

Conclusão:

- o bloco do imóvel está bem encaminhado para peças cadastrais e documentais básicas

### 3. Situação possessória e informações socioeconômicas básicas

Campos identificados:

- tempo de ocupação
- exerce função pública
- possui outro imóvel rural
- renda familiar
- distância à sede do município
- distância ao asfalto

Cobertura atual: **Parcial**

Base de evidência:

- `projetos.tempo_posse_anos`
- `projetos.funcao_publica`
- `projetos.possui_imovel_rural`
- `projetos.renda_familiar`
- `projetos.distancia_sede_km`
- `projetos.distancia_asfalto_km`

Lacuna:

- esses campos existem para o projeto principal, mas a ficha SEAPA pede mais contexto operacional e de vistoria do que o banco registra hoje

### 4. Processo administrativo SEAPA

Campos identificados:

- ordem de serviço
- número de protocolo
- solicitação de vistas e cópia
- data de vistoria
- histórico processual ligado ao requerimento

Cobertura atual: **Não coberto**

Base de evidência:

- há `data_protocolo`, `data_aprovacao`, `data_entrega` em `projetos`
- não há estrutura própria para:
  - número de ordem de serviço
  - data da ordem de serviço
  - protocolo SEAPA por tipo
  - número de notificação
  - histórico de despacho/vistoria

Conclusão:

- este é um dos maiores gaps para gerar documentação SEAPA com certeza

### 5. Ficha de vistoria

Campos identificados na `14_GPRF_FichadeVistoria_2023-db9.docx`:

- ordem de serviço externo/inspeção
- nome do informante
- CPF do informante
- nome do transmitente da posse
- cartório
- desmembramento de outro imóvel
- RPPN
- protocolo anterior
- classificação de capacidade
- áreas por uso:
  - cultura permanente
  - cultura anual
  - pastagem natural
  - pastagem artificial
- confirmação de georreferenciamento
- enquadramento em desconto / hipossuficiência / programas sociais

Cobertura atual: **Não coberto**

Conclusão:

- a ficha de vistoria **não pode ser gerada com certeza total** a partir do banco atual
- hoje esse bloco exigiria preenchimento manual ou campo textual genérico

### 6. Responsável técnico e credenciamento

Campos identificados:

- nome do técnico
- CPF do técnico
- CFT/CRT ou CREA
- código INCRA / credenciamento
- TRT/ART
- tipo de conselho

Cobertura atual: **Parcial**

Base de evidência:

- [gerador_documentos.py](C:\Users\User\.codex\worktrees\db9b\geoadmin-core\backend\integracoes\gerador_documentos.py) tenta ler:
  - `tecnico.nome`
  - `tecnico.cpf`
  - `tecnico.crt`
  - `tecnico.crea`
  - `tecnico.codigo_incra`

Lacuna:

- esse bloco não aparece consolidado no contrato `ProjetoOficialV1` vindo do banco real
- não há confirmação, pelo schema auditado atual, de uma trilha robusta para:
  - TRT/ART
  - tipo de conselho
  - validade de credenciamento
  - múltiplos responsáveis técnicos quando necessário

Conclusão:

- o gerador já “espera” esse dado, mas ele ainda precisa ser tratado como bloco estruturado e oficial do domínio

### 7. Confrontantes e declaração de respeito de limites

Campos identificados:

- nome do confrontante
- CPF do confrontante
- nome do imóvel confrontante
- matrícula do confrontante
- proprietário principal
- técnico responsável
- tabela técnica de vértices, azimute e distância

Cobertura atual: **Parcial**

Base de evidência:

- `confrontantes.nome`
- `confrontantes.cpf`
- `confrontantes.nome_imovel`
- `confrontantes.matricula`
- `confrontantes.lado`
- geometria disponível via perímetro/área e rotas geodésicas

Lacuna:

- a tabela final de vértices/segmentos precisa ser montada por gerador técnico, não sai pronta do schema
- o bloco do técnico ainda é parcial

Conclusão:

- a declaração de limites está próxima de automação boa
- mas ainda não está garantida integralmente por dado estruturado único

### 8. Cartografia e peça técnica final

Campos identificados no mapa modelo:

- propriedade
- proprietário
- matrícula origem
- cartório
- município
- comarca
- estado
- área total
- perímetro
- escala
- sistema geodésico
- datum
- TRT/ART
- código INCRA
- data de certificação
- CNS
- classes de aptidão/uso

Cobertura atual: **Parcial**

Base de evidência:

- temos geometria, perímetro, confrontantes, nome do imóvel e área
- o mapa PDF exige metadados registrais e técnicos mais ricos do que o schema atual garante

Lacunas principais:

- cartório
- CNS/CNM
- data de certificação
- número de ART/TRT estruturado
- quadro de classes de aptidão/uso em estrutura formal

## O que o banco atual já supre com boa segurança

### Pode sustentar bem

- nome do requerente
- CPF/CNPJ
- RG
- estado civil
- profissão
- e-mail
- telefone
- endereço e CEP
- nome do imóvel
- município/comarca/estado
- matrícula
- área do imóvel
- dados conjugais básicos
- confrontantes básicos
- geometrias/croqui/perímetro
- controle de documentos enviados

## O que ainda não está garantido com certeza de dado

### Gaps reais

- ordem de serviço SEAPA
- protocolo administrativo estruturado
- ficha de vistoria em bloco completo
- transmitente da posse
- informante da vistoria
- campos de desconto/hipossuficiência/programa social
- desmembramento
- RPPN
- classes de uso/capacidade e áreas por cultura/pastagem
- cartório e identificadores registrais mais ricos (`CNS`, `CNM`)
- responsável técnico plenamente estruturado
- ART/TRT estruturada

## Conclusão objetiva

Se a pergunta for:

> “os dados atuais do banco já suprem os formulários da SEAPA?”

A resposta correta é:

**Eles suprem bem o núcleo cadastral e parte do núcleo técnico, mas ainda não suprem com certeza total o conjunto SEAPA completo.**

Para garantir certeza de dados nesses formulários, o app ainda precisa estruturar pelo menos 4 blocos:

1. `processo_administrativo_seapa`
2. `vistoria_seapa`
3. `responsavel_tecnico_oficial`
4. `registro_imobiliario_ampliado`

## Recomendação de produto

### O que dá para automatizar já, com segurança razoável

- requerimento de titulação
- requerimento diverso
- declaração de função pública
- declaração de não possuir imóvel rural
- declaração de residência
- boa parte da declaração de respeito de limites

### O que ainda deve ser tratado como parcial

- ficha de vistoria
- ordem de serviço
- peça cartográfica final completa
- pacote SEAPA completo com garantia jurídica/técnica de preenchimento

## Próximo passo recomendado

Usar esta matriz para abrir uma trilha específica de modelagem:

- `seapa_processo`
- `seapa_vistoria`
- `tecnico_responsavel`
- `registro_imobiliario`

e só então afirmar automação SEAPA plena com certeza de dado.
