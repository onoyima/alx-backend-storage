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
