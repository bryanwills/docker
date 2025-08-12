#!/bin/bash

# Script to import local keys from ~/.keys into HashiCorp Vault
# This script will:
# 1. Read all files from ~/.keys
# 2. Store them in Vault under secret/keys/ with their original filenames
# 3. Set no expiration (TTL = 0)
# 4. Preserve file permissions and metadata
# 5. Use the current authenticated Vault token

set -e

# Configuration
KEYS_DIR="$HOME/.keys"
VAULT_ADDR="${VAULT_ADDR:-https://keys.bryanwills.dev}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔑 Vault Key Export Script${NC}"
echo "================================"

# Check if keys directory exists
if [ ! -d "$KEYS_DIR" ]; then
    echo -e "${RED}❌ Error: Keys directory $KEYS_DIR does not exist${NC}"
    echo "Please create the directory or update KEYS_DIR variable"
    exit 1
fi

# Function to check if file is a text-based key file
is_key_file() {
    local file_path="$1"

    # Skip files larger than 1MB (likely binaries)
    local file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
    if [ "$file_size" -gt 1048576 ]; then
        return 1
    fi

    # Skip common binary/archive extensions
    local filename=$(basename "$file_path")
    case "$filename" in
        *.zip|*.tar.gz|*.tar|*.gz|*.bz2|*.rar|*.7z|*.dmg|*.pkg|*.app|*.exe|*.bin|*.dll|*.so|*.dylib)
            return 1
            ;;
    esac

    # Try to detect if it's a text file (first 1KB)
    if head -c 1024 "$file_path" 2>/dev/null | grep -q '[^[:print:][:space:]]'; then
        return 1
    fi

    return 0
}

# Function to import a single key file
import_key_file() {
    local file_path="$1"
    local filename=$(basename "$file_path")

    # Strip leading dot from filename for Vault storage
    local vault_filename="${filename#.}"
    local vault_path="keys/${vault_filename}"

    # Check if key already exists in Vault
    if vault kv get "$vault_path" >/dev/null 2>&1; then
        echo -e "${YELLOW}⏭️  Skipping existing key: $filename${NC}"
        echo "   Already exists at: $vault_path"
        return 0
    fi

    # Get file info
    local file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null)
    local file_perms=$(stat -f%Lp "$file_path" 2>/dev/null || stat -c%a "$file_path" 2>/dev/null)
    local file_owner=$(stat -f%Su "$file_path" 2>/dev/null || stat -c%U "$file_path" 2>/dev/null)
    local file_mtime=$(stat -f%m "$file_path" 2>/dev/null || stat -c%Y "$file_path" 2>/dev/null)
    local file_mtime_readable=$(date -r "$file_mtime" 2>/dev/null || date -d "@$file_mtime" 2>/dev/null)

    echo -e "${BLUE}📤 Importing: $filename${NC}"

    # Read file content and store in Vault
    local content=$(cat "$file_path")

    # Store in Vault with metadata
    vault kv put "$vault_path" \
        content="$content" \
        filename="$filename" \
        vault_filename="$vault_filename" \
        original_path="$file_path" \
        file_size="$file_size" \
        file_permissions="$file_perms" \
        file_owner="$file_owner" \
        file_modified="$file_mtime_readable" \
        imported_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        source="macbook-pro-export" \
        no_expiration="true" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully imported: $filename${NC}"
        echo "   Vault path: $vault_path"
        echo "   Vault filename: $vault_filename"
        echo "   Size: $file_size bytes"
        echo "   Permissions: $file_perms"
        echo "   Modified: $file_mtime_readable"
    else
        echo -e "${RED}❌ Failed to import: $filename${NC}"
    fi
}

# Main import process
echo -e "${BLUE}🚀 Starting key import process...${NC}"
echo "Source directory: $KEYS_DIR"
echo "Vault address: $VAULT_ADDR"
echo ""

# Count total files to import
total_files=$(find "$KEYS_DIR" -type f | wc -l)
echo -e "${YELLOW}📊 Found $total_files files to import${NC}"
echo ""

# Start the import process
echo -e "${BLUE}📁 Processing files...${NC}"

# Process all files - portable approach for older bash versions
processed_count=0
skipped_count=0
files=()
while IFS= read -r -d '' file; do
    files+=("$file")
done < <(find "$KEYS_DIR" -type f -print0)

echo -e "${YELLOW}🔍 Found ${#files[@]} total files${NC}"
echo ""

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        if is_key_file "$file"; then
            ((processed_count++))
            echo -e "${YELLOW}🔍 Processing file #$processed_count: $file${NC}"
            import_key_file "$file"
        else
            ((skipped_count++))
            local filename=$(basename "$file")
            local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            echo -e "${YELLOW}⏭️  Skipping non-key file #$skipped_count: $filename (${file_size} bytes)${NC}"
        fi
    fi
done

echo ""
echo -e "${YELLOW}📊 Processed $processed_count key files, skipped $skipped_count non-key files${NC}"
echo ""
echo -e "${GREEN}🎉 Key import process completed!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Verify your keys are stored: vault kv list keys/"
echo "2. View a specific key: vault kv get keys/[filename]"
echo "3. Update the root token for security: vault token revoke myroot"
echo "4. Create a new root token: vault token create -policy=root"
echo ""
echo -e "${BLUE}🔍 Verification commands:${NC}"
echo "# List all imported keys:"
echo "vault kv list keys/"
echo ""
echo "# View a specific key:"
echo "vault kv get keys/[filename]"
echo ""
echo "# Check key metadata:"
echo "vault kv metadata keys/[filename]"
echo ""
echo -e "${YELLOW}⚠️  Security Note:${NC}"
echo "- The current root token 'myroot' is not secure for production"
echo "- Consider revoking it and creating a new one"
echo "- Use GitHub OAuth for regular access instead of root tokens"
