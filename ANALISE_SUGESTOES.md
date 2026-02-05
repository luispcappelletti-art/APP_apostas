# Análise do APP_apostas e sugestões de evolução

Este documento consolida uma análise técnica e de produto do app atual, com foco em segurança, manutenção, performance e novas funcionalidades.

## 1) Pontos críticos (prioridade alta)

1. **Remover segredos hardcoded no código**
   - A chave do Gemini está exposta no código-fonte em mais de um ponto.
   - Recomendação: mover para configuração segura (backend/proxy + variável de ambiente) e rotacionar a chave atual.

2. **Substituir login por PIN hardcoded por autenticação real**
   - O login atual valida uma senha fixa simples.
   - Recomendação: PIN com hash local + biometria (LocalAuthentication) e opção de bloqueio por tentativas.

3. **Quebrar o arquivo monolítico em módulos**
   - O app está concentrado em um único arquivo muito grande.
   - Recomendação: separar por feature (`apostas/`, `dashboard/`, `investimentos/`, `crypto/`, etc.) + `services/` + `models/`.

4. **Criar camada de dados com versionamento/migração**
   - Persistência em JSON sem contrato de versão centralizado aumenta risco de quebra em upgrades.
   - Recomendação: adotar banco local (Isar/SQLite/Hive) com migrações e repositórios.

## 2) Melhorias de engenharia

1. **Gerenciamento de estado**
   - Há muitas chamadas diretas de `setState` ao longo das telas.
   - Sugestão: migrar gradualmente para Riverpod/Bloc para reduzir acoplamento e efeitos colaterais.

2. **Validação e tipagem dos dados**
   - Existem muitos `Map<String, dynamic>` com cast manual.
   - Sugestão: modelos tipados (`freezed` + `json_serializable`) e validações no parsing.

3. **Qualidade e manutenção**
   - Remover imports duplicados e código obsoleto.
   - Configurar `analysis_options.yaml` com lint rigoroso.
   - Adicionar testes unitários para métricas de apostas (ROI, drawdown, winrate, EV).

4. **Confiabilidade de IO/backup**
   - Padronizar fluxo de backup/restore com checksum e validação pré-importação.
   - Incluir log de auditoria para importações e ações destrutivas.

## 3) Melhorias de UX e produto

1. **Onboarding e organização de navegação**
   - Estruturar melhor os menus, agrupando funcionalidades por domínio.
   - Adicionar onboarding curto para explicar fluxo de cadastro e leitura dos gráficos.

2. **Filtros e busca avançada**
   - Salvar filtros favoritos e preset por estratégia.
   - Permitir comparação de períodos e estratégias lado a lado.

3. **Alertas e rotina operacional**
   - Alertas locais: banca abaixo de limite, sequência de perdas, metas diárias/semanais.
   - Checklist pré-aposta para reduzir viés emocional.

4. **Modo consultivo com IA (mais seguro)**
   - Melhorar prompts com contexto estruturado e rastreabilidade das recomendações.
   - Registrar “motivo da entrada” e comparar previsão vs. resultado real.

## 4) Novas funcionalidades sugeridas

1. **Módulo de gestão de banca por estratégia**
   - Banca segmentada por mercado (escanteios, gols, etc.).
   - Regra de stake automática (flat, Kelly fracionado, stake adaptativa por confiança).

2. **Score de qualidade por aposta**
   - Criar um score composto por: EV, confiança histórica, risco do mercado e liquidez percebida.
   - Exibir score no momento de registrar aposta.

3. **Diagnóstico de performance por contexto**
   - Performance por faixa de odd, campeonato, horário, tipo de mercado e casa/fora.
   - Detecção automática de “zonas ruins” (quando parar de operar uma estratégia).

4. **Planejamento financeiro integrado**
   - Conectar resultados de apostas com metas pessoais (reserva, investimentos, despesas).
   - Simulador de cenário (otimista, base, estresse) para projeção mensal.

## 5) Roadmap recomendado (90 dias)

- **Fase 1 (Semanas 1-3):** segurança e arquitetura mínima (segredos, autenticação, modularização inicial).
- **Fase 2 (Semanas 4-7):** camada de dados tipada + testes de cálculo + backup robusto.
- **Fase 3 (Semanas 8-10):** UX/filtros avançados + score de qualidade.
- **Fase 4 (Semanas 11-12):** IA consultiva auditável + ajustes finais com métricas.

## 6) Indicadores para medir evolução

- Crash-free rate.
- Tempo médio para registrar uma aposta.
- Taxa de uso de filtros/relatórios.
- Quantidade de erros em importação/backup.
- Acurácia do score vs resultado real.
- Retenção semanal de uso do app.
