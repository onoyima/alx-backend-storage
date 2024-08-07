#!/bin/bash

# Ensure the script is running from the correct directory
if [ "$(basename "$PWD")" != "0x00-MySQL_Advanced" ]; then
    echo "Please run this script from the '0x00-MySQL_Advanced' directory."
    exit 1
fi

# Define the SQL files for tasks 8 through 14
tasks=(
    "8-index_my_names.sql"
    "9-index_name_score.sql"
    "10-div.sql"
    "11-need_meeting.sql"
    "100-average_weighted_score.sql"
    "101-average_weighted_score.sql"
)

# Create SQL files for each task
for task in "${tasks[@]}"; do
    echo "Creating $task..."

    case $task in
        "8-index_my_names.sql")
            cat <<EOF > $task
-- Task 08: Create an index on the first letter of name
CREATE INDEX idx_name_first ON names (LEFT(name, 1));
EOF
            ;;
        "9-index_name_score.sql")
            cat <<EOF > $task
-- Task 09: Create an index on the first letter of name and score
CREATE INDEX idx_name_first_score ON names (LEFT(name, 1), score);
EOF
            ;;
        "10-div.sql")
            cat <<EOF > $task
-- Task 10: Create SafeDiv function to safely divide
DELIMITER //

CREATE FUNCTION SafeDiv(a INT, b INT) 
RETURNS FLOAT
DETERMINISTIC
BEGIN
    RETURN IF(b = 0, 0, a / b);
END //

DELIMITER ;
EOF
            ;;
        "11-need_meeting.sql")
            cat <<EOF > $task
-- Task 11: Create view for students needing a meeting
CREATE VIEW need_meeting AS
SELECT name
FROM students
WHERE score < 80
AND (last_meeting IS NULL OR last_meeting < CURDATE() - INTERVAL 1 MONTH);
EOF
            ;;
        "100-average_weighted_score.sql")
            cat <<EOF > $task
-- Task 12: Create ComputeAverageWeightedScoreForUser procedure
DELIMITER //

CREATE PROCEDURE ComputeAverageWeightedScoreForUser(IN user_id INT)
BEGIN
    DECLARE weighted_score FLOAT;
    SELECT SUM(score * weight) / SUM(weight) INTO weighted_score
    FROM corrections c
    JOIN projects p ON c.project_id = p.id
    WHERE c.user_id = user_id;
    UPDATE users SET average_score = weighted_score WHERE id = user_id;
END //

DELIMITER ;
EOF
            ;;
        "101-average_weighted_score.sql")
            cat <<EOF > $task
-- Task 13: Create ComputeAverageWeightedScoreForUsers procedure
DELIMITER //

CREATE PROCEDURE ComputeAverageWeightedScoreForUsers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE user_id INT;
    DECLARE cur CURSOR FOR SELECT id FROM users;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO user_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        CALL ComputeAverageWeightedScoreForUser(user_id);
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;
EOF
            ;;
    esac

    echo "$task created."
done

echo "All remaining task files have been created."

