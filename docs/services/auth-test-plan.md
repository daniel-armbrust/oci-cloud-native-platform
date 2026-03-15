# Plano de Testes - Serviço Auth

## 1. Objetivo
Validar que o serviço `auth` autentica usuários, emite e renova JWTs corretamente, aplica regras de revogação/logout e expõe sinais de saúde/observabilidade com comportamento estável em cenários de sucesso, erro e abuso.

## 2. Escopo
Incluído:
- `POST /auth`
- `POST /auth/refresh`
- `POST /auth/logout`
- `GET /health`
- `GET /ready`
- `GET /metrics`
- Integração com MySQL (usuários) e Redis (store/revogação de tokens)

Fora de escopo:
- Telas frontend
- Autorização de outros microserviços consumidores do JWT
- Hardening de infraestrutura (WAF, IAM, rede)

## 3. Estratégia de Testes
- Testes funcionais de API (caixa-preta) por endpoint.
- Testes de integração (MySQL/Redis) para readiness, login, refresh e logout.
- Testes de segurança focados em JWT inválido, expirado, malformado e replay de refresh.
- Testes de resiliência para indisponibilidade parcial (MySQL/Redis).
- Regressão mínima automatizada em pipeline.

## 4. Ambiente e Pré-requisitos
Ambiente mínimo:
- Serviço `auth-service` em execução.
- Banco MySQL com usuário admin ativo (`admin@ocipizza.com`).
- Redis disponível.

Variáveis relevantes:
- `JWT_SECRET`
- `JWT_ACCESS_TTL` (default: 3600)
- `JWT_REFRESH_TTL` (default: 604800)

Dados de teste sugeridos:
- Usuário válido ativo: `admin@ocipizza.com` / `admin123`.
- Usuário inexistente.
- Usuário inativo (se disponível no banco para teste).

## 5. Critérios de Entrada e Saída
Critérios de entrada:
- Containers `mysql`, `redis` e `auth-service` com status `Up`.
- Seed de dados concluída.

Critérios de saída:
- 100% dos cenários críticos aprovados (P0 e P1).
- Sem falhas abertas em autenticação, emissão de token e logout.
- Endpoints de saúde e métricas operacionais.

## 6. Casos de Teste Funcionais

### 6.1 `POST /auth`
1. Login com credenciais válidas.
- Esperado: `200`, `status=success`, presença de `access_token`, `refresh_token`, `token_type=Bearer`, `expires_in`.

2. Login com senha inválida.
- Esperado: `401`, `status=fail`, mensagem de credenciais inválidas.

3. Login com email inexistente.
- Esperado: `401`, `status=fail`.

4. Payload inválido (sem `password`, sem `email`, JSON malformado).
- Esperado: `400`, `status=fail`, `Invalid request payload`.

5. Usuário inativo.
- Esperado: `401`, `status=fail`.

### 6.2 `POST /auth/refresh`
1. Refresh com token válido do tipo `refresh`.
- Esperado: `200`, `status=success`, novo `access_token`.

2. Refresh com token de acesso no campo `refresh_token`.
- Esperado: `401`, `status=fail`.

3. Refresh com token malformado/assinatura inválida.
- Esperado: `401`, `status=fail`.

4. Refresh com token expirado.
- Esperado: `401`, `status=fail`.

5. Refresh com token revogado.
- Esperado: `401`, `status=fail`.

6. Refresh com token não presente no store (replay ou token desconhecido).
- Esperado: `401`, `status=fail`.

### 6.3 `POST /auth/logout`
1. Logout com `Authorization: Bearer <access_token>` válido.
- Esperado: `200`, `status=success`.

2. Logout com `refresh_token` válido no body.
- Esperado: `200`, `status=success`.

3. Logout com access token inválido.
- Esperado: `401`, `status=fail`.

4. Logout com refresh token inválido.
- Esperado: `401`, `status=fail`.

5. Logout sem token (idempotência básica).
- Esperado: `200`, `status=success`.

### 6.4 Saúde e observabilidade
1. `GET /health` com serviço ativo.
- Esperado: `200`, `status=success`, `data.status=ok`.

2. `GET /ready` com MySQL e Redis disponíveis.
- Esperado: `200`, `status=success`, `data.status=ready`.

3. `GET /ready` com MySQL indisponível.
- Esperado: `503`, `status=fail`, `Database unavailable`.

4. `GET /ready` com Redis indisponível.
- Esperado: `503`, `status=fail`, `Redis unavailable`.

5. `GET /metrics`.
- Esperado: `200`, `Content-Type` Prometheus e métricas incluindo:
  - `auth_login_success_total`
  - `auth_login_fail_total`
  - `auth_refresh_success_total`
  - `auth_refresh_fail_total`
  - `auth_logout_total`

## 7. Casos de Segurança (JWT)
1. Validar claim `type` (`access` vs `refresh`) em fluxos corretos.
2. Validar expiração (`exp`) com TTL curto em ambiente de teste.
3. Validar revogação por `jti` após logout.
4. Verificar que alteração de payload quebra assinatura.
5. Verificar rejeição de token com formato inválido (`a.b`, `abc`).

## 8. Testes Não Funcionais
1. Carga leve: 50-100 logins concorrentes por 1-3 minutos.
- Meta: taxa de erro < 1% sem degradação severa.

2. Latência de login (`POST /auth`).
- Meta inicial: p95 < 300 ms em ambiente local controlado.

3. Estabilidade de readiness.
- Meta: respostas consistentes durante reinício de dependências.

## 9. Priorização
P0 (bloqueantes):
- Login válido/inválido.
- Refresh válido/inválido.
- Logout revogando token.
- `health` e `ready`.

P1 (alta):
- Expiração de token.
- Token malformado/assinatura inválida.
- Métricas principais.

P2 (média):
- Carga leve e medições de latência.

## 10. Automação Recomendada
- Suite API com `pytest` + `httpx` (ou `requests`) para fluxos principais.
- Fixtures para:
  - criar usuário de teste;
  - autenticar e retornar tokens;
  - limpar/revogar chaves no Redis.
- Execução em CI:
  - subir `mysql`, `redis` e `auth-service`;
  - rodar suíte P0/P1 em cada PR;
  - rodar P2 em rotina diária/noturna.

## 10.1 Implementação Atual (P0)
- Arquivo de testes automatizados P0:
  - `webapp/services/auth/tests/test_auth_p0.py`
- Dependências de desenvolvimento:
  - `webapp/services/auth/requirements-dev.txt`
- Comando sugerido:
  - `PYTHONPATH=/app pytest -q tests/test_auth_p0.py`

## 11. Riscos e Mitigações
- Risco: dados de teste instáveis no banco.
- Mitigação: seed determinística e limpeza por execução.

- Risco: falso positivo por ambiente local sem isolamento.
- Mitigação: executar testes em containers efêmeros no CI.

- Risco: dependência de relógio para expiração JWT.
- Mitigação: usar TTL curto e margem de tempo controlada nos testes.

## 12. Evidências
Para cada execução, registrar:
- data/hora;
- commit/hash testado;
- ambiente;
- casos executados e status;
- logs e payloads de falha;
- métricas coletadas (quando aplicável).
