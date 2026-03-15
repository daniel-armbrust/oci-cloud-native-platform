# Service AUTH

O serviço auth é um serviço REST responsável pela autenticação e emissão de tokens de acesso da aplicação.

Ele permite que usuários se autentiquem no sistema e obtenham um token JWT que será utilizado para acessar endpoints protegidos da API.

# Contexto de Negócio

O sistema precisa permitir que:

- Usuários façam login na aplicação
- Tokens de acesso sejam emitidos após autenticação
- Serviços validem o token para autorizar requisições
- Sessões possam ser renovadas no futuro

- IDs são UUID
- Datas seguem o formato ISO 8601 (UTC)
- Todas as respostas seguem o padrão JSend simplificado

Este serviço será consumido por:

- frontend web
- admin-panel
- microserviços internos

# REST

## Endpoints Principais

| Método | Endpoint | Descrição        | Auth | HTTP Status     | JSend          |
|--------|----------|------------------|------|-----------------|----------------|
| POST   | /auth    | Autenticar usuário | Não  | 200 / 401       | success / fail |

## Health & Observabilidade

| Método | Endpoint  | Descrição           | HTTP Status |
|--------|-----------|---------------------|-------------|
| GET    | /health   | Liveness check      | 200         |
| GET    | /ready    | Readiness check     | 200         |
| GET    | /metrics  | Métricas Prometheus | 200         |

## POST /auth

Autentica um usuário no sistema e retorna um token de acesso.

### Autenticação

Este endpoint não requer autenticação.

### Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

Nenhum.

### Request Body

| Campo    | Tipo   | Obrigatório | Descrição        |
|----------|--------|-------------|------------------|
| email    | string | Sim         | Email do usuário |
| password | string | Sim         | Senha do usuário |

### Exemplo de Request

```json
{
  "email": "admin@example.com",
  "password": "secret123"
}
```

### Resposta - 200 OK

Usuário autenticado com sucesso.

```json
{
  "status": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600
  }
}
```

### Resposta - 400 Bad Request

Dados submetidos são inválidos.

```json
{
  "status": "fail",
  "message": "Invalid request payload"
}
```

### Resposta - 401 Unauthorized

Credenciais inválidas.

```json
{
  "status": "fail",
  "message": "Invalid email or password"
}
```

### Resposta - 500 Internal Server Error

Erro inesperado no servidor.

```json
{
  "status": "error",
  "message": "Internal server error"
}
```

## POST /auth/logout

Realiza o logout do usuário autenticado.

Este endpoint invalida o token de autenticação atual, encerrando a sessão do usuário.

### Autenticação

Requer autenticação do usuário.

### Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

Nenhum.

### Request Body

Este endpoint não requer corpo de requisição (body payload).

### Resposta - 200 OK

Logout realizado com sucesso.

```json
{
  "status": "success",
  "message": "Logout successful"
}
```

### Resposta - 401 Unauthorized

Credenciais inválidas.

```json
{
  "status": "fail",
  "message": "Invalid email or password"
}
```

### Resposta - 500 Internal Server Error

Erro inesperado no servidor.

```json
{
  "status": "error",
  "message": "Internal server error"
}
```

## POST /auth/refresh

Gera um novo token de acesso utilizando um refresh token válido.

Este endpoint permite renovar o token de autenticação sem exigir que o usuário realize login novamente.

### Autenticação

Não requer autenticação.

### Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

Nenhum.

### Request Body

| Campo         | Tipo   | Obrigatório | Descrição                          |
|---------------|--------|-------------|------------------------------------|
| refresh_token | string | Sim         | Token de atualização da sessão     |

### Exemplo de Request

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Resposta - 200 OK

Novo token de acesso gerado com sucesso.

```json
{
  "status": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600
  }
}
```

### Resposta - 400 Bad Request

Refresh token inválido ou ausente.

```json
{
  "status": "fail",
  "message": "Invalid refresh token"
}
```

### Resposta - 401 Unauthorized

Refresh token expirado ou revogado.

```json
{
  "status": "fail",
  "message": "Refresh token expired"
}
```

### Resposta - 500 Internal Server Error

Erro inesperado no servidor.

```json
{
  "status": "error",
  "message": "Internal server error"
}
```