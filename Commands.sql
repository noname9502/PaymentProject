-- Enable UUID Extension (PostgreSQL)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create ENUM Types for PostgreSQL
CREATE TYPE role_enum AS ENUM ('customer', 'admin', 'support');
CREATE TYPE transaction_type_enum AS ENUM ('payment', 'refund');
CREATE TYPE status_enum AS ENUM ('pending', 'completed', 'failed');
CREATE TYPE method_enum AS ENUM ('credit_card', 'bank_account');

-- Users Table (Renamed from User to Users)
CREATE TABLE Users (
    UserID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Username VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Salt VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE,
    Role role_enum DEFAULT 'customer',
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to Auto-Update `UpdatedAt` on Users Table
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.UpdatedAt = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_users_updated_at
BEFORE UPDATE ON Users
FOR EACH ROW
EXECUTE FUNCTION update_users_updated_at();

-- Merchant Table
CREATE TABLE Merchant (
    MerchantID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15) UNIQUE,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger for `UpdatedAt` in Merchant Table
CREATE TRIGGER trigger_merchant_updated_at
BEFORE UPDATE ON Merchant
FOR EACH ROW
EXECUTE FUNCTION update_users_updated_at();

-- Account Balance Ledger
CREATE TABLE AccountBalance (
    BalanceID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    UserID UUID NULL,
    MerchantID UUID NULL,
    Balance DECIMAL(18, 4) DEFAULT 0.0000,
    Currency VARCHAR(10) DEFAULT 'USD',
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (MerchantID) REFERENCES Merchant(MerchantID) ON DELETE CASCADE,
    UNIQUE (UserID, MerchantID)
);

-- Transaction Table
CREATE TABLE Transaction (
    TransactionID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    UserID UUID NOT NULL,
    MerchantID UUID NOT NULL,
    Amount DECIMAL(18, 4) NOT NULL,
    Currency VARCHAR(10) DEFAULT 'USD',
    TransactionType transaction_type_enum NOT NULL,
    Status status_enum DEFAULT 'pending',
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (MerchantID) REFERENCES Merchant(MerchantID) ON DELETE CASCADE
);

-- Payment Method Table
CREATE TABLE PaymentMethod (
    PaymentMethodID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    UserID UUID NOT NULL,
    MethodType method_enum NOT NULL,
    Details TEXT NOT NULL, -- Encrypt this field in the application level
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Transaction Log Table
CREATE TABLE TransactionLog (
    LogID UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    TransactionID UUID NOT NULL,
    Event VARCHAR(255) NOT NULL,
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (TransactionID) REFERENCES Transaction(TransactionID) ON DELETE CASCADE
);

-- Indexing for Performance Optimization
CREATE INDEX idx_users_email ON Users (Email);
CREATE INDEX idx_merchant_email ON Merchant (Email);
CREATE INDEX idx_transaction_status ON Transaction (Status);
CREATE INDEX idx_transaction_timestamp ON Transaction (Timestamp);
CREATE INDEX idx_paymentmethod_userid ON PaymentMethod (UserID);



-- Insert Transactions (Fix: Use LIMIT 1)
INSERT INTO Transaction (TransactionID, UserID, MerchantID, Amount, Currency, TransactionType, Status)
VALUES 
(gen_random_uuid(), 
 (SELECT UserID FROM Users WHERE Email = 'john@example.com' LIMIT 1), 
 (SELECT MerchantID FROM Merchant WHERE Name = 'Amazon' LIMIT 1), 
 150.75, 'USD', 'payment', 'completed'),

(gen_random_uuid(), 
 (SELECT UserID FROM Users WHERE Email = 'alice@example.com' LIMIT 1), 
 (SELECT MerchantID FROM Merchant WHERE Name = 'Walmart' LIMIT 1), 
 500.00, 'USD', 'payment', 'pending')
ON CONFLICT DO NOTHING;

-- Insert Payment Methods (Fix: Use LIMIT 1)
INSERT INTO PaymentMethod (PaymentMethodID, UserID, MethodType, Details)
VALUES 
(gen_random_uuid(), (SELECT UserID FROM Users WHERE Email = 'john@example.com' LIMIT 1), 'credit_card', 'EncryptedCardDetails1'),
(gen_random_uuid(), (SELECT UserID FROM Users WHERE Email = 'alice@example.com' LIMIT 1), 'bank_account', 'EncryptedBankDetails2')
ON CONFLICT DO NOTHING;

-- Insert Transaction Logs (Fix: Use LIMIT 1)
INSERT INTO TransactionLog (LogID, TransactionID, Event)
VALUES 
(gen_random_uuid(), (SELECT TransactionID FROM Transaction WHERE Amount = 150.75 LIMIT 1), 'Transaction initiated'),
(gen_random_uuid(), (SELECT TransactionID FROM Transaction WHERE Amount = 150.75 LIMIT 1), 'Transaction completed'),
(gen_random_uuid(), (SELECT TransactionID FROM Transaction WHERE Amount = 500.00 LIMIT 1), 'Transaction initiated')
ON CONFLICT DO NOTHING;
