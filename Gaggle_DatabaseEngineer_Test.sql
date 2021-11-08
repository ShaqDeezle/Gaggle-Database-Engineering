-- Question 1)

SELECT CONCAT(first_name, " ", last_name) AS "Full Name" FROM customer
WHERE UPPER(first_name) = (SELECT first_name FROM actor
			   WHERE actor_id = 8)

UNION

SELECT CONCAT(first_name, " ", last_name) FROM actor
WHERE actor_id != 8 AND UPPER(first_name) = (SELECT first_name FROM actor
					     WHERE actor_id = 8);



-- Question 2)

ALTER TABLE actor ADD (UUID BINARY(16) UNIQUE);

ALTER TABLE customer ADD (UUID BINARY(16) UNIQUE);

	-- Assigning UUID() as a DEFAULT value won't work because it does not guarantee UNIQUE values.


	/*

	Follow the following steps before executing the UPDATE command in "MySQL Workbench" to avoid getting the Error Code "1175":

	Step 1: Go to Edit --> Preferences
	Step 2: Click "SQL Editor" tab and uncheck "Safe Updates" check box
	Step 3: Click on "Query" Tab at the top --> Reconnect to Server (Or you can logout and then log back in)
	Step 4: Now execute your SQL query.


	Another method you can do instead of following the 4 steps above is to execute: 
	SET SQL_SAFE_UPDATES = 0;

	That should turn off the safety precautions, but make sure to set it back to 1 because it is a good safety precaution.

	*/


UPDATE actor
SET UUID = (UUID_TO_BIN(UUID()));

UPDATE customer
SET UUID = (UUID_TO_BIN(UUID()));

	-- The UUID_TO_BIN() function converts a UUID from a human-readable format (VARCHAR) into a compact format (BINARY) format for storing.

	-- Your column is of the datatype, binary(16), which means UUID data is implicitly converted to binary. Therefore, using UUID_TO_BIN is not needed.


SELECT actor_id, CONCAT(first_name, " ", last_name) AS "Full Name", last_update, BIN_TO_UUID(uuid) as "UUID" FROM actor;

SELECT customer_id, store_id, CONCAT(first_name, " ", last_name) AS "Full Name", email, address_id, active, create_date, last_update, BIN_TO_UUID(uuid) as "UUID" FROM customer;

	-- The BIN_TO_UUID() function converts UUID from the compact format (BINARY) to human-readable format (VARCHAR) for displaying.


DELIMITER #
CREATE TRIGGER insert_uuid_actor
BEFORE INSERT ON actor
FOR EACH  ROW 
BEGIN 
    SET NEW.UUID = (UUID_TO_BIN(UUID()));
END;
#
DELIMITER ;


DELIMITER #
CREATE TRIGGER insert_uuid_customer
BEFORE INSERT ON customer
FOR EACH  ROW 
BEGIN 
    SET NEW.UUID = (UUID_TO_BIN(UUID()));
END;
#
DELIMITER ;



-- Question 3)

	-- There are a few ways to go about doing this. First, you can create a JOIN to display the data:

SELECT CONCAT(cu.first_name, " ", cu.last_name) AS "Full Name", cu.email, cu.address_id FROM customer cu
JOIN address a
ON cu.address_id = a.address_id
JOIN city c
ON a.city_id = c.city_id
JOIN country ct
ON c.country_id = ct.country_id
WHERE ct.country = 'Canada';



	-- You can use the "EXPLAIN" to get tips on how to improve the query:

EXPLAIN (select customer_id, first_name fn, last_name ln, email from customer cu 
where address_id in (select address_id from address a where city_id in (
select city_id from city c where country_id in (select country_id from
country ct where country = 'Canada'))));

	-- After executing this in MySQL Workbench, the "EXPLAIN" suggested using an index on the "country" table to improve the query.


SHOW INDEX FROM country FROM sakila;

	-- I ran the command above to see how many (indexes) and what each of those indexes was on the country table.


CREATE INDEX country_idx ON country (country);

	-- I created an index on the "country" column based on the "EXPLAIN", and wanted to change the "type" for the country table from "ALL" to "ref".



-- Question 4)

	/*
	
	MySQL 8 onwards has new internal/data dictionary functions called "BIN_TO_UUID" and "UUID_TO_BIN". These functions convert the hex, which is a function in MySQL that returns an equivalent hexadecimal string value of a string or numeric input, to binary by using unhex. UNHEX function in MySQL is used to convert the Hexadecimal number into the bytes represented by the number. The value it returns is a binary string, and vice versa, converting it to a hex using the HEX function.
	
	
	However, if you do not have MySQL 8+ or you want to create your own "BIN_TO_UUID" and "UUID_TO_BIN" functions, then you can use the code below:
	
	
	A substitute fill in code for "BIN_TO_UUID" and "UUID_TO_BIN" for MySQL with the swap_flag parameter.
	
	
		-- If swap_flag is 0, the two-argument form is equivalent to the one-argument form. Therefore, the string result is in the same order as the binary argument.

		
		-- If swap_flag is 1, the UUID value is assumed to have its time-low and time-high parts swapped. These parts are swapped back to their original position in the result value.

	
	*/

DELIMITER $$

CREATE FUNCTION BIN_TO_UUID(b BINARY(16), f BOOLEAN)
RETURNS CHAR(36)
DETERMINISTIC
BEGIN
   DECLARE hexStr CHAR(32);
   SET hexStr = HEX(b);
   RETURN LOWER(CONCAT(
        IF(f,SUBSTR(hexStr, 9, 8),SUBSTR(hexStr, 1, 8)), '-',
        IF(f,SUBSTR(hexStr, 5, 4),SUBSTR(hexStr, 9, 4)), '-',
        IF(f,SUBSTR(hexStr, 1, 4),SUBSTR(hexStr, 13, 4)), '-',
        SUBSTR(hexStr, 17, 4), '-',
        SUBSTR(hexStr, 21)
    ));
END$$


CREATE FUNCTION UUID_TO_BIN(uuid CHAR(36), f BOOLEAN)
RETURNS BINARY(16)
DETERMINISTIC
BEGIN
  RETURN UNHEX(CONCAT(
  IF(f,SUBSTRING(uuid, 15, 4),SUBSTRING(uuid, 1, 8)),
  SUBSTRING(uuid, 10, 4),
  IF(f,SUBSTRING(uuid, 1, 8),SUBSTRING(uuid, 15, 4)),
  SUBSTRING(uuid, 20, 4),
  SUBSTRING(uuid, 25))
  );
END$$

DELIMITER ;
