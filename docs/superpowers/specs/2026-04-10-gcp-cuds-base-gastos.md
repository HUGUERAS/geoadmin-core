# Notas Internas — CUDs com Base em Gastos (GCP)

> **Fonte oficial:** [Descontos por Compromisso de Uso com base em gastos — Google Cloud](https://cloud.google.com/billing/docs/how-to/cud-spend-based)

## Resumo de Decisão (GeoAdmin)

Contexto de avaliação: verificar viabilidade de CUDs para reduzir custo de Cloud Run
e SQL conforme o uso do produto cresce.

### Pontos-chave para a decisão

- CUDs com base em gastos aplicam desconto em troca de um **gasto mínimo por hora** comprometido.
- São **irreversíveis**: uma vez comprado, não é possível cancelar ou reduzir o valor.
- Produtos relevantes para o GeoAdmin: **Cloud Run**, **Cloud SQL**, **GKE** (se adotado).
- Compromisso é por região e por conta de faturamento.

### Quando faz sentido para o GeoAdmin

| Condição | Ação recomendada |
| :--- | :--- |
| Uso de Cloud Run/SQL previsível e estável por ≥ 1 ano | Avaliar CUD de 1 ano |
| Uso ainda irregular (fase de crescimento) | Manter sob demanda — evitar lock-in |
| Saving estimado > 15% do custo atual | Priorizar avaliação formal |

### Próximo passo

Antes de comprar qualquer CUD, consolidar 3 meses de dados de faturamento no
BigQuery via **Billing Export** e calcular a taxa de utilização real.

Consulte a documentação oficial para o procedimento de compra, verificação de
descontos e métricas de eficácia dos CUDs após a migração para o novo modelo de consumo.
