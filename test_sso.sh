#!/bin/bash

# Configuration
OPENIG_URL="http://localhost/sso"
USERNAME="duykim"
PASSWORD="password"
COOKIE_FILE="/tmp/oidc_cookies.txt"

rm -f $COOKIE_FILE

echo "--- Step 1: Initial request to OpenIG ---"
RESPONSE_1=$(curl -s -i -c $COOKIE_FILE "$OPENIG_URL")
AUTH_URL=$(echo "$RESPONSE_1" | grep -i "Location:" | awk '{print $2}' | tr -d '\r')

if [ -z "$AUTH_URL" ]; then
    echo "FAILED: No redirect from OpenIG. Response:"
    echo "$RESPONSE_1"
    exit 1
fi
echo "Redirected to Keycloak: $AUTH_URL"

echo -e "\n--- Step 2: Fetch Keycloak Login Page ---"
RESPONSE_2=$(curl -s -i -b $COOKIE_FILE -c $COOKIE_FILE -L "$AUTH_URL")
LOGIN_ACTION_URL=$(echo "$RESPONSE_2" | grep -o 'action="[^"]*"' | head -1 | cut -d'"' -f2 | sed 's/&amp;/\&/g')

if [ -z "$LOGIN_ACTION_URL" ]; then
    echo "FAILED: Could not find login form action in Keycloak."
    exit 1
fi
echo "Login form action: $LOGIN_ACTION_URL"

echo -e "\n--- Step 3: Submitting Login Credentials ---"
# FIXED CURL SYNTAX
RESPONSE_3=$(curl -s -i -b $COOKIE_FILE -c $COOKIE_FILE \
    -d "username=$USERNAME" \
    -d "password=$PASSWORD" \
    -d "credentialId=" \
    "$LOGIN_ACTION_URL")

CALLBACK_URL=$(echo "$RESPONSE_3" | grep -i "Location:" | awk '{print $2}' | tr -d '\r')

if [ -z "$CALLBACK_URL" ]; then
    echo "FAILED: Login submission did not result in a redirect."
    echo "Check if username/password are correct in Keycloak."
    exit 1
fi
echo "Redirected back to OpenIG: $CALLBACK_URL"

echo -e "\n--- Step 4: Completing SSO at OpenIG ---"
# Following the callback to OpenIG
RESPONSE_4=$(curl -s -i -b $COOKIE_FILE -c $COOKIE_FILE -L "$CALLBACK_URL")

if echo "$RESPONSE_4" | grep -q "SSO Success!"; then
    echo -e "\n********************************************************"
    echo "S U C C E S S :  O I D C   S S O   C O N F I R M E D !"
    echo "********************************************************"
    echo "Final Node Response: $(echo "$RESPONSE_4" | grep -o 'Node: [^<]*')"
else
    echo -e "\nFAILED: Did not see 'SSO Success!' in the final response."
    echo "Response Snippet:"
    echo "$RESPONSE_4" | grep -i "SSO" || echo "$RESPONSE_4" | head -n 20
    exit 1
fi