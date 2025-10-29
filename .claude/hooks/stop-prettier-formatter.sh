#!/bin/bash
set -e

# Stop hook that runs Prettier on all edited files
# This runs when Claude Code finishes responding

# Read session data from stdin
session_data=$(cat)
session_id=$(echo "$session_data" | jq -r '.session_id // "default"')

# Use cache directory in project
cache_dir="$CLAUDE_PROJECT_DIR/.claude/tsc-cache/${session_id}"

# Check if cache directory exists
if [[ ! -d "$cache_dir" ]]; then
    exit 0  # No edits were made, nothing to format
fi

# Check if edited files log exists
edited_files_log="$cache_dir/edited-files.log"
if [[ ! -f "$edited_files_log" ]]; then
    exit 0  # No files to format
fi

# Extract unique file paths from the log (format: timestamp:path:repo)
files_to_format=$(awk -F: '{print $2}' "$edited_files_log" | sort -u)

# Count files to format
file_count=$(echo "$files_to_format" | wc -l | tr -d ' ')

if [[ -z "$files_to_format" ]] || [[ "$file_count" -eq 0 ]]; then
    exit 0  # No files to format
fi

echo "🎨 Formatting $file_count edited file(s) with Prettier..."

# Change to project root
project_root="$CLAUDE_PROJECT_DIR"
cd "$project_root"

# Function to get appropriate Prettier config for file
get_prettier_config() {
    local file="$1"
    local file_dir=$(dirname "$file")

    # Search upward from file directory for .prettierrc
    current_dir="$file_dir"
    while [[ "$current_dir" != "/" ]] && [[ "$current_dir" != "$HOME" ]]; do
        if [[ -f "$current_dir/.prettierrc" ]]; then
            echo "$current_dir/.prettierrc"
            return
        fi
        if [[ -f "$current_dir/.prettierrc.json" ]]; then
            echo "$current_dir/.prettierrc.json"
            return
        fi
        if [[ -f "$current_dir/.prettierrc.js" ]]; then
            echo "$current_dir/.prettierrc.js"
            return
        fi
        # Move up one directory
        current_dir=$(dirname "$current_dir")
    done

    # Check project root
    if [[ -f "$project_root/.prettierrc" ]]; then
        echo "$project_root/.prettierrc"
        return
    fi
    if [[ -f "$project_root/.prettierrc.json" ]]; then
        echo "$project_root/.prettierrc.json"
        return
    fi

    # No config found - return empty (will use Prettier defaults)
    echo ""
}

# Format each file
formatted_count=0
while IFS= read -r file; do
    # Skip empty lines
    if [[ -z "$file" ]]; then
        continue
    fi
    
    # Check if file exists and is a formattable type
    if [[ -f "$file" ]] && [[ "$file" =~ \.(ts|tsx|js|jsx|json)$ ]]; then
        config_path=$(get_prettier_config "$file")

        # Format with config if found, otherwise use defaults
        if [[ -n "$config_path" ]] && [[ -f "$config_path" ]]; then
            if npx prettier --write "$file" --config "$config_path" 2>/dev/null; then
                echo "  ✅ $(basename "$file")"
                ((formatted_count++))
            else
                echo "  ⚠️  Failed to format $(basename "$file")"
            fi
        else
            # Use Prettier defaults (no config)
            if npx prettier --write "$file" 2>/dev/null; then
                echo "  ✅ $(basename "$file") (using defaults)"
                ((formatted_count++))
            else
                echo "  ⚠️  Failed to format $(basename "$file")"
            fi
        fi
    fi
done <<< "$files_to_format"

if [[ $formatted_count -gt 0 ]]; then
    echo "✨ Formatted $formatted_count file(s) successfully"
else
    echo "ℹ️  No files needed formatting"
fi

# Exit cleanly
exit 0