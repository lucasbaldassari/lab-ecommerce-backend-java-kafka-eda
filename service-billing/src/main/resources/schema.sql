CREATE SCHEMA IF NOT EXISTS billing_service;

SET search_path TO billing_service, public;

CREATE TABLE IF NOT EXISTS payment (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    amount DECIMAL(19, 2) NOT NULL CHECK (amount >= 0),
    method VARCHAR(50) NOT NULL,
    installments SMALLINT NOT NULL DEFAULT 1 CHECK (installments > 0),
    status VARCHAR(50) NOT NULL,
    error_code VARCHAR(100),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payment_history_order_id ON payment(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_history_customer_id ON payment(customer_id);
CREATE INDEX IF NOT EXISTS idx_payment_history_method ON payment(method);
CREATE INDEX IF NOT EXISTS idx_payment_history_status ON payment(status);
CREATE INDEX IF NOT EXISTS idx_payment_history_error_code ON payment(error_code);
CREATE INDEX IF NOT EXISTS idx_payment_history_created_at ON payment(created_at);

CREATE TABLE IF NOT EXISTS payment_history (
    id UUID PRIMARY KEY,
    payment_id UUID NOT NULL,
    status VARCHAR(50) NOT NULL,
    error_code VARCHAR(100),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_history_payment_id FOREIGN KEY (payment_id) REFERENCES payment(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_payment_history_payment_id ON payment_history(payment_id);

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
