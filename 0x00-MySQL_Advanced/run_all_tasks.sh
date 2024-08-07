#!/bin/bash

# Directory for SQL files
TASKS_DIR="0x00-MySQL_Advanced"

# Create the directory if it doesn't exist
mkdir -p "$TASKS_DIR"

# Task 0: Create the `users` table with unique email
cat > "$TASKS_DIR/0-uniq_users.sql" <<EOF
-- Task 0: Create users table with unique email
CREATE TABLE IF NOT EXISTS users (
    id INT NOT NULL AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255),
    PRIMARY KEY (id)
);
EOF

# Task 1: Create the `users` table with country enumeration
cat > "$TASKS_DIR/1-country_users.sql" <<EOF
-- Task 1: Create users table with country enumeration
CREATE TABLE IF NOT EXISTS users (
    id INT NOT NULL AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(255),
    country ENUM('US', 'CO', 'TN') NOT NULL DEFAULT 'US',
    PRIMARY KEY (id)
);
EOF

# Task 2: Rank country origins of bands by number of fans
cat > "$TASKS_DIR/2-fans.sql" <<EOF
-- Task 2: Rank country origins of bands by number of fans
SELECT origin, nb_fans
FROM bands
ORDER BY nb_fans DESC;
EOF

# Task 3: List all bands with Glam rock as their main style, ranked by longevity
cat > "$TASKS_DIR/3-glam_rock.sql" <<EOF
-- Task 3: List all bands with Glam rock as their main style, ranked by longevity
SELECT band_name, (2022 - formed) AS lifespan
FROM bands
WHERE style = 'Glam rock'
ORDER BY lifespan DESC;
EOF

# Task 4: Create trigger to decrease item quantity after adding a new order
cat > "$TASKS_DIR/4-store.sql" <<EOF
-- Task 4: Trigger to decrease item quantity after adding a new order
DELIMITER //

CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE items
    SET quantity = quantity - NEW.number
    WHERE name = NEW.item_name;
END //

DELIMITER ;
EOF

# Task 5: Create trigger to reset valid_email attribute only when the email changes
cat > "$TASKS_DIR/5-valid_email.sql" <<EOF
-- Task 5: Trigger to reset valid_email attribute only when the email changes
DELIMITER //

CREATE TRIGGER before_user_update
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    IF OLD.email != NEW.email THEN
        SET NEW.valid_email = 0;
    END IF;
END //

DELIMITER ;
EOF

# Task 6: Create stored procedure to add bonus for a student
cat > "$TASKS_DIR/6-bonus.sql" <<EOF
-- Task 6: Stored procedure to add a bonus correction for a student
DELIMITER //

CREATE PROCEDURE AddBonus (
    IN user_id INT,
    IN project_name VARCHAR(255),
    IN score INT
)
BEGIN
    DECLARE project_id INT;

    -- Check if the project exists, otherwise create it
    SET project_id = (SELECT id FROM projects WHERE name = project_name);

    IF project_id IS NULL THEN
        INSERT INTO projects (name) VALUES (project_name);
        SET project_id = LAST_INSERT_ID();
    END IF;

    -- Insert the correction
    INSERT INTO corrections (user_id, project_id, score) VALUES (user_id, project_id, score);
END //

DELIMITER ;
EOF

# Task 7: Create stored procedure to compute average score for a user
cat > "$TASKS_DIR/7-average_score.sql" <<EOF
-- Task 7: Stored procedure to compute and store the average score for a user
DELIMITER //

CREATE PROCEDURE ComputeAverageScoreForUser (
    IN user_id INT
)
BEGIN
    DECLARE avg_score FLOAT;

    -- Calculate the average score
    SELECT AVG(score) INTO avg_score
    FROM corrections
    WHERE user_id = user_id;

    -- Update the user's average score
    UPDATE users
    SET average_score = avg_score
    WHERE id = user_id;
END //

DELIMITER ;
EOF

# Create a README.md file with general project information
cat > "$TASKS_DIR/README.md" <<EOF
# MySQL Advanced Tasks

This repository contains SQL scripts for various advanced MySQL tasks. The tasks include creating tables, triggers, and stored procedures, as well as ranking and processing data.

## Tasks

- **Task 0:** Create a table `users` with a unique email constraint.
- **Task 1:** Create a table `users` with an enumeration for the country field.
- **Task 2:** Rank country origins of bands by the number of fans.
- **Task 3:** List all bands with Glam rock as their main style, ranked by longevity.
- **Task 4:** Create a trigger to decrease item quantity after a new order is added.
- **Task 5:** Create a trigger to reset the `valid_email` attribute when the email changes.
- **Task 6:** Create a stored procedure to add a bonus correction for a student.
- **Task 7:** Create a stored procedure to compute and store the average score for a user.

## Usage

1. Import the SQL scripts into your MySQL database.
2. Execute the scripts as needed to set up your database environment and test the functionality.
EOF

echo "All task SQL files and README.md have been created in the $TASKS_DIR directory."

