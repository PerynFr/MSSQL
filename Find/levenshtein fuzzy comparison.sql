CREATE FUNCTION ufn_levenshtein(@s1 nvarchar(3999), @s2 nvarchar(3999))
RETURNS int
AS
BEGIN
DECLARE @s1_len int, @s2_len int
DECLARE @i int, @j int, @s1_char nchar, @c int, @c_temp int
DECLARE @cv0 varbinary(8000), @cv1 varbinary(8000)

SELECT
@s1_len = LEN(@s1),
@s2_len = LEN(@s2),
@cv1 = 0x0000,
@j = 1, @i = 1, @c = 0

WHILE @j <= @s2_len
SELECT @cv1 = @cv1 + CAST(@j AS binary(2)), @j = @j + 1

WHILE @i <= @s1_len
BEGIN
SELECT
@s1_char = SUBSTRING(@s1, @i, 1),
@c = @i,
@cv0 = CAST(@i AS binary(2)),
@j = 1

WHILE @j <= @s2_len
BEGIN
SET @c = @c + 1
SET @c_temp = CAST(SUBSTRING(@cv1, @j+@j-1, 2) AS int) +
CASE WHEN @s1_char = SUBSTRING(@s2, @j, 1) THEN 0 ELSE 1 END
IF @c > @c_temp SET @c = @c_temp
SET @c_temp = CAST(SUBSTRING(@cv1, @j+@j+1, 2) AS int)+1
IF @c > @c_temp SET @c = @c_temp
SELECT @cv0 = @cv0 + CAST(@c AS binary(2)), @j = @j + 1
END

SELECT @cv1 = @cv0, @i = @i + 1
END

RETURN @c
END;




IF OBJECT_ID('ExistingCustomers') IS NOT NULL
DROP TABLE ExistingCustomers;

CREATE TABLE ExistingCustomers
(
    Customer VARCHAR(255),
    ID INT
);

INSERT ExistingCustomers SELECT 'Eds Barbershop', 1002;
INSERT ExistingCustomers SELECT 'GroceryTown', 1003;
INSERT ExistingCustomers SELECT 'Candy Place', 1004;
INSERT ExistingCustomers SELECT 'Handy Man', 1005;
INSERT ExistingCustomers SELECT 'Александр', 1006;



IF OBJECT_ID('POTENTIALCUSTOMERS') IS NOT NULL
DROP TABLE POTENTIALCUSTOMERS;

CREATE TABLE POTENTIALCUSTOMERS(Customer VARCHAR(255));

INSERT POTENTIALCUSTOMERS SELECT 'Eds Barbershop';
INSERT POTENTIALCUSTOMERS SELECT 'Grocery Town';
INSERT POTENTIALCUSTOMERS SELECT 'Candy Place';
INSERT POTENTIALCUSTOMERS SELECT 'Handee Man';
INSERT POTENTIALCUSTOMERS SELECT 'The Apple Farm';
INSERT POTENTIALCUSTOMERS SELECT 'Ride-a-Long Bikes';
INSERT POTENTIALCUSTOMERS SELECT 'Алехандер';


SELECT A.Customer,
b.ID,
b.Customer as cust,
dbo.ufn_levenshtein(REPLACE(A.Customer, ' ', ''), REPLACE(B.Customer, ' ', '')) as ValueLev
FROM POTENTIALCUSTOMERS a
LEFT JOIN ExistingCustomers b ON dbo.ufn_levenshtein(REPLACE(A.Customer, ' ', ''), REPLACE(B.Customer, ' ', '')) < 15;

WITH CTE(RowNbr,Customer,ID,cust,ValueLev) AS
(
    SELECT RANK() OVER (PARTITION BY a.Customer ORDER BY dbo.ufn_levenshtein(REPLACE(A.Customer, ' ', ''), REPLACE(B.Customer, ' ', '')) ASC) AS RowNbr,
    A.Customer,
    b.ID,
    b.Customer as cust,
    dbo.ufn_levenshtein(REPLACE(A.Customer, ' ', ''), REPLACE(B.Customer, ' ', '')) as ValueLev
    FROM POTENTIALCUSTOMERS a
    LEFT JOIN ExistingCustomers b ON dbo.ufn_levenshtein(REPLACE(A.Customer, ' ', ''), REPLACE(B.Customer, ' ', '')) < 15
)
SELECT Customer,
MIN(ID) AS ID,
MIN(cust) AS cust,
ValueLev
FROM CTE
WHERE CTE.RowNbr = 1
GROUP BY Customer, ValueLev;
