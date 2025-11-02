#!/bin/bash

# Script to test nginx.conf.sigil configuration locally using Docker
# This reads the actual nginx.conf.sigil file, strips Dokku template variables, and validates it

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NGINX_SIGIL="$SCRIPT_DIR/nginx.conf.sigil"
TEST_CONFIG="/tmp/test-nginx.conf"

if [ ! -f "$NGINX_SIGIL" ]; then
    echo "❌ Error: nginx.conf.sigil not found at $NGINX_SIGIL"
    exit 1
fi

echo "🔧 Reading nginx.conf.sigil and creating test config..."
echo ""

# Read nginx.conf.sigil and strip out Dokku template variables
# Comment out include directives
# Remove SSL from listen directives for testing (nginx requires certs to be present)
# Replace SSL cert paths with dummy values
sed -e 's|^.*include {{ \$.DOKKU_ROOT }}/{{ \$.APP }}/nginx.conf.d/\*\.conf;|  # include dummy;|g' \
    -e 's| ssl http2;| http2;|g' \
    -e 's|ssl_certificate.*{{ \$.APP_SSL_PATH }}/server.crt;|    # ssl_certificate /dummy/path.crt;|g' \
    -e 's|ssl_certificate_key.*{{ \$.APP_SSL_PATH }}/server.key;|    # ssl_certificate_key /dummy/path.key;|g' \
    "$NGINX_SIGIL" > "$TEST_CONFIG"

echo "✅ Test config created at $TEST_CONFIG"
echo ""
echo "🐳 Testing nginx config with Docker..."
echo ""

# Test the config using nginx in Docker
if docker run --rm -v "$TEST_CONFIG:/etc/nginx/conf.d/default.conf" nginx:alpine nginx -t 2>&1 | grep -q "syntax is ok"; then
    echo ""
    echo "✅ Nginx configuration is valid!"
    echo ""
    echo "📝 To manually inspect the test config: cat $TEST_CONFIG"
    echo "🗑️  To remove the test config: rm $TEST_CONFIG"
    exit 0
else
    echo ""
    echo "❌ Nginx configuration has errors!"
    echo ""
    echo "📝 Check the test config: cat $TEST_CONFIG"
    exit 1
fi
