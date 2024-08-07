-- Task 10: Create SafeDiv function to safely divide
DELIMITER //

CREATE FUNCTION SafeDiv(a INT, b INT) 
RETURNS FLOAT
DETERMINISTIC
BEGIN
    RETURN IF(b = 0, 0, a / b);
END //

DELIMITER ;
