-- Test2B.sql (Oracle SQL)
-- Creates and populates CUSTOMER, ORDERS, PRODUCT tables for Practical Test 2B

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE LINEITEM PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE ORDERS PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE CUSTOMER PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE PRODUCT PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE CUSTOMER (
  custID        NUMBER(3)    PRIMARY KEY,
  name          VARCHAR2(50) NOT NULL,
  phone         VARCHAR2(20),
  address       VARCHAR2(80),
  city          VARCHAR2(30),
  state         VARCHAR2(30),
  country       VARCHAR2(30),
  zipcode       VARCHAR2(10),
  creditRating  VARCHAR2(10) CHECK (creditRating IN ('GOOD','FAIR','POOR')),
  comments      VARCHAR2(100)
);

CREATE TABLE PRODUCT (
  productID     NUMBER(3)    PRIMARY KEY,
  productName   VARCHAR2(50) NOT NULL,
  description   VARCHAR2(120),
  costPrice     NUMBER(8,2)  NOT NULL CHECK (costPrice >= 0),
  sellPrice     NUMBER(8,2)  NOT NULL CHECK (sellPrice >= 0)
);

CREATE TABLE ORDERS (
  orderID       NUMBER(4)    PRIMARY KEY,
  custID        NUMBER(3)    NOT NULL,
  dateOrdered   DATE         NOT NULL,
  dateShipped   DATE,
  paymentType   VARCHAR2(10) CHECK (paymentType IN ('CASH','CREDIT')),
  CONSTRAINT fk_orders_cust FOREIGN KEY (custID) REFERENCES CUSTOMER(custID)
);

-- Insert CUSTOMER
INSERT INTO CUSTOMER VALUES (501, 'Aina Rahman', '013-5551234', '12 Jalan Bakti', 'Serdang', 'Selangor', 'Malaysia', '43400', 'GOOD', 'Frequent buyer');
INSERT INTO CUSTOMER VALUES (502, 'Bryan Lim', '012-3337788', '8 Jalan Mutiara', 'Kajang', 'Selangor', 'Malaysia', '43000', 'FAIR', 'Prefers online payment');
INSERT INTO CUSTOMER VALUES (503, 'Chong Mei', '017-8881122', '20 Jalan Kenanga', 'Bangi', 'Selangor', 'Malaysia', '43650', 'POOR', 'Late payment history');
INSERT INTO CUSTOMER VALUES (504, 'Deepa Nair', '019-2223344', '55 Jalan Taming', 'Shah Alam', 'Selangor', 'Malaysia', '40100', 'GOOD', '—');
INSERT INTO CUSTOMER VALUES (505, 'Ehsan Idris', '016-9090909', '3 Lorong Seroja', 'Putrajaya', 'W.P. Putrajaya', 'Malaysia', '62000', 'POOR', 'Credit hold');
INSERT INTO CUSTOMER VALUES (506, 'Farah Zulkifli', '011-7778899', '99 Jalan Lestari', 'Cyberjaya', 'Selangor', 'Malaysia', '63000', 'FAIR', 'New customer');

-- Insert PRODUCT
INSERT INTO PRODUCT VALUES (301, 'Outdoor Boots', 'Waterproof boots for trekking', 120.00, 189.00);
INSERT INTO PRODUCT VALUES (302, 'Snooze Sleeping Bag', 'Lightweight sleeping bag (3-season)', 95.00, 149.00);
INSERT INTO PRODUCT VALUES (303, 'Mountain Tent', '2-person tent with rainfly', 210.00, 329.00);
INSERT INTO PRODUCT VALUES (304, 'Hiking Pole', 'Adjustable pole (pair)', 45.00, 79.00);
INSERT INTO PRODUCT VALUES (305, 'Sun Hat', 'UV-protection hat', 18.00, 35.00);
INSERT INTO PRODUCT VALUES (306, 'Rain Jacket', 'Breathable rain jacket', 80.00, 129.00);

-- Insert ORDERS
INSERT INTO ORDERS VALUES (1001, 501, TO_DATE('2025-10-10','YYYY-MM-DD'), TO_DATE('2025-10-12','YYYY-MM-DD'), 'CASH');
INSERT INTO ORDERS VALUES (1002, 503, TO_DATE('2025-10-11','YYYY-MM-DD'), TO_DATE('2025-10-13','YYYY-MM-DD'), 'CREDIT');
INSERT INTO ORDERS VALUES (1003, 502, TO_DATE('2025-10-11','YYYY-MM-DD'), TO_DATE('2025-10-14','YYYY-MM-DD'), 'CREDIT');
INSERT INTO ORDERS VALUES (1004, 505, TO_DATE('2025-10-12','YYYY-MM-DD'), NULL, 'CREDIT');
INSERT INTO ORDERS VALUES (1005, 504, TO_DATE('2025-10-13','YYYY-MM-DD'), TO_DATE('2025-10-15','YYYY-MM-DD'), 'CASH');
INSERT INTO ORDERS VALUES (1006, 506, TO_DATE('2025-10-14','YYYY-MM-DD'), TO_DATE('2025-10-16','YYYY-MM-DD'), 'CASH');

COMMIT;