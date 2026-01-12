/* 
   TRIGGER: trg_OrderLineProcessing
   Event: BEFORE INSERT on OrderLines
   Purpose: 
   1. Automatically calculates ExtendedLineTotal (Quantity * Price).
   2. Checks if sufficient stock exists in Parts table.
   3. Updates inventory (deducts stock) upon successful order.
*/
CREATE OR REPLACE TRIGGER trg_OrderLineProcessing
BEFORE INSERT ON OrderLines
FOR EACH ROW
DECLARE
    v_CurrentStock NUMBER;
BEGIN
    -- 1. Retrieve current stock level for the requested part
    SELECT QuantityOnHand INTO v_CurrentStock
    FROM Parts
    WHERE PartID = :NEW.PartID;

    -- 2. Rigorous Check: Prevent order if stock is insufficient
    IF v_CurrentStock < :NEW.Quantity THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Insufficient Inventory: Current stock (' || v_CurrentStock || 
            ') is less than requested quantity (' || :NEW.Quantity || ').');
    END IF;

    -- 3. Auto-Calculate Line Total [Source: 19]
    :NEW.ExtendedLineTotal := :NEW.Quantity * :NEW.ListPrice;

    -- 4. Update Inventory: Deduct the ordered quantity from stock
    UPDATE Parts
    SET QuantityOnHand = QuantityOnHand - :NEW.Quantity
    WHERE PartID = :NEW.PartID;
END;
/

/* 
   PROCEDURE: prc_PlaceWholesaleOrder
   Purpose: Streamlines order creation for Wholesale Customers.
   Logic: Validates customer type, retrieves their discount, creates order header.
*/
CREATE OR REPLACE PROCEDURE prc_PlaceWholesaleOrder (
    p_OrderNumber IN NUMBER,
    p_CustomerID  IN NUMBER,
    p_SalesRepID  IN NUMBER,
    p_ShipAddr    IN VARCHAR2,
    p_BillAddr    IN VARCHAR2
)
IS
    v_CustomerType VARCHAR2(20);
    v_DiscountRate NUMBER;
BEGIN
    -- 1. Validation: Ensure Customer exists and is a 'Wholesale' type
    BEGIN
        SELECT CustomerType INTO v_CustomerType 
        FROM Customers WHERE CustomerID = p_CustomerID;
        
        IF v_CustomerType <> 'Wholesale' THEN
            RAISE_APPLICATION_ERROR(-20002, 'Violation: Customer ' || p_CustomerID || ' is not a Wholesale client.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Error: Customer ID ' || p_CustomerID || ' does not exist.');
    END;

    -- 2. Retrieve the specific discount percentage for this wholesale client [Source: 29]
    SELECT DiscountPercentage INTO v_DiscountRate
    FROM WholesaleCustomers WHERE CustomerID = p_CustomerID;

    -- 3. Create the Order Header
    INSERT INTO Orders (
        OrderNumber, CustomerID, SalesRepID, ShippingAddress, BillingAddress, 
        OrderStatus, OrderDate
    ) VALUES (
        p_OrderNumber, p_CustomerID, p_SalesRepID, p_ShipAddr, p_BillAddr, 
        'Open', SYSDATE
    );

    -- 4. Output Confirmation for logging
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Wholesale Order #' || p_OrderNumber || ' created.');
    DBMS_OUTPUT.PUT_LINE('Client ID: ' || p_CustomerID || ' | Applied Discount: ' || (v_DiscountRate * 100) || '%');

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('TRANSACTION FAILED: ' || SQLERRM);
END;
/

-- SET ENVIRONMENT
SET SERVEROUTPUT ON;

PROMPT TEST SCENARIO EXECUTION LOG

-- STEP 1: PREPARE DUMMY DATA
-- Create Department, Employee (Sales), Customer (Wholesale), and Part
INSERT INTO Departments (DeptName) VALUES ('Sales');
INSERT INTO Employees (EmployeeID, Name, EmployeeType, DeptID) VALUES (901, 'Jane Sales', 'Sales', 1);
INSERT INTO SalesRepresentatives (EmployeeID, CommissionRate) VALUES (901, 0.05);

-- Create a Wholesale Customer with 20% Discount
INSERT INTO Customers (CustomerID, Name, CustomerType) VALUES (500, 'AutoParts Global', 'Wholesale');
INSERT INTO WholesaleCustomers (CustomerID, DiscountPercentage) VALUES (500, 0.20);

-- Create a Part with 10 units in stock
INSERT INTO Parts (PartID, Description, UnitPrice, QuantityOnHand) VALUES (888, 'V8 Engine Block', 5000.00, 10);
COMMIT;

PROMPT [INFO] Data Preparation Complete.

-- STEP 2: TEST STORED PROCEDURE (Success Case)
PROMPT 
PROMPT [TEST 1] Executing Stored Procedure for Wholesale Order...
EXEC prc_PlaceWholesaleOrder(7001, 500, 901, 'Warehouse A', 'HQ Billing');

-- STEP 3: TEST TRIGGER (Success Case)
PROMPT 
PROMPT [TEST 2] Inserting Order Line (Buying 2 units)...
-- Note: ExtendedLineTotal is omitted to prove Trigger calculates it.
INSERT INTO OrderLines (OrderNumber, PartID, Quantity, ListPrice) VALUES (7001, 888, 2, 5000.00);

-- Verification Query
SELECT PartID, Quantity, ExtendedLineTotal FROM OrderLines WHERE OrderNumber = 7001;
SELECT QuantityOnHand AS "Remaining Stock (Should be 8)" FROM Parts WHERE PartID = 888;

-- STEP 4: TEST TRIGGER (Failure Case - Business Rule Enforcement)
PROMPT 
PROMPT [TEST 3] Attempting to overdraw inventory (Buying 100 units)...
BEGIN
    INSERT INTO OrderLines (OrderNumber, PartID, Quantity, ListPrice) VALUES (7001, 888, 100, 5000.00);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXPECTED ERROR CAUGHT: ' || SQLERRM);
END;
/

PROMPT END OF TEST
