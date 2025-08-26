#!/bin/bash
set -euo pipefail

CSV_FILE="employee.csv"

# Create CSV with header if not exists
if [[ ! -f "$CSV_FILE" ]]; then
  echo "username,fullname" > "$CSV_FILE"
fi

read -rp "Enter UserName: " user
read -rp "Enter your Full Name: " name

# normalize username: trim spaces, lowercase, remove inner spaces
user="$(echo "$user" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]' | tr -d ' ')"

# simple username validation (linux-friendly)
if ! [[ "$user" =~ ^[a-z_][a-z0-9_.-]*$ ]]; then
  echo "Invalid username. Allowed: letters, digits, _ . - (start with letter/_)."
  exit 1
fi

# trim fullname spaces and replace any commas with spaces to keep CSV valid
name="$(echo "$name" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr ',' ' ')"

echo
echo "You entered:"
echo "  username: $user"
echo "  fullName: $name"
read -rp "Confirm? [y/n] " input

case "$input" in
  y|Y)
    # prevent duplicate usernames in CSV
    if grep -qi "^${user}," "$CSV_FILE"; then
      echo "Username already exists in $CSV_FILE. Not adding duplicate."
      exit 1
    fi
    echo "$user,$name" >> "$CSV_FILE"
    echo "Saved to $CSV_FILE"
    ;;
  n|N) echo "Cancelled."; exit 0 ;;
  *)   echo "Cancelled."; exit 0 ;;
esac

