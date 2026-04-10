# Descontos por Compromisso de Uso (CUDs) com Base em Gastos (GCP)

Os descontos por compromisso de uso (CUDs) com base em gastos oferecem um desconto em troca do seu compromisso de gastar um valor mínimo por hora em um produto. O desconto se aplica ao conjunto de recursos qualificados para o produto.

**Importante:** este documento aborda alguns descontos por compromisso de uso com base em gastos (CUDs) que migram automaticamente para um novo modelo de consumo, que usa descontos em vez de créditos. A data da migração é indicada por uma notificação na página Visão geral do faturamento do Google Cloud console.

## Produtos Cobertos

Você precisa adquirir compromissos separados com base em gastos para cada produto Google Cloud para o qual os CUDs estão disponíveis. Os CUDs se aplicam ao uso qualificado em todos os projetos pagos pela conta do Cloud Billing.

| CUDs afetados (novo modelo usando descontos) | CUDs não afetados (modelo legado usando créditos) |
| :--- | :--- |
| CUDs flexíveis do Compute (abrange gastos qualificados no Compute Engine, Google Kubernetes Engine e Cloud Run) | Todos os CUDs do VMware Engine |
| AlloyDB para PostgreSQL | Backup e DR (para VMware Engine) |
| Backup e DR (para Oracle) | NetApp Volumes |
| BigQuery (não está mais disponível para compra) | Backup para GKE |
| Bigtable | |
| Cloud SQL | |
| Dataflow | |
| Firestore | |
| Serviço gerenciado para Apache Kafka | |
| Memorystore | |
| Spanner | |
| Cloud Run (não está mais disponível para compra) | |
| Google Kubernetes Engine (GKE) Autopilot (não está mais disponível para compra) | |

## Como os CUDs com base em gastos funcionam

Ao comprar um compromisso, você se compromete com um valor de gasto por hora específico. O sistema verifica seu uso a cada hora para aplicar o desconto.

**Importante:** não é possível cancelar os compromissos que você comprou. É necessário pagar o valor mensal que você aceitou durante a vigência dele.

### CUDs Superutilizados (que excedem seu compromisso)

Se o uso qualificado exceder o valor com que você se comprometeu, o CUD vai cobrir o uso até o limite, e o restante será cobrado pela taxa padrão.
- **Mecanismo:** o sistema aplica o desconto de CUD ao primeiro bloco de uso igual ao seu compromisso.
- **Custo:** qualquer uso além desse limite é cobrado pelo preço sob demanda padrão.

### CUDs Subutilizados (que não atendem ao seu compromisso)

Se o uso qualificado for menor que o valor comprometido, você ainda será responsável pelo custo total do compromisso.
- **Sem transferência:** o compromisso não utilizado não é transferido para a próxima hora.
- **Custo:** você paga o valor total do compromisso que comprou.
- **No novo modelo de consumo:** como você não usou totalmente o compromisso, o crédito FEE_UTILIZATION_OFFSET não será grande o suficiente para anular totalmente a SKU de taxa de CUD de US $1. O saldo restante na SKU de taxa representa seu custo para o compromisso não utilizado.

## Cálculos de faturamento do valor do compromisso e do uso

| Recurso | CUDs afetados (novo modelo usando descontos) | CUDs não afetados (modelo legado usando créditos) |
| :--- | :--- | :--- |
| **Valor do compromisso** | Você se compromete com o gasto com desconto (o valor real que você paga). | Você se compromete com o gasto sob demanda (o valor do preço de tabela). |
| **Cobranças de uso** | O uso é faturado diretamente na taxa com desconto. | O uso é faturado pelo preço de tabela; um crédito compensa o custo. |
| **Exibição de economia** | Os relatórios mostram a economia líquida (diferença calculada). | Os relatórios mostram o valor do crédito bruto. |

## Modelos de consumo

No Cloud Billing, um modelo de consumo representa o preço que você paga por uma determinada quantidade de uso de SKU em um determinado contexto. Uma SKU pode ter vários modelos de consumo, mas apenas um se aplica a qualquer quantidade de uso em um momento específico.

- **Padrão:** representa o preço de tabela padrão.
- **Modelo de CUD:** representa o preço com desconto (por exemplo, "CUD flexível do Compute – 1 ano").

## Mudanças na estrutura de SKUs e taxas

O novo modelo de CUD apresenta mudanças estruturais:

- **Preços de tabela de uso x preços de tabela de taxas:** o preço de tabela da SKU uso não mudou. O preço de tabela das SKUs de taxa mudou para US$1.
- **Comparação direta:** como as SKUs de taxa agora são de US $1, não é possível comparar os custos brutos diretamente entre os modelos.
- **Fórmula de cálculo de economia:** `Cost at on-demand rates - Cost at CUD consumption rate + CUD Fees`
- **Compensação de utilização de taxas:** quando você usa o CUD, o sistema aplica um crédito chamado `FEE_UTILIZATION_OFFSET` que anula especificamente o custo da SKU de taxa de CUD.

## Tarefas comuns de CUD com base em gastos

- Comprar compromissos com base em gastos.
- Ver seus compromissos.
- Verificar seus descontos após a migração.
- Analisar a eficácia dos seus CUDs.

### Comprar compromissos com base em gastos

- **Especificidade da região:** a maioria é restrita à região selecionada.
- **Escopo da conta de faturamento:** vinculados à conta de faturamento específica.
- **Irreversibilidade:** não é possível cancelar.
- **Sem modificações:** não é possível diminuir o valor, mudar região ou prazo.
- **Tempo de ativação:**
  - Comprado de :00 a :49: começa no início da próxima hora.
  - Comprado de :50 a :59: pula uma hora e começa no início da hora seguinte.

## Mudanças no programa CUD (Migração)

- Faturamento simplificado usando preços com desconto diretamente.
- Maior flexibilidade no escopo de alguns CUDs.
- Adição de Modelos de Consumo.
- Cobertura de produtos expandida.
- Exibição de economias diretas na fatura.
- SKUs de taxa de CUD simplificadas (US$ 1/hora).
- Valor do compromisso na compra agora é o preço com desconto.
- Nova exportação de metadados para o BigQuery.

### Determinar qualquer ação necessária

- **Para usuários do BigQuery:** atualizar sistemas internos (painéis FinOps) que dependem do esquema de dados anterior.
- **Para usuários da API Cloud Commerce Consumer Procurement:** atualizar código que automatiza compras de CUDs para usar os novos nomes de ofertas e valores.