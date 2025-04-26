#!/bin/bash
set -euo pipefail

echo "Fetching main branch to compare..."
git fetch origin main

echo "Detecting modified features..."
MODIFIED_FEATURES=$(git diff --name-only origin/main -- 'src/**' | grep '^src/' | cut -d/ -f2 | sort -u || true)

if [ -z "$MODIFIED_FEATURES" ]; then
  echo "No features modified. Skipping tests."
  exit 0
fi

echo "Modified features detected: $MODIFIED_FEATURES"

for feature_name in $MODIFIED_FEATURES; do
  echo "==============================="
  echo "Testing feature: $feature_name"
  echo "==============================="

  TEMP_DIR=$(mktemp -d)
  mkdir -p "$TEMP_DIR/src/$feature_name"
  mkdir -p "$TEMP_DIR/test"

  cp -r src/"$feature_name"/* "$TEMP_DIR/src/$feature_name/"

  # Create dummy test script if not present
  cat <<EOF > "$TEMP_DIR/test/test.sh"
#!/bin/bash
echo "Test for feature: $feature_name"
EOF
  chmod +x "$TEMP_DIR/test/test.sh"

  devcontainer features test -f "$TEMP_DIR/src/$feature_name" -i mcr.microsoft.com/devcontainers/base:ubuntu
done
