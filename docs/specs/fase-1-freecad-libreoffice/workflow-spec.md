# Workflow Spec — Fase 1 FreeCAD + LibreOffice

## Fluxo principal

O fluxo operacional esperado para a Fase 1 e:

1. tecnico ou operador abre um projeto no `GeoAdmin Pro`
2. valida o perimetro ativo e os dados principais do imovel
3. solicita a exportacao tecnica ou documental
4. o `backend` consolida os dados do projeto
5. o sistema gera uma saida padronizada
6. o usuario consome a saida no `FreeCAD` ou no `LibreOffice`

## Fluxo A — Exportacao do projeto oficial

1. usuario abre o detalhe do projeto
2. clica em `Baixar JSON tecnico`
3. sistema chama `GET /projetos/{id}/exportacao/projeto.json`
4. backend monta o `projeto_oficial`
5. arquivo e entregue ao usuario

Resultado esperado:

- arquivo unico
- estrutura previsivel
- sem necessidade de editar manualmente o conteudo
- pronto para alimentar documentos, CAD e futura automacao administrativa

## Fluxo B — Pacote para FreeCAD

1. usuario abre o detalhe do projeto ou a tela de mapa
2. clica em `Exportar FreeCAD`
3. sistema chama `GET /projetos/{id}/exportacao/freecad`
4. backend gera pacote tecnico
5. usuario baixa o `.zip`
6. usuario abre o `DXF` ou usa o `JSON` no fluxo do `FreeCAD`

Resultado esperado:

- perimetro exportado corretamente
- vertices e nomenclatura coerentes
- pacote tecnico legivel e reutilizavel
- preparado para evoluir para camadas como `reserva legal`, `benfeitorias` e `APP`

## Fluxo C — Memorial ODT/PDF

1. usuario abre o detalhe do projeto
2. clica em `Gerar memorial`
3. sistema chama a rota documental
4. backend usa o mesmo contrato base do projeto
5. memorial e gerado em `ODT`
6. quando suportado pelo ambiente, o sistema tambem gera `PDF`

Resultado esperado:

- documento nasce do mesmo dado tecnico usado na exportacao
- nao existe redigitacao manual do essencial
- documentos administrativos simples devem sair de forma quase automatica

## Regras operacionais

- se nao houver `perimetro_ativo`, a exportacao tecnica falha com mensagem clara
- se faltarem dados documentais obrigatorios, a geracao do memorial deve informar quais campos faltam
- o usuario deve conseguir entender se a falha e tecnica, cadastral ou de ambiente

## Mensagens minimas de erro

- `Projeto sem perimetro ativo`
- `Projeto sem vertices suficientes`
- `Dados documentais incompletos`
- `Dados cadastrais oficiais incompletos`
- `Processo administrativo sem numero ou orgao`
- `Template ODT nao encontrado`
- `Conversao para PDF indisponivel neste ambiente`

## Ponto de entrada recomendado na interface

Tela principal da fase:

- detalhe do projeto

Acoes recomendadas:

- `Baixar JSON tecnico`
- `Exportar FreeCAD`
- `Gerar memorial ODT`
- `Gerar memorial PDF`

## Papel de cada sistema no fluxo

`GeoAdmin Pro`

- organiza dados
- valida regras
- gera os contratos
- centraliza cadastro de proponentes, representantes, cadastros oficiais e processos

`FreeCAD`

- recebe pacote tecnico
- desenha ou complementa a saida CAD

`LibreOffice`

- recebe documento base
- viabiliza ajuste e emissao documental
