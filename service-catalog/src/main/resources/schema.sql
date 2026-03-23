CREATE SCHEMA IF NOT EXISTS catalog_service;

SET search_path TO catalog_service, public;

CREATE TABLE IF NOT EXISTS product (
    id UUID PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    price DECIMAL(9,2) NOT NULL CHECK (price >= 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_product_title ON product(title);
CREATE INDEX IF NOT EXISTS idx_product_created_at ON product(created_at);

CREATE TABLE IF NOT EXISTS inventory (
    id UUID PRIMARY KEY,
    product_id UUID NOT NULL UNIQUE,
    quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES product(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_inventory_product_id ON inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_created_at ON inventory(created_at);

CREATE TABLE IF NOT EXISTS inventory_movement (
    id UUID PRIMARY KEY,
    inventory_id UUID NOT NULL,
    order_id UUID,
    quantity INT NOT NULL,
    type VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_inventory_movement_inventory FOREIGN KEY (inventory_id) REFERENCES inventory(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_inventory_movement_inventory_id ON inventory_movement(inventory_id);
CREATE INDEX IF NOT EXISTS idx_inventory_movement_order_id ON inventory_movement(order_id);
CREATE INDEX IF NOT EXISTS idx_inventory_movement_created_at ON inventory_movement(created_at);

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
