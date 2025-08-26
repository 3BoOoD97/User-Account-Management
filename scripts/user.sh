#!/bin/bash
set -euo pipefail

CSV_FILE="employee.csv"
OUT_FILE="out.txt"

# must be root
if [[ $EUID -ne 0 ]]; then
  echo "Run as root (use sudo)."
  exit 1
fi

# csv must exist
if [[ ! -f "$CSV_FILE" ]]; then
  echo "CSV not found: $CSV_FILE"
  exit 1
fi

# normalize line endings (remove CR if present)
tmp_csv="$(mktemp)"
sed 's/\r$//' "$CSV_FILE" > "$tmp_csv"

# read: username,fullname
while IFS=, read -r rawUser rawFullName || [[ -n "${rawUser:-}" ]]; do
  # skip empty lines
  [[ -z "${rawUser:-}" ]] && continue

  # sanitize username: strip CR/space, lowercase
  userName="$(echo "$rawUser" | tr -d '\r' | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
  fullName="$(echo "${rawFullName:-}" | tr -d '\r')"

  # skip header if present
  if [[ "$userName" == "username" ]]; then
    continue
  fi

  # username validity (letters, digits, -, _ .)
  if ! [[ "$userName" =~ ^[a-z_][a-z0-9_.-]*$ ]]; then
    echo "Skip invalid username: '$userName'"
    continue
  fi

  # if user exists, skip
  if id "$userName" &>/dev/null; then
    echo "User exists, skipping: $userName"
    continue
  fi

  password="$(openssl rand -base64 12)"

  # create user with home dir and gecos (full name)
  useradd -m -c "$fullName" "$userName"

  # set password
  echo "$userName:$password" | chpasswd

  # force change on first login
  chage -d 0 "$userName"

  # output
  echo "User created: $userName"
  echo "Full Name: $fullName"
  echo "Random Password: $password"
  echo "---------------------------"

  echo "$userName,$password" >> "$OUT_FILE"

done < "$tmp_csv"

rm -f "$tmp_csv"
echo "User creation completed!"

