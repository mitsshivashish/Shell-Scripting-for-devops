# Configuration Files

**Advanced ~25 min read**

Hardcoding values in scripts is a recipe for maintenance headaches. Professional scripts separate configuration from code, allowing easy customization across environments. This lesson teaches you multiple approaches to configuration management!

## Sourcing Configuration Files

The simplest approach: store configuration in a Bash file and source it.

### Example

```bash
#!/usr/bin/env bash
# Configuration Demo - Sourcing Config Files

echo "=== Configuration Demo ==="
echo ""

# Create a sample config file
CONFIG_FILE="/tmp/demo_config.sh"

cat > "$CONFIG_FILE" << 'EOF'
# Sample configuration file
# This gets sourced by the main script

# Database settings
DB_HOST="localhost"
DB_PORT=5432
DB_NAME="myapp"
DB_USER="appuser"

# Application settings
APP_ENV="development"
APP_DEBUG=true
LOG_LEVEL="INFO"

# Paths
DATA_DIR="/var/data"
TEMP_DIR="/tmp/myapp"
EOF

echo "--- Config File Contents ---"
cat "$CONFIG_FILE"
echo ""

# Source the config file
echo "--- Loading Configuration ---"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    echo "Configuration loaded from: $CONFIG_FILE"
else
    echo "Config file not found!"
fi
echo ""

# Display loaded values
echo "--- Loaded Values ---"
echo "DB_HOST=$DB_HOST"
echo "DB_PORT=$DB_PORT"
echo "DB_NAME=$DB_NAME"
echo "DB_USER=$DB_USER"
echo "APP_ENV=$APP_ENV"
```

### Output

Click Run to execute your code.

## Config File Format

```bash
# config.sh - Application configuration
# This file is sourced by the main script

# Database settings
DB_HOST="localhost"
DB_PORT=5432
DB_NAME="myapp"
DB_USER="appuser"

# Application settings
APP_ENV="development"
APP_DEBUG=true
APP_LOG_LEVEL="INFO"

# Paths
DATA_DIR="/var/data/myapp"
LOG_DIR="/var/log/myapp"
TEMP_DIR="/tmp/myapp"

# Feature flags
ENABLE_CACHE=true
ENABLE_METRICS=false
```

**The `source` Command:** `source file` (or `. file`) executes the file in the current shell, making its variables available. Unlike running a script, sourcing doesn't create a subshell.

## Environment Variables with Defaults

Environment variables allow runtime configuration without modifying files.

```bash
# Pattern: Use env var if set, otherwise use default
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
APP_ENV="${APP_ENV:-production}"

# Pattern: Require env var (fail if unset)
DB_PASSWORD="${DB_PASSWORD:?Database password required}"
API_KEY="${API_KEY:?API key must be set}"

# Pattern: Use env var only if set and non-empty
LOG_FILE="${LOG_FILE:+$LOG_FILE}"  # Empty if unset

# Check boolean env vars
if [[ "${DEBUG:-false}" == "true" ]]; then
    set -x
fi

# Load from .env file (dotenv pattern)
load_dotenv() {
    local env_file="${1:-.env}"
    if [[ -f "$env_file" ]]; then
        # Export each line as variable
        set -a  # Auto-export
        source "$env_file"
        set +a
    fi
}

load_dotenv
```

### Parameter Expansion Reference

| Syntax | Behavior |
|---|---|
| `${var:-default}` | Use default if var is unset or empty |
| `${var:=default}` | Set var to default if unset or empty |
| `${var:?error}` | Exit with error if var is unset or empty |
| `${var:+value}` | Use value if var IS set and non-empty |
