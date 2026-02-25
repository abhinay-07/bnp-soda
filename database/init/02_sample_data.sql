-- ============================================
-- KYC Data Quality Platform - Sample Data
-- Includes intentional data quality issues
-- ============================================

-- ============================================
-- USERS TABLE - Sample Data
-- ============================================

-- Valid users
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

-- ISSUE: Underage users (< 18 years old) - Data Quality Issue #1
('USR011', 'Oliver', 'Young', 'oliver.young@email.com', '+447700900357', '2010-06-15', 'GBR', '357 Market Street', 'Leeds', 'LS1 1AA', 'PENDING', 'HIGH'),
('USR012', 'Amelia', 'Walker', 'amelia.walker@email.com', '+447700900468', '2008-11-22', 'GBR', '468 George Street', 'Newcastle', 'NE1 1AA', 'PENDING', 'HIGH'),
('USR013', 'Harry', 'Robinson', 'harry.robinson@email.com', '+447700900579', '2012-03-08', 'GBR', '579 Duke Street', 'Sheffield', 'S1 1AA', 'PENDING', 'HIGH'),

-- ISSUE: Invalid email formats - Data Quality Issue #2
('USR014', 'Isabella', 'White', 'isabella.white.invalid', '+447700900680', '1990-05-10', 'GBR', '680 Earl Street', 'Nottingham', 'NG1 1AA', 'PENDING', 'MEDIUM'),
('USR015', 'Jack', 'Harris', 'jack@harris@email..com', '+447700900791', '1988-09-17', 'GBR', '791 Baron Street', 'Leicester', 'LE1 1AA', 'PENDING', 'MEDIUM'),
('USR016', 'Mia', 'Martin', 'mia.martin@', '+447700900802', '1991-12-24', 'GBR', '802 Knight Street', 'Derby', 'DE1 1AA', 'PENDING', 'MEDIUM'),

-- ISSUE: Invalid phone formats - Data Quality Issue #3
('USR017', 'Charlie', 'Thompson', 'charlie.thompson@email.com', '12345', '1989-07-05', 'GBR', '913 Bishop Street', 'Plymouth', 'PL1 1AA', 'PENDING', 'MEDIUM'),
('USR018', 'Ella', 'Moore', 'ella.moore@email.com', 'INVALID_PHONE', '1992-10-14', 'GBR', '024 Archbishop Street', 'Southampton', 'SO14 1AA', 'PENDING', 'MEDIUM'),
('USR019', 'George', 'Jackson', 'george.jackson@email.com', '+44-ABC-DEF-GHI', '1987-01-28', 'GBR', '135 Dean Street', 'Portsmouth', 'PO1 1AA', 'PENDING', 'MEDIUM'),

-- ISSUE: Duplicate user IDs - Data Quality Issue #4
('USR020', 'Grace', 'Lee', 'grace.lee@email.com', '+447700901357', '1990-04-16', 'GBR', '246 Canon Street', 'Coventry', 'CV1 1AA', 'ACTIVE', 'LOW'),
('USR020', 'Lucas', 'Hall', 'lucas.hall@email.com', '+447700901468', '1988-08-23', 'GBR', '357 Vicar Street', 'York', 'YO1 1AA', 'PENDING', 'HIGH'),

-- ISSUE: NULL critical fields - Data Quality Issue #5
('USR021', 'Lily', 'Allen', 'lily.allen@email.com', NULL, '1991-11-30', 'GBR', '468 Rector Street', 'Bath', 'BA1 1AA', 'ACTIVE', 'MEDIUM'),
('USR022', 'Oscar', 'King', NULL, '+447700901680', '1989-02-07', 'GBR', '579 Abbot Street', 'Cambridge', 'CB1 1AA', 'PENDING', 'MEDIUM'),
('USR023', NULL, 'Wright', 'alice.wright@email.com', '+447700901791', '1993-05-14', 'GBR', '680 Prior Street', 'Oxford', 'OX1 1AA', 'PENDING', 'MEDIUM'),

-- Additional valid users for volume
('USR024', 'Benjamin', 'Scott', 'benjamin.scott@email.com', '+447700901802', '1986-09-21', 'GBR', '791 Monk Street', 'Winchester', 'SO23 1AA', 'ACTIVE', 'LOW'),
('USR025', 'Chloe', 'Green', 'chloe.green@email.com', '+447700901913', '1992-12-28', 'GBR', '802 Friar Street', 'Norwich', 'NR1 1AA', 'ACTIVE', 'LOW'),
('USR026', 'Daniel', 'Adams', 'daniel.adams@email.com', '+447700902024', '1988-03-06', 'GBR', '913 Parson Street', 'Exeter', 'EX1 1AA', 'ACTIVE', 'LOW'),
('USR027', 'Emily', 'Baker', 'emily.baker@email.com', '+447700902135', '1990-06-13', 'GBR', '024 Chaplain Street', 'Canterbury', 'CT1 1AA', 'ACTIVE', 'LOW'),
('USR028', 'Ethan', 'Nelson', 'ethan.nelson@email.com', '+447700902246', '1987-09-20', 'GBR', '135 Curate Street', 'Durham', 'DH1 1AA', 'ACTIVE', 'MEDIUM'),
('USR029', 'Freya', 'Carter', 'freya.carter@email.com', '+447700902357', '1991-12-27', 'GBR', '246 Sexton Street', 'Lancaster', 'LA1 1AA', 'ACTIVE', 'LOW'),
('USR030', 'Henry', 'Mitchell', 'henry.mitchell@email.com', '+447700902468', '1989-04-04', 'GBR', '357 Deacon Street', 'Chester', 'CH1 1AA', 'ACTIVE', 'LOW'),

-- ISSUE: Suspicious/High-risk users - Data Quality Issue #6
('USR031', 'Ivan', 'Petrov', 'ivan.petrov@email.com', '+74951234567', '1980-01-01', 'RUS', 'Red Square 1', 'Moscow', '101000', 'SUSPENDED', 'HIGH'),
('USR032', 'Viktor', 'Sokolov', 'viktor.sokolov@email.com', '+74951234568', '1975-02-02', 'RUS', 'Tverskaya Street 2', 'Moscow', '101001', 'SUSPENDED', 'HIGH'),

-- Additional valid users for better data distribution
('USR033', 'Jessica', 'Perez', 'jessica.perez@email.com', '+447700903024', '1993-07-11', 'GBR', '468 Market Place', 'Salisbury', 'SP1 1AA', 'ACTIVE', 'LOW'),
('USR034', 'Joshua', 'Roberts', 'joshua.roberts@email.com', '+447700903135', '1988-10-18', 'GBR', '579 The Square', 'Truro', 'TR1 1AA', 'ACTIVE', 'LOW'),
('USR035', 'Katie', 'Turner', 'katie.turner@email.com', '+447700903246', '1991-01-25', 'GBR', '680 Church Street', 'Hereford', 'HR1 1AA', 'ACTIVE', 'LOW'),
('USR036', 'Liam', 'Phillips', 'liam.phillips@email.com', '+447700903357', '1987-04-02', 'GBR', '791 Bridge Street', 'Worcester', 'WR1 1AA', 'ACTIVE', 'LOW'),
('USR037', 'Madison', 'Campbell', 'madison.campbell@email.com', '+447700903468', '1992-07-09', 'GBR', '802 Station Road', 'Gloucester', 'GL1 1AA', 'ACTIVE', 'MEDIUM'),
('USR038', 'Mason', 'Parker', 'mason.parker@email.com', '+447700903579', '1989-10-16', 'GBR', '913 North Street', 'Chichester', 'PO19 1AA', 'ACTIVE', 'LOW'),
('USR039', 'Natalie', 'Evans', 'natalie.evans@email.com', '+447700903680', '1990-01-23', 'GBR', '024 South Street', 'Ipswich', 'IP1 1AA', 'ACTIVE', 'LOW'),
('USR040', 'Noah', 'Edwards', 'noah.edwards@email.com', '+447700903791', '1988-04-30', 'GBR', '135 East Street', 'Lincoln', 'LN1 1AA', 'ACTIVE', 'LOW');

-- ============================================
-- KYC_DOCS TABLE - Sample Data
-- ============================================

-- Valid documents
INSERT INTO kyc_docs (user_id, document_type, document_number, issue_date, expiry_date, issuing_country, verification_status) VALUES
('USR001', 'PASSPORT', 'GBR123456789', '2020-01-15', '2030-01-15', 'GBR', 'VERIFIED'),
('USR001', 'UTILITY_BILL', 'UB-001-2024', '2024-01-01', NULL, 'GBR', 'VERIFIED'),
('USR002', 'NATIONAL_ID', 'GBR987654321', '2019-05-20', '2029-05-20', 'GBR', 'VERIFIED'),
('USR003', 'DRIVERS_LICENSE', 'DL-GBR-001234', '2018-08-10', '2028-08-10', 'GBR', 'VERIFIED'),
('USR004', 'PASSPORT', 'GBR234567890', '2021-03-12', '2031-03-12', 'GBR', 'VERIFIED'),
('USR005', 'NATIONAL_ID', 'GBR876543210', '2019-11-25', '2029-11-25', 'GBR', 'VERIFIED'),
('USR006', 'PASSPORT', 'ESP123456789', '2020-06-18', '2030-06-18', 'ESP', 'VERIFIED'),
('USR007', 'PASSPORT', 'FRA123456789', '2021-09-22', '2031-09-22', 'FRA', 'VERIFIED'),
('USR008', 'NATIONAL_ID', 'GBR765432109', '2020-02-14', '2030-02-14', 'GBR', 'VERIFIED'),
('USR009', 'DRIVERS_LICENSE', 'DL-GBR-002345', '2019-07-30', '2029-07-30', 'GBR', 'VERIFIED'),
('USR010', 'PASSPORT', 'GBR345678901', '2020-10-05', '2030-10-05', 'GBR', 'VERIFIED'),

-- ISSUE: Expired documents - Data Quality Issue #7
('USR011', 'PASSPORT', 'GBR456789012', '2014-01-20', '2024-01-20', 'GBR', 'EXPIRED'),
('USR012', 'NATIONAL_ID', 'GBR654321098', '2013-04-15', '2023-04-15', 'GBR', 'EXPIRED'),
('USR013', 'DRIVERS_LICENSE', 'DL-GBR-003456', '2012-07-10', '2022-07-10', 'GBR', 'EXPIRED'),

-- ISSUE: Missing documents for some users - Data Quality Issue #8
-- Users USR014, USR015, USR016 have NO documents (referential integrity issue)

-- Pending verification documents
('USR017', 'PASSPORT', 'GBR567890123', '2024-01-01', '2034-01-01', 'GBR', 'PENDING'),
('USR018', 'NATIONAL_ID', 'GBR543210987', '2024-02-01', '2034-02-01', 'GBR', 'PENDING'),
('USR019', 'DRIVERS_LICENSE', 'DL-GBR-004567', '2024-03-01', '2034-03-01', 'GBR', 'PENDING'),

-- Duplicate documents for same user
('USR020', 'PASSPORT', 'GBR678901234', '2021-05-15', '2031-05-15', 'GBR', 'VERIFIED'),
('USR020', 'NATIONAL_ID', 'GBR432109876', '2020-08-20', '2030-08-20', 'GBR', 'VERIFIED'),
('USR020', 'DRIVERS_LICENSE', 'DL-GBR-005678', '2019-11-25', '2029-11-25', 'GBR', 'VERIFIED'),

-- Documents for users with missing info
('USR021', 'PASSPORT', 'GBR789012345', '2020-12-10', '2030-12-10', 'GBR', 'VERIFIED'),
('USR022', 'NATIONAL_ID', 'GBR321098765', '2021-03-15', '2031-03-15', 'GBR', 'VERIFIED'),

-- Additional valid documents
('USR024', 'PASSPORT', 'GBR890123456', '2021-06-20', '2031-06-20', 'GBR', 'VERIFIED'),
('USR025', 'NATIONAL_ID', 'GBR210987654', '2020-09-25', '2030-09-25', 'GBR', 'VERIFIED'),
('USR026', 'DRIVERS_LICENSE', 'DL-GBR-006789', '2019-12-30', '2029-12-30', 'GBR', 'VERIFIED'),
('USR027', 'PASSPORT', 'GBR901234567', '2021-03-05', '2031-03-05', 'GBR', 'VERIFIED'),
('USR028', 'NATIONAL_ID', 'GBR109876543', '2020-06-10', '2030-06-10', 'GBR', 'VERIFIED'),
('USR029', 'DRIVERS_LICENSE', 'DL-GBR-007890', '2019-09-15', '2029-09-15', 'GBR', 'VERIFIED'),
('USR030', 'PASSPORT', 'GBR012345678', '2021-12-20', '2031-12-20', 'GBR', 'VERIFIED'),

-- High-risk users documents
('USR031', 'PASSPORT', 'RUS123456789', '2015-01-01', '2025-01-01', 'RUS', 'REJECTED'),
('USR032', 'PASSPORT', 'RUS987654321', '2016-02-02', '2026-02-02', 'RUS', 'REJECTED'),

-- Additional valid documents
('USR033', 'NATIONAL_ID', 'GBR098765432', '2020-03-25', '2030-03-25', 'GBR', 'VERIFIED'),
('USR034', 'PASSPORT', 'GBR987654320', '2021-06-30', '2031-06-30', 'GBR', 'VERIFIED'),
('USR035', 'DRIVERS_LICENSE', 'DL-GBR-008901', '2019-09-05', '2029-09-05', 'GBR', 'VERIFIED'),
('USR036', 'PASSPORT', 'GBR876543219', '2020-12-10', '2030-12-10', 'GBR', 'VERIFIED'),
('USR037', 'NATIONAL_ID', 'GBR765432108', '2021-03-15', '2031-03-15', 'GBR', 'VERIFIED'),
('USR038', 'DRIVERS_LICENSE', 'DL-GBR-009012', '2019-06-20', '2029-06-20', 'GBR', 'VERIFIED'),
('USR039', 'PASSPORT', 'GBR654321097', '2020-09-25', '2030-09-25', 'GBR', 'VERIFIED'),
('USR040', 'NATIONAL_ID', 'GBR543210986', '2021-12-30', '2031-12-30', 'GBR', 'VERIFIED');

-- ============================================
-- SUMMARY OF INTENTIONAL DATA QUALITY ISSUES
-- ============================================

-- Issue #1: Underage users (USR011, USR012, USR013) - age < 18
-- Issue #2: Invalid email formats (USR014, USR015, USR016)
-- Issue #3: Invalid phone formats (USR017, USR018, USR019)
-- Issue #4: Duplicate user IDs (USR020 appears twice)
-- Issue #5: NULL critical fields (USR021, USR022, USR023)
-- Issue #6: High-risk suspended users (USR031, USR032)
-- Issue #7: Expired documents (USR011, USR012, USR013)
-- Issue #8: Users without documents (USR014, USR015, USR016)

-- ============================================
-- COMMIT TRANSACTION
-- ============================================

-- Display summary
DO $$
DECLARE
    user_count INTEGER;
    doc_count INTEGER;
    issue_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users;
    SELECT COUNT(*) INTO doc_count FROM kyc_docs;
    
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Sample data loaded successfully!';
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Total users inserted: %', user_count;
    RAISE NOTICE 'Total documents inserted: %', doc_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Intentional Data Quality Issues:';
    RAISE NOTICE '- Underage users: 3';
    RAISE NOTICE '- Invalid emails: 3';
    RAISE NOTICE '- Invalid phones: 3';
    RAISE NOTICE '- Duplicate user IDs: 1';
    RAISE NOTICE '- NULL critical fields: 3';
    RAISE NOTICE '- High-risk users: 2';
    RAISE NOTICE '- Expired documents: 3';
    RAISE NOTICE '- Users without documents: 3';
    RAISE NOTICE '===========================================';
    RAISE NOTICE 'Total issues to be detected by Soda: ~21';
    RAISE NOTICE '===========================================';
END $$;
