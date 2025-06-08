-- Initializes the ibkr_data database schema for IBKR pipeline

-- Create schema
CREATE SCHEMA IF NOT EXISTS ib_schema;

-- Table: realtime_forex
CREATE TABLE IF NOT EXISTS ib_schema.realtime_forex (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL,
    open NUMERIC,
    high NUMERIC,
    low NUMERIC,
    close NUMERIC,
    volume NUMERIC,
    equity TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_forex_time ON ib_schema.realtime_forex(timestamp);
CREATE INDEX IF NOT EXISTS idx_forex_equity ON ib_schema.realtime_forex(equity);

-- Table: strategy_positions
CREATE TABLE IF NOT EXISTS ib_schema.strategy_positions (
    id SERIAL PRIMARY KEY,
    equity TEXT NOT NULL,
    date_start TIMESTAMPTZ,
    date_end TIMESTAMPTZ,
    phase INTEGER,
    pos_type TEXT
);
CREATE INDEX IF NOT EXISTS idx_positions_equity ON ib_schema.strategy_positions(equity);
CREATE INDEX IF NOT EXISTS idx_positions_type ON ib_schema.strategy_positions(pos_type);

-- Table: trade_log
CREATE TABLE IF NOT EXISTS ib_schema.trade_log (
    id SERIAL PRIMARY KEY,
    side TEXT,
    time TIMESTAMPTZ,
    price NUMERIC,
    commission NUMERIC
);
CREATE INDEX IF NOT EXISTS idx_trade_time ON ib_schema.trade_log(time);
CREATE INDEX IF NOT EXISTS idx_trade_side ON ib_schema.trade_log(side);
