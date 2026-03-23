CREATE SCHEMA IF NOT EXISTS order_service;

SET search_path TO order_service, public;

CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL,
    status VARCHAR(50) NOT NULL,
    total_quantity SMALLINT NOT NULL CHECK (total_quantity > 0),
    total_amount DECIMAL(9,2) NOT NULL CHECK (total_amount >= 0),
    payment_method VARCHAR(50) NOT NULL,
    payment_installments SMALLINT NOT NULL DEFAULT 1 CHECK (payment_installments > 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_order_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_order_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_created_at ON orders(created_at);

CREATE TABLE IF NOT EXISTS order_item (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    title VARCHAR(200) NOT NULL,
    price DECIMAL(9,2) NOT NULL CHECK (price >= 0),
    quantity SMALLINT NOT NULL CHECK (quantity > 0),
    amount DECIMAL(9,2) NOT NULL CHECK (amount >= 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_item_order_id FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_order_item_order_id ON order_item(order_id);

CREATE TABLE IF NOT EXISTS order_status_history (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL,
    status VARCHAR(50) NOT NULL,
    comments TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_status_history_order_id FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON order_status_history(order_id);

CREATE TABLE IF NOT EXISTS saga (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL UNIQUE,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_saga_order_id FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_saga_order_id ON saga(order_id);
CREATE INDEX IF NOT EXISTS idx_saga_status ON saga(status);
CREATE INDEX IF NOT EXISTS idx_saga_created_at ON saga(created_at);

CREATE TABLE IF NOT EXISTS saga_status_history (
    id UUID PRIMARY KEY,
    saga_id UUID NOT NULL,
    status VARCHAR(50) NOT NULL,
    comments TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_saga_status_history_saga_id FOREIGN KEY (saga_id) REFERENCES saga(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_saga_status_history_saga_id ON saga_status_history(saga_id);

CREATE TABLE IF NOT EXISTS infra_inbox (
    message_id UUID PRIMARY KEY,
    event VARCHAR(100) NOT NULL,
    processed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_infra_inbox_processed_at ON infra_inbox (processed_at);

CREATE TABLE IF NOT EXISTS infra_outbox (
    id UUID PRIMARY KEY,
    topic_name VARCHAR(100) NOT NULL,
    partition_key VARCHAR(100) NOT NULL,
    event VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    correlation_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_infra_outbox_pending_relay ON infra_outbox (created_at ASC) WHERE status = 'PENDING';
