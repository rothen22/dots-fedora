#!/bin/bash

# Check for new files in the current directory

# Add all new files
git add .

# Commit with the current date and time
current_date=$(date '+%Y-%m-%d %H:%M:%S')
git commit -m "Automated commit on $current_date"
