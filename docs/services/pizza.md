# Aplicação Web - OCI Pizza

# Service PIZZA

O serviço pizza é um serviço REST responsável pelo cardápio da pizzaria. Ele dispõe de informações sobre as pizzas que incluem preço, imagem da pizza, ingredientes, categoria (salgada, doce, vegana) e disponibilidade. 

# Contexto de Negócio

O sistema precisa permitir que:

- Clientes visualizem o cardápio
- Administradores atualizem preços
- Itens sejam ativados/desativados
- Promoções futuras sejam adicionadas
- IDs são UUID
- Datas seguem o formato ISO 8601 (UTC)
- Todas as respostas seguem o padrão JSend simplificado

Este serviço será consumido por:

- frontend web
- admin-panel

# REST

## Endpoints Principais

| Método | Endpoint     | Descrição                    | Auth  | HTTP Status     | JSend          |
|--------|--------------|------------------------------|-------|-----------------|----------------|
| GET    | /pizzas      | Lista pizzas                 | Não   | 200             | success        |
| GET    | /pizzas/{id} | Detalhe da pizza             | Não   | 200 / 404       | success / fail |
| POST   | /pizzas      | Criar nova pizza             | Admin | 201 / 400       | success / fail |
| PATCH  | /pizzas/{id} | Atualizar pizza              | Admin | 200 / 400 / 404 | success / fail |
| DELETE | /pizzas/{id} | Desativar pizza (soft delete)| Admin | 200 / 404       | success / fail |

## Health & Observabilidade

| Método | Endpoint  | Descrição            | HTTP Status |
|--------|-----------|----------------------|-------------|
| GET    | /health   | Liveness check       | 200         |
| GET    | /ready    | Readiness check      | 200         |
| GET    | /metrics  | Métricas Prometheus  | 200         |

## GET /pizzas

Retorna a lista de pizzas disponíveis no cardápio.

Este endpoint permite consultar todas as pizzas cadastradas no sistema.  
Os resultados podem ser filtrados por categoria, disponibilidade ou tamanho, e suportam paginação.

### Autenticação

Este endpoint não requer autenticação.

### Query Parameters

| Parâmetro  | Tipo     | Obrigatório | Descrição                     |
|------------|----------|------------|--------------------------------|
| category   | string   | Não        | Filtrar por categoria          |
| available  | boolean  | Não        | Filtrar disponibilidade        |
| size       | string   | Não        | Filtrar por tamanho            |
| page       | integer  | Não        | Página (default: 1)            |
| limit      | integer  | Não        | Itens por página (default: 10) |

### Path Parameters

Nenhum.

### Request Body

Este endpoint não possui corpo de requisição (body payload).

### Resposta - 200 OK

Retorna a lista de pizzas.

```json
{
  "status": "success",
  "data": {
    "items": [
      {
        "id": "8f14e45f-ea9d-4f12-9b3e-9a5b5d4a6c01",
        "name": "Margherita",
        "description": "Molho de tomate, mussarela e manjericão",
        "image_url": "https://cdn.example.com/pizzas/margherita.jpg",
        "category": "salgada",
        "available": true,
        "sizes": [
          {
            "size": "media",
            "price": 42.90
          },
          {
            "size": "grande",
            "price": 52.90
          }
        ]
      },
      {
        "id": "c8a7c3c1-9b6a-4e31-b1e8-6d4a8c9d2a11",
        "name": "Calabresa",
        "description": "Molho de tomate, mussarela, calabresa e cebola",
        "image_url": "https://cdn.example.com/pizzas/margherita.jpg",
        "category": "vegana",
        "available": true,
        "sizes": [
          {
            "size": "media",
            "price": 45.90
          },
          {
            "size": "grande",
            "price": 55.90
          }
        ]
      }
    ],
    "page": 1,
    "limit": 10,
    "total": 25
  }
}
```

Mesmo se não houver pizzas, ainda é 200, com lista vazia.

```json
{
  "status": "success",
  "data": {
    "items": [],
    "page": 1,
    "limit": 10,
    "total": 0
  }
}
```

### Resposta - 400 Bad Request

Quando os query parameters são inválidos, por exemplo:

- page=-1
- limit=0
- available=abc

```json
{
  "status": "fail",
  "message": "Invalid query parameters"
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

## GET /pizzas/{id}

### Autenticação

Este endpoint não requer autenticação.

### Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

| Parâmetro | Tipo | Obrigatório | Descrição                    |
|-----------|------|-------------|------------------------------|
| id        | UUID | Sim         | Identificador único da pizza |

### Request Body

Este endpoint não possui corpo de requisição (body payload).

### Resposta - 200 OK

Pizza encontrada e retornada com sucesso.

```json
{
  "status": "success",
  "data": {
    "id": "8f14e45f-ea9d-4f12-9b3e-9a5b5d4a6c01",
    "name": "Chocolate",
    "description": "Chocolate e morango",
    "image_url": "https://cdn.example.com/pizzas/margherita.jpg",
    "category": "doce",
    "available": true,
    "sizes": [
      {
        "size": "media",
        "price": 42.90
      },
      {
        "size": "grande",
        "price": 52.90
      }
    ],
    "created_at": "2026-03-04T22:15:30Z",
    "updated_at": "2026-03-04T22:15:30Z"
  }
}
```

### Resposta - 400 Bad Request

Identificador da pizza inválido.

```json
{
  "status": "fail",
  "message": "Invalid UUID format"
}
```

### Resposta - 404 Not Found

Pizza não encontrada.

```json
{
  "status": "fail",
  "message": "Pizza not found",
}
```

### Resposta - 500 Internal Server Error

Erro inesperado no servidor.

```json
{
  "status": "fail",
  "message": "Pizza not found",
}
```

## POST /pizzas

Cria uma nova pizza no cardápio.

### Autenticação

Requer autenticação de administrador.

### Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

Nenhum.

### Request Body

| Campo       | Tipo    | Obrigatório | Descrição                         |
|-------------|---------|-------------|-----------------------------------|
| name        | string  | Sim         | Nome da pizza                     |
| description | string  | Sim         | Descrição da pizza                |
| category    | string  | Sim         | Categoria da pizza                |
| available   | boolean | Sim         | Indica se a pizza está disponível |
| sizes       | array   | Sim         | Lista de tamanhos e preços        |

- O nome da pizza deve ser único.
- A pizza deve possuir pelo menos um tamanho.
- O preço deve ser maior que zero.
- A remoção de pizzas é feita por soft delete, alterando available.

### Exemplo de Request

```json
{
  "name": "Calabresa",
  "description": "Molho de tomate, mussarela, calabresa e cebola",
  "image_url": "https://cdn.example.com/pizzas/margherita.jpg",
  "category": "salgada",
  "available": true,
  "sizes": [
    {
      "size": "media",
      "price": 45.90
    },
    {
      "size": "grande",
      "price": 55.90
    }
  ]
}
```

### Resposta - 201 Created

Pizza criada com sucesso.

```json
{
  "status": "success",
  "message": "Pizza created succesful",
  "data": {
    "id": "9c1c5c1e-1a2f-4e8b-8c7a-6d9b5e8a1234"
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

### Resposta - 409 Conflict

Já existe pizza com o mesmo nome.

```json
{
  "status": "fail",
  "message": "Pizza already exists"
}
```

### Resposta - 500 Internal Server Error

Erro inesperado ao processar a solicitação.

```json
{
  "status": "error",
  "message": "Internal server error"
}
```

## PATCH /pizzas/{id}

Atualiza parcialmente os dados de uma pizza existente no cardápio.

### Autenticação

Requer autenticação de administrador.

## Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

| Parâmetro | Tipo | Obrigatório | Descrição              |
|-----------|------|-------------|------------------------|
| id        | UUID | Sim         | Identificador da pizza |

### Request Body

Todos os campos são opcionais. Apenas os campos enviados serão atualizados.

| Campo       | Tipo    | Descrição                           |
|-------------|---------|-------------------------------------|
| name        | string  | Novo nome da pizza                  |
| description | string  | Nova descrição                      |
| category    | string  | Nova categoria                      |
| available   | boolean | Define se a pizza está disponível   |
| sizes       | array   | Atualiza lista de tamanhos e preços |

- `name` deve ser único.
- `price` deve ser maior que zero.
- `sizes` não pode conter tamanhos duplicados.
- Uma pizza deve possuir pelo menos um tamanho.
- Alterações são registradas atualizando `updated_at`.

### Exemplo de Request

```json
{
  "description": "Molho de tomate, mussarela, calabresa artesanal e cebola roxa",
  "sizes": [
    {
      "size": "media",
      "price": 47.90
    },
    {
      "size": "grande",
      "price": 57.90
    }
  ]
}
```

### Resposta - 200 OK

Pizza atualizada com sucesso.

```json
{
  "status": "success",
  "data": {
    "id": "c8a7c3c1-9b6a-4e31-b1e8-6d4a8c9d2a11",
    "updated_at": "2026-03-04T22:45:00Z"
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

### Resposta - 404 Not Found

Pizza não encontrada.

```json
{
  "status": "fail",
  "message": "Pizza not found"
}
```

### Resposta - 409 Conflict

Conflito com o estado atual do recurso.

```json
{
  "status": "fail",
  "message": "Pizza name already exists"
}
```

### Resposta - 500 Internal Server Error

Erro inesperado ao processar a solicitação.

```json
{
  "status": "error",
  "message": "Internal server error"
}
```

## DELETE /pizzas/{id}

Este endpoint realiza **remoção lógica (soft delete)** da pizza.  
A pizza não é removida fisicamente do banco de dados; em vez disso, o campo `available` é definido como `false`.

- A remoção é feita por soft delete.
- O campo available é definido como false.
- A pizza permanece no banco de dados para fins históricos.
- A data `updated_at` deve ser atualizada.

### Autenticação

Requer autenticação de administrador.

## Query Parameters

Este endpoint não possui parâmetros de consulta.

### Path Parameters

| Parâmetro | Tipo | Obrigatório | Descrição              |
|-----------|------|-------------|------------------------|
| id        | UUID | Sim         | Identificador da pizza |

### Request Body

Este endpoint não possui corpo de requisição (body payload).

### Resposta - 200 OK

Pizza removida com sucesso.

```json
{
  "status": "success",
  "data": {
    "id": "c8a7c3c1-9b6a-4e31-b1e8-6d4a8c9d2a11",
    "available": false,
    "updated_at": "2026-03-04T23:40:12Z"
  }
}
```

### Resposta - 400 Bad Request

Identificador da pizza inválido.

```json
{
  "status": "fail",
  "message": "Invalid UUID format"
}
```

### Resposta - 401 — Unauthorized

Usuário não autenticado.

```json
{
  "status": "fail",
  "message": "Unauthorized"
}
```

### Resposta - 404 Not Found

Pizza não encontrada.

```json
{
  "status": "fail",
  "message": "Pizza not found"
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