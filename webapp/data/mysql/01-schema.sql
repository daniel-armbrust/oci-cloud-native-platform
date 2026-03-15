-- =========================
-- DATABASE: OCIPIZZA
-- =========================
CREATE DATABASE IF NOT EXISTS ocipizza
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE ocipizza;

-- =========================
-- USERS
-- =========================
-- id
--    Identificador único do usuário (UUID).
--
-- name
--    Nome completo do usuário.
--
-- email
--    Email do usuário utilizado para login no sistema.
--    Deve ser único.
--
-- password_hash
--    Senha do usuário armazenada como hash (ex: bcrypt).
--
-- role
--    Tipo de usuário do sistema.
--    Pode ser:
--      admin -> administrador da pizzaria
--      user  -> cliente que realiza pedidos
--
-- whatsapp
--    Número de WhatsApp utilizado para contato com o cliente.
--
-- active
--    Indica se o usuário está ativo no sistema.
--
-- created_at
--    Data de criação do usuário.
--
-- updated_at
--    Data da última atualização do usuário.
--
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    whatsapp VARCHAR(20),
    active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

-- =========================
-- USER ADDRESSES
-- =========================
-- id
--    Identificador único do endereço (UUID).
--
-- user_id
--    Identificador do usuário dono do endereço.
--
-- street
--    Nome da rua.
--
-- number
--    Número da residência ou prédio.
--
-- complement
--    Complemento do endereço (ex: apartamento, bloco, casa).
--
-- neighborhood
--    Bairro onde o endereço está localizado.
--
-- city
--    Cidade do endereço.
--
-- state
--    Estado do endereço.
--
-- zip_code
--    CEP do endereço.
--
-- is_default
--    Define se este é o endereço padrão do usuário.
--
-- created_at
--    Data de criação do endereço.
--
CREATE TABLE user_addresses (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    street VARCHAR(255) NOT NULL,
    number VARCHAR(20),
    complement VARCHAR(255),
    neighborhood VARCHAR(150),
    city VARCHAR(150),
    state VARCHAR(50),
    zip_code VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =========================
-- DELIVERY ZONES
-- =========================
-- id
--    Identificador único da zona de entrega (UUID).
--
-- name
--    Nome da região de entrega. Pode ser usado para identificar 
--    áreas como "Centro", "Zona Norte", "Mooca", etc.
--
-- city
--    Cidade atendida pela pizzaria.
--
-- state
--    Estado onde a entrega é realizada.
--
-- neighborhood
--    Bairro atendido. Usado para verificar se o endereço do cliente
--    está dentro da área de entrega.
--
-- delivery_fee
--    Taxa de entrega cobrada para essa região.
--
-- active
--    Indica se a zona de entrega está ativa.
--    Se FALSE, o sistema não permitirá pedidos para essa região.
--
CREATE TABLE delivery_zones (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    city VARCHAR(150),
    state VARCHAR(50),
    neighborhood VARCHAR(150),
    delivery_fee DECIMAL(10,2),
    active BOOLEAN DEFAULT TRUE
);

-- =========================
-- ORDERS
-- =========================
-- id
--    Identificador único do pedido (UUID).
--
-- user_id
--    Usuário que realizou o pedido.
--
-- address_id
--    Endereço onde o pedido será entregue.
--
-- status
--    Status atual do pedido.
--    Pode ser:
--      created
--      preparing
--      out_for_delivery
--      delivered
--      cancelled
--
-- total_amount
--    Valor total do pedido.
--
-- created_at
--    Data de criação do pedido.
--
-- updated_at
--    Data da última atualização do pedido.
--
CREATE TABLE orders (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    address_id CHAR(36) NOT NULL,
    
    status ENUM(
        'created',
        'preparing',
        'out_for_delivery',
        'delivered',
        'cancelled'
    ) DEFAULT 'created',

    total_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (address_id) REFERENCES user_addresses(id)
);

-- =========================
-- ORDER ITEMS
-- =========================
-- id
--    Identificador único do item do pedido (UUID).
--
-- order_id
--    Pedido ao qual este item pertence.
--
-- pizza_id
--    Identificador da pizza no catálogo.
--
-- pizza_name
--    Nome da pizza no momento do pedido.
--    Mantido para preservar o histórico.
--
-- size
--    Tamanho da pizza (ex: pequena, média, grande).
--
-- price
--    Preço da pizza no momento do pedido.
--
-- quantity
--    Quantidade de pizzas pedidas.
--
-- created_at
--    Data de criação do item do pedido.
--
CREATE TABLE order_items (
    id CHAR(36) PRIMARY KEY,
    order_id CHAR(36) NOT NULL,
    pizza_id CHAR(36) NOT NULL,
    pizza_name VARCHAR(150),
    size VARCHAR(20),
    price DECIMAL(10,2),
    quantity INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);