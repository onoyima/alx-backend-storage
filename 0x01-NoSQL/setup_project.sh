#!/bin/bash

# Create the root directory for the project
mkdir -p alx-backend-storage/0x01-NoSQL
cd alx-backend-storage/0x01-NoSQL || exit

# Create the MongoDB command files with comments and newlines
files=("0-list_databases" "1-use_or_create_database" "2-insert" "3-all" "4-match" "5-count" "6-update" "7-delete")

for file in "${files[@]}"; do
  echo "// my comment" > "$file"
  echo "" >> "$file"
done

# Create Python files with comments, newlines, and boilerplate content
python_files=("8-all.py" "9-insert_school.py" "10-update_topics.py" "11-schools_by_topic.py" "12-log_stats.py")

for pyfile in "${python_files[@]}"; do
  echo "#!/usr/bin/env python3" > "$pyfile"
  echo '""" my comment """' >> "$pyfile"
  echo "" >> "$pyfile"
  echo "def function_name():" >> "$pyfile"
  echo "    \"\"\" Function documentation \"\"\"" >> "$pyfile"
  echo "    pass" >> "$pyfile"
  echo "" >> "$pyfile"
done

# Make Python files executable
chmod +x "${python_files[@]}"

# Create the README.md file at the root of the project
echo "# ALX Backend Storage Project" > README.md
echo "" >> README.md
echo "This project contains MongoDB commands and Python scripts for various tasks." >> README.md

# Verify the creation of files
echo "Files created successfully:"
ls -l
