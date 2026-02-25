-- Delete all test data first
DELETE FROM kyc_docs;
DELETE FROM users;

-- Insert valid test users
INSERT INTO users (user_id, first_name, last_name, email, phone, date_of_birth, country_code, address_line1, city, postal_code, account_status, risk_level) VALUES
('USR001', 'John', 'Smith', 'john.smith@email.com', '+447700900123', '1985-03-15', 'GBR', '123 Oxford Street', 'London', 'W1D 1BS', 'ACTIVE', 'LOW'),
('USR002', 'Emma', 'Johnson', 'emma.johnson@email.com', '+447700900456', '1990-07-22', 'GBR', '456 Park Lane', 'Manchester', 'M1 1AE', 'ACTIVE', 'LOW'),
('USR003', 'Michael', 'Williams', 'michael.williams@email.com', '+447700900789', '1988-11-30', 'GBR', '789 High Street', 'Birmingham', 'B1 1AA', 'ACTIVE', 'LOW'),
('USR004', 'Sarah', 'Brown', 'sarah.brown@email.com', '+447700900321', '1992-01-18', 'GBR', '321 Queen Street', 'Edinburgh', 'EH2 1JN', 'ACTIVE', 'LOW'),
('USR005', 'David', 'Jones', 'david.jones@email.com', '+447700900654', '1987-05-25', 'GBR', '654 King Street', 'Glasgow', 'G1 1RB', 'ACTIVE', 'MEDIUM'),
('USR006', 'Laura', 'Garcia', 'laura.garcia@email.com', '+34912345678', '1991-09-12', 'ESP', 'Calle Mayor 123', 'Madrid', '28013', 'ACTIVE', 'LOW'),
('USR007', 'Thomas', 'Martinez', 'thomas.martinez@email.com', '+33145678901', '1989-04-08', 'FRA', '45 Rue de Rivoli', 'Paris', '75001', 'ACTIVE', 'LOW'),
('USR008', 'Sophie', 'Anderson', 'sophie.anderson@email.com', '+447700900987', '1993-12-03', 'GBR', '987 Victoria Road', 'Liverpool', 'L1 1JD', 'ACTIVE', 'LOW'),
('USR009', 'James', 'Taylor', 'james.taylor@email.com', '+447700900135', '1986-08-19', 'GBR', '135 Princes Street', 'Bristol', 'BS1 1AA', 'ACTIVE', 'LOW'),
('USR010', 'Olivia', 'Thomas', 'olivia.thomas@email.com', '+447700900246', '1994-02-27', 'GBR', '246 Castle Street', 'Cardiff', 'CF10 1BH', 'ACTIVE', 'LOW'),
('USR011', 'Benjamin', 'Scott', 'benjamin.scott@email.com', '+447700901802', '1986-09-21', 'GBR', '791 Monk Street', 'Winchester', 'SO23 1AA', 'ACTIVE', 'LOW'),
('USR012', 'Chloe', 'Green', 'chloe.green@email.com', '+447700901913', '1992-12-28', 'GBR', '802 Friar Street', 'Norwich', 'NR1 1AA', 'ACTIVE', 'LOW');

-- Insert KYC documents
INSERT INTO kyc_docs (user_id, document_type, document_number, issue_date, expiry_date, issuing_country, verification_status) VALUES
('USR001', 'PASSPORT', 'GB123456789', '2020-01-15', '2030-01-15', 'GBR', 'VERIFIED'),
('USR002', 'NATIONAL_ID', 'ID987654321', '2021-06-20', '2031-06-20', 'GBR', 'VERIFIED'),
('USR003', 'DRIVERS_LICENSE', 'DL456789012', '2019-03-10', '2029-03-10', 'GBR', 'VERIFIED'),
('USR004', 'PASSPORT', 'GB234567890', '2022-05-12', '2032-05-12', 'GBR', 'VERIFIED'),
('USR005', 'NATIONAL_ID', 'ID123456789', '2020-11-08', '2030-11-08', 'GBR', 'VERIFIED'),
('USR006', 'PASSPORT', 'ES234567890', '2021-02-14', '2031-02-14', 'ESP', 'VERIFIED'),
('USR007', 'NATIONAL_ID', 'FR987654321', '2020-09-25', '2030-09-25', 'FRA', 'VERIFIED'),
('USR008', 'PASSPORT', 'GB345678901', '2023-01-18', '2033-01-18', 'GBR', 'VERIFIED'),
('USR009', 'DRIVERS_LICENSE', 'DL567890123', '2021-07-22', '2031-07-22', 'GBR', 'VERIFIED'),
('USR010', 'PASSPORT', 'GB456789012', '2022-11-30', '2032-11-30', 'GBR', 'PENDING'),
('USR011', 'NATIONAL_ID', 'ID234567890', '2020-12-01', '2025-12-01', 'GBR', 'VERIFIED'),
('USR012', 'PASSPORT', 'GB567890123', '2021-08-15', '2026-08-15', 'GBR', 'VERIFIED');
