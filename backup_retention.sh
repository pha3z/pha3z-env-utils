#!/bin/bash

# AUTHOR: JAMES HOUX
# DATE: 2025-4-14
# WHAT: Zero dependencies backups retention script
# WHY: Works well with a daily mysqldump for periodic database backs or any other
# process that can be configured to generate daily folders.
# Makes backup retention completely independent from daily backup processes.
#
# HOW IT WORKS:
# Given an input folder, this script scans for subfolders with the naming pattern YYYY-MM-DD
# The retention days and retention weeks constants are then used to transition
# the contents from the daily subfolders into weekly and eventually monthly folders.
#
# IDEMPOTENCY:
# The script is idempotent, meaning running it N times back-to-back will have the same result
# as if you ran it only once (assuming the main folder doesn't change between runs).
# You could start using this on an existing array of folders that go back many months/years
# or you could start using it on a handful of daily folders in a brand new backup environment.
#
# HOW TO CONFIGURE IT:
# Change RETENTION_DAYS and RETENTION_WEEKS for the behavior you need.
# All daily folders that are older than the RETENTION_DAYS count will be transitioned into weekly folders
# NOTE: Weekly folders are counted backward from TODAY -regardless- of RETENTION_DAYS count.
# So if you set RETENTION_WEEKS to 8, then weekly folders will be maintained up to 8 weeks backward from today.
# If you have 14 RETENTION_DAYS and 8 RETENTION_WEEKS, the result will be 6 (SIX) weekly folders.

RETENTION_DAYS=14
RETENTION_WEEKS=8


# Check if INPUT_FOLDER was provided
if [ -z "$1" ]; then
  echo "Usage: $0 INPUT_FOLDER"
  exit 1
fi

INPUT_FOLDER="$1"

# Change to the input folder
if [ -d "$INPUT_FOLDER" ]; then
  cd "$INPUT_FOLDER" || {
    echo "Failed to change directory to $INPUT_FOLDER"
    exit 1
  }
else
  echo "Error: '$INPUT_FOLDER' is not a valid directory."
  exit 1
fi


RETENTION_DAYS=14
RETENTION_WEEKS=8

DAILY_CUTOFF_DATE=$(date -d "-${RETENTION_DAYS} days" +"%Y-%m-%d")

# Find all dy- folders older than DAILY_CUTOFF_DATE
OLDER_FOLDERS=$(find . -type d -name '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' | sort | while read -r folder; do
  folder_date=$(basename "$folder" | cut -d'-' -f1-)
  if [[ "$folder_date" < "$DAILY_CUTOFF_DATE" ]]; then
    echo "$folder"
  fi
done)

if [ -z "$OLDER_FOLDERS" ]; then
  echo "No daily folders found beyond the cutoff date: ($DAILY_CUTOFF_DATE)"
else
  echo "Moving contents of old daily folders into weekly folders..."

  echo "$OLDER_FOLDERS" | while read -r folder; do
    folder_date=$(basename "$folder" | cut -d'-' -f1-)
    weekly_date=$(date -d "$folder_date -$(date -d "$folder_date" +%w) days" +"%Y-%m-%d")
    weekly_folder="$weekly_date-week"

    if [ ! -d "$weekly_folder" ]; then
      mkdir "$weekly_folder"
      echo "Created weekly folder: $weekly_folder"
    fi

    # Move contents (not the folder itself) into the weekly folder
    if [ "$(ls -A "$folder")" ]; then
      mv "$folder"/* "$weekly_folder"/
      echo "Moved contents: $folder → $weekly_folder"
    fi

    if [ -d "$folder" ]; then
      if [ -z "$(ls -A "$folder")" ]; then
        rmdir "$folder"
      else
        echo "Failed to move entire folder contents: $folder"
      fi
    fi

  done
fi

WEEKLY_CUTOFF_DATE=$(date -d "-${RETENTION_WEEKS} weeks" +"%Y-%m-%d")

# Find all wk- folders older than WEEKLY_CUTOFF_DATE
OLDER_FOLDERS=$(find . -type d -name '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-week' | sort | while read -r folder; do
  folder_date=$(basename "$folder" | cut -d'-' -f1-3)
  if [[ "$folder_date" < "$WEEKLY_CUTOFF_DATE" ]]; then
    echo "$folder"
  fi
done)

if [ -z "$OLDER_FOLDERS" ]; then
  echo "No weekly folders found beyond the cutoff date: ($WEEKLY_CUTOFF_DATE)"
else
  echo "Moving contents of old weekly folders into monthly folders..."

  echo "$OLDER_FOLDERS" | while read -r folder; do
    folder_date=$(basename "$folder" | cut -d'-' -f1-3)
    month_start=$(date -d "$folder_date" +"%Y-%m-01")
    monthly_folder="$month_start-month"

    if [ ! -d "$monthly_folder" ]; then
      mkdir "$monthly_folder"
      echo "Created monthly folder: $monthly_folder"
    fi

    # Move contents (not the folder itself) into the monthly folder
    if [ "$(ls -A "$folder")" ]; then
      mv "$folder"/* "$monthly_folder"/
      echo "Moved contents: $folder → $monthly_folder"
    fi

    if [ -d "$folder" ]; then
      if [ -z "$(ls -A "$folder")" ]; then
        rmdir "$folder"
      else
        echo "Failed to move entire folder contents: $folder"
      fi
    fi

  done
fi