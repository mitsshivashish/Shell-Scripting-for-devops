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

## Parsing Different Config Formats

Sometimes you need to parse INI files, YAML, or other formats.

### Example

```bash
#!/usr/bin/env bash
# Configuration Parsing Demo

echo "=== Config Parsing Demo ==="
echo ""

# Create sample config files
KEY_VALUE_FILE="/tmp/app.conf"
INI_FILE="/tmp/app.ini"

# Simple key=value config
cat > "$KEY_VALUE_FILE" << 'EOF'
# Application Configuration
# Comments start with #

host=localhost
port=8080
debug=true
name=My Application
timeout=30
EOF

# INI-style config
cat > "$INI_FILE" << 'EOF'
# INI Configuration File

[database]
```

### Output

Click Run to execute your code.

## Common Formats

### Simple `key=value` Parser

```bash
# Simple key=value parser
parse_config() {
    local file="$1"
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue

        # Trim whitespace
        key="$(echo "$key" | xargs)"
        value="$(echo "$value" | xargs)"

        # Remove quotes
        value="${value#[\"\']}"
        value="${value%[\"\']}"

        # Export as variable
        export "$key=$value"
    done < "$file"
}
```

### INI File Parser

```bash
# INI file parser (with sections)
parse_ini() {
    local file="$1"
    local section=""

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*[#\;] ]] && continue
        [[ -z "${line// }" ]] && continue

        # Section header
        if [[ "$line" =~ ^\[([^\]]+)\] ]]; then
            section="${BASH_REMATCH[1]}_"
            continue
        fi

        # Key=value
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            local key="${section}${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            key="$(echo "$key" | xargs | tr '[:lower:]' '[:upper:]')"
            export "$key=$value"
        fi
    done < "$file"
}

# Usage with INI:
# [database]
# host=localhost
# port=5432
# -> DATABASE_HOST=localhost, DATABASE_PORT=5432
```

## Configuration Hierarchy

Professional scripts support multiple config sources with clear precedence.

```bash
# Load configuration with precedence:
# 1. Built-in defaults (lowest)
# 2. System config file
# 3. User config file
# 4. Environment variables
# 5. Command-line arguments (highest)

load_config() {
    # 1. Defaults
    DB_HOST="localhost"
    DB_PORT=5432
    APP_ENV="production"

    # 2. System config
    [[ -f "/etc/myapp/config" ]] && source "/etc/myapp/config"

    # 3. User config
    [[ -f "$HOME/.myapprc" ]] && source "$HOME/.myapprc"

    # 4. Local project config
    [[ -f "./.myapp.conf" ]] && source "./.myapp.conf"

    # 5. Environment overrides
    DB_HOST="${MYAPP_DB_HOST:-$DB_HOST}"
    DB_PORT="${MYAPP_DB_PORT:-$DB_PORT}"
    APP_ENV="${MYAPP_ENV:-$APP_ENV}"

    # 6. Command-line args override in parse_args()
}

# Environment-specific configs
load_environment_config() {
    local env="${APP_ENV:-production}"
    local config_dir="${CONFIG_DIR:-/etc/myapp}"

    # Load base config
    [[ -f "$config_dir/config.sh" ]] && source "$config_dir/config.sh"

    # Load environment-specific overrides
    [[ -f "$config_dir/config.$env.sh" ]] && source "$config_dir/config.$env.sh"
}
```

**12-Factor App:** The 12-factor methodology recommends storing config in environment variables. This works well for containerized applications and CI/CD pipelines.

## Configuration Validation

Always validate configuration before using it.

```bash
# Validate required settings
validate_config() {
    local errors=0

    # Required variables
    for var in DB_HOST DB_USER DB_PASSWORD; do
        if [[ -z "${!var}" ]]; then
            echo "ERROR: $var is required" >&2
            ((errors++))
        fi
    done

    # Numeric validation
    if [[ ! "$DB_PORT" =~ ^[0-9]+$ ]]; then
        echo "ERROR: DB_PORT must be a number" >&2
        ((errors++))
    fi

    # Range validation
    if [[ $DB_PORT -lt 1 || $DB_PORT -gt 65535 ]]; then
        echo "ERROR: DB_PORT must be 1-65535" >&2
        ((errors++))
    fi

    # Path validation
    if [[ ! -d "$DATA_DIR" ]]; then
        echo "ERROR: DATA_DIR does not exist: $DATA_DIR" >&2
        ((errors++))
    fi

    # Enum validation
    case "$APP_ENV" in
        development|staging|production) ;;
        *)
            echo "ERROR: APP_ENV must be development, staging, or production" >&2
            ((errors++))
            ;;
    esac

    return $errors
}

# Print current configuration
print_config() {
    echo "=== Current Configuration ==="
    echo "DB_HOST=$DB_HOST"
    echo "DB_PORT=$DB_PORT"
    echo "DB_NAME=$DB_NAME"
    echo "DB_USER=$DB_USER"
    echo "DB_PASSWORD=****"  # Don't print passwords!
    echo "APP_ENV=$APP_ENV"
    echo "DATA_DIR=$DATA_DIR"
}
```

## Common Mistakes

### 1. Sourcing untrusted config files

```bash
# Dangerous - config could run arbitrary code!
source "$USER_PROVIDED_CONFIG"

# Safer - parse key=value only
while IFS='=' read -r key value; do
    # Validate key name
    [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]] || continue
    declare "$key=$value"
done < "$config"
```

### 2. No default values

```bash
# Wrong - fails if not set
process --host "$DB_HOST"

# Correct - provide defaults
DB_HOST="${DB_HOST:-localhost}"
process --host "$DB_HOST"
```

### 3. Hardcoding paths

```bash
# Wrong - not portable
CONFIG_FILE="/home/john/myapp/config"

# Correct - use variables
CONFIG_FILE="${HOME}/.config/myapp/config"
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/myapp/config"
```

## Summary

- **source:** Load config from Bash files with `source config.sh`
- **Defaults:** Always provide defaults with `${VAR:-default}`
- **Hierarchy:** Support multiple sources with clear precedence
- **Validation:** Always validate config before use
- **Security:** Never source untrusted files; parse instead
- **Secrets:** Use environment variables for passwords/tokens
