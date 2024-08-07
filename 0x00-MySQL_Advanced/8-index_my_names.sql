-- Task 08: Create an index on the first letter of name
CREATE INDEX idx_name_first ON names (LEFT(name, 1));
