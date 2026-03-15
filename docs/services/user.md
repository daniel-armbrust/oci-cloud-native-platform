# Service USERS

O serviço users é um serviço REST responsável pelo gerenciamento de usuários do sistema.

Ele permite criar contas, consultar informações de usuários, atualizar dados e remover usuários quando necessário.

# Contexto de Negócio

O sistema precisa permitir que:

- Usuários criem contas
- Usuários atualizem seus dados
- Administradores gerenciem contas
- Administradores removam usuários
- IDs são UUID
- Datas seguem o formato ISO 8601 (UTC)
- Todas as respostas seguem o padrão JSend simplificado
- O email do usuário não pode ser alterado
- O campo role só pode ser alterado por administradores
- A senha deve possuir requisitos mínimos de segurança
- Alterações atualizam o campo `updated_at`

Este serviço será consumido por:

- frontend web
- admin-panel
- auth-service

# REST

## Endpoints Principais

| Método | Endpoint        | Descrição          | Auth  | HTTP Status     | JSend          |
|--------|-----------------|--------------------|-------|-----------------|----------------|
| GET    | /users          | Lista usuários     | Admin | 200             | success        |
| GET    | /users/{id}     | Detalhe do usuário | Sim   | 200 / 404       | success / fail |
| POST   | /users          | Criar novo usuário | Não   | 201 / 400       | success / fail |
| PATCH  | /users/{id}     | Atualizar usuário  | Sim   | 200 / 400 / 404 | success / fail |
| DELETE | /users/{id}     | Remover usuário    | Admin | 200 / 404       | success / fail |

## GET /users

Retorna a lista de usuários cadastrados no sistema.

Este endpoint permite consultar os usuários existentes e suporta paginação para limitar a quantidade de resultados retornados.

### Autenticação

Requer autenticação de administrador.

### Query Parameters

| Parâmetro | Tipo    | Obrigatório | Descrição                                    |
|-----------|---------|-------------|----------------------------------------------|
| page      | integer | Não         | Número da página (default: 1)                |
| limit     | integer | Não         | Quantidade de itens por página (default: 10) |

### Path Parameters

Nenhum.

### Request Body

Este endpoint não possui corpo de requisição (body payload).

### Resposta - 200 OK

Lista de usuários retornada com sucesso.

```json
{
  "status": "success",
  "data": {
    "items": [
      {
        "id": "f19c4f9b-6c0d-4a6a-bb24-8a5a18d8b6f2",
        "name": "Daniel Armbrust",
        "email": "daniel@example.com",
        "role": "user",
        "created_at": "2026-03-05T01:15:00Z"
      },
      {
        "id": "3d1b4a9c-8d2f-4e12-b7a1-5c9e7d0a9123",
        "name": "Admin User",
        "email": "admin@example.com",
        "role": "admin",
        "created_at": "2026-03-04T18:10:00Z"
      }
    ],
    "page": 1,
    "limit": 10,
    "total": 2
  }
}
```

### Resposta - 401 Unauthorized

Usuário não autenticado ou sem permissão para acessar este recurso.

```json
{
  "status": "fail",
  "message": "Unauthorized"
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

## GET /users/{id}

Retorna os detalhes de um usuário específico.

### Autenticação

Requer autenticação.

### Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| id | UUID | Sim | Identificador único do usuário |

### Request Body

Este endpoint não possui corpo de requisição (body payload).

### Resposta - 200 OK

Usuário encontrado e retornado com sucesso.

```json
{
  "status": "success",
  "data": {
    "id": "f19c4f9b-6c0d-4a6a-bb24-8a5a18d8b6f2",
    "name": "Daniel Armbrust",
    "email": "daniel@example.com",
    "role": "user",
    "created_at": "2026-03-05T01:15:00Z",
    "updated_at": "2026-03-05T01:15:00Z"
  }
}
```

### Resposta - 400 Bad Request

Identificador do usuário inválido.

```json
{
  "status": "fail",
  "message": "Invalid UUID format"
}
```

### Resposta - 401 Unauthorized

Usuário não autenticado.

```json
{
  "status": "fail",
  "message": "Unauthorized"
}
```

### Resposta - 404 Not Found

Usuário não encontrado.

```json
{
  "status": "fail",
  "message": "User not found"
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

## POST /users

Cria um novo usuário no sistema.

### Autenticação

Este endpoint não requer autenticação.

### Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

Nenhum.

### Request Body

| Campo    | Tipo   | Obrigatório | Descrição        |
|----------|--------|-------------|------------------|
| name     | string | Sim         | Nome do usuário  |
| email    | string | Sim         | Email do usuário |
| password | string | Sim         | Senha do usuário |

### Exemplo de Request

```json
{
  "name": "Daniel Armbrust",
  "email": "daniel@example.com",
  "password": "strongpassword123"
}
```

### Resposta - 201 Created

Usuário criado com sucesso.

```json
{
  "status": "success",
  "message": "User created successfully",
  "data": {
    "id": "f19c4f9b-6c0d-4a6a-bb24-8a5a18d8b6f2"
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

### Resposta - 409 Conflict

Email já cadastrado.

```json
{
  "status": "fail",
  "message": "User already exists"
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

## PATCH /users/{id}

Atualiza parcialmente os dados de um usuário existente.

Este endpoint permite modificar informações do usuário sem a necessidade de enviar todos os campos.

### Autenticação

Requer autenticação do usuário.

### Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

| Parâmetro | Tipo | Obrigatório | Descrição                      |
|-----------|------|-------------|--------------------------------|
| id        | UUID | Sim         | Identificador único do usuário |

### Request Body

Todos os campos são opcionais. Apenas os campos enviados serão atualizados.

| Campo    | Tipo   | Descrição                            |
|----------|--------|--------------------------------------|
| name     | string | Novo nome do usuário                 |
| password | string | Nova senha                           |
| role     | string | Papel do usuário (`user` ou `admin`) |

### Exemplo de Request

```json
{
  "name": "Daniel A."
}
```

### Resposta - 200 OK

Usuário atualizado com sucesso

```json
{
  "status": "success",
  "data": {
    "id": "f19c4f9b-6c0d-4a6a-bb24-8a5a18d8b6f2",
    "updated_at": "2026-03-05T01:20:00Z"
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

Usuário não autenticado.

```json
{
  "status": "fail",
  "message": "Unauthorized"
}
```

### Resposta - 403 Forbidden

Usuário não autenticado.

```json
{
  "status": "fail",
  "message": "Permission denied"
}
```

### Resposta - 404 Not Found

Usuário não encontrado.

```json
{
  "status": "fail",
  "message": "User not found"
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

## DELETE /users/{id}

Remove um usuário do sistema.

A remoção é realizada por **soft delete**, ou seja, o usuário não é removido fisicamente do banco de dados.  
O registro é marcado como removido para fins de auditoria e histórico.

### Autenticação

Requer autenticação de administrador.

### Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

| Parâmetro | Tipo | Obrigatório | Descrição |
|-----------|------|-------------|-----------|
| id | UUID | Sim | Identificador único do usuário |

### Request Body

Este endpoint não possui corpo de requisição (body payload).

### Resposta - 200 OK

Usuário removido com sucesso.

```json
{
  "status": "success",
  "data": {
    "id": "f19c4f9b-6c0d-4a6a-bb24-8a5a18d8b6f2",
    "deleted": true,
    "deleted_at": "2026-03-05T01:30:00Z"
  }
}
```

### Resposta - 400 Bad Request

Identificador do usuário inválido.

```json
{
  "status": "fail",
  "message": "Invalid UUID format"
}
```

### Resposta - 401 Unauthorized

Usuário não autenticado.

```json
{
  "status": "fail",
  "message": "Unauthorized"
}
```

### Resposta - 403 Forbidden

Usuário não autenticado.

```json
{
  "status": "fail",
  "message": "Permission denied"
}
```

### Resposta - 404 Not Found

Usuário não encontrado.

```json
{
  "status": "fail",
  "message": "User not found"
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