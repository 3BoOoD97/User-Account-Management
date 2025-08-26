# User Account Management (Bash + CSV)

Bash scripts to **manage Linux user accounts** from a CSV file.  
Includes a prompt-based helper to append employee data into `employee.csv` and a creator script that provisions Linux user accounts with **random passwords**, forces password change on first login, and saves generated credentials to `out.txt`.

---

## Project Structure

```
user-account-management/
├── scripts/
│   ├── add-to-csv.sh          # Collects username/fullname and appends to employee.csv
│   └── create-users.sh        # Creates Linux users from CSV
├── employee.csv               # CSV with: username,fullname (first row is a header)
├── .gitignore                 # Ignores logs/secrets/output files
└── README.md                  # This file
```

---

## Prerequisites

- Linux host (run the creator script with **sudo/root**).
- `openssl` (for random passwords).

Install if needed:
```bash
sudo apt-get update
sudo apt-get install -y openssl dos2unix
```

---

## CSV Format

File: **`employee.csv`**

- First row is a **header**: `username,fullname`
- Each subsequent row: one user per line
- Example:
```csv
username,fullname
abod,abod dabor
```

> Commas inside full names are replaced by spaces by the helper script to keep the CSV valid.

---

## Scripts

### 1) `scripts/add-to-csv.sh`
Interactive helper to safely add entries to `employee.csv`.

**Features:**
- Trims spaces, lowercases usernames, removes inner spaces.
- Validates usernames: `^[a-z_][a-z0-9_.-]*$`
- Prevents duplicates in the CSV.
- Creates the header automatically when file is missing.

**Run:**
```bash
chmod +x scripts/add-to-csv.sh
./scripts/add-to-csv.sh
```

---

### 2) `scripts/create-users.sh`
Reads `employee.csv` and creates users.

**What it does:**
1. Ensures it runs as **root**.
2. Normalizes CSV line endings (removes CR if present).
3. For each row:
   - Validates/sanitizes `username` and `fullname`.
   - Skips invalid or duplicate system users.
   - Creates user with home dir: `useradd -m -c "<fullname>" <username>`
   - Generates random password: `openssl rand -base64 12`
   - Sets password via `chpasswd` and **forces change on first login** (`chage -d 0`).
   - Appends `username,password` to **`out.txt`**.

**Run:**
```bash
sudo chmod +x scripts/create-users.sh
sudo ./scripts/create-users.sh
```

**Output files:**
- `out.txt` — CSV of `username,password` for the created users.
- Console messages showing actions and any skipped rows.

---

## Security Notes!
- Keep `out.txt` secure: it contains **plaintext passwords** generated for users.
- Consider changing permissions:
```bash
chmod 600 out.txt
```

---

## Quick Start

```bash
# 1) Prepare repository
git clone git@github.com:<USERNAME>/user-account-management.git
cd user-account-management

# 2) Add users to CSV
./scripts/add-to-csv.sh   # follow the prompts (username, full name)

# 3) Create Linux users (requires sudo/root)
sudo ./scripts/create-users.sh
```

---


