#!/bin/bash
# WAF Testing Script
# Usage: ./test-waf.sh <ALB_DNS_NAME>

ALB_DNS=$1

if [ -z "$ALB_DNS" ]; then
  echo "Usage: ./test-waf.sh <ALB_DNS_NAME>"
  echo "Example: ./test-waf.sh dev-web-alb-123.us-east-1.elb.amazonaws.com"
  exit 1
fi

echo "Testing WAF on https://$ALB_DNS"
echo "---------------------------------------------------"

# 1. Normal Request
echo "[1] Testing Normal Request (Should be ALLOWED)"
HUD_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$ALB_DNS/")
echo "HTTP Status: $HUD_CODE"
if [[ "$HUD_CODE" == "200" || "$HUD_CODE" == "503" ]]; then
  echo "RESULT: PASS (Allowed)"
else
  echo "RESULT: FAIL (Unexpected Status)"
fi
echo ""

# 2. SQL Injection Test
echo "[2] Testing SQL Injection (Should be BLOCKED)"
echo "Payload: /?id=1' OR '1'='1"
SQLI_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$ALB_DNS/?id=1'%20OR%20'1'='1")
echo "HTTP Status: $SQLI_CODE"
if [[ "$SQLI_CODE" == "403" ]]; then
  echo "RESULT: PASS (Blocked)"
else
  echo "RESULT: FAIL (Not Blocked)"
fi
echo ""

# 3. XSS Test
echo "[3] Testing Cross-Site Scripting (XSS) (Should be BLOCKED)"
echo "Payload: /?name=<script>alert('XSS')</script>"
XSS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$ALB_DNS/?name=<script>alert('XSS')</script>")
echo "HTTP Status: $XSS_CODE"
if [[ "$XSS_CODE" == "403" ]]; then
  echo "RESULT: PASS (Blocked)"
else
  echo "RESULT: FAIL (Not Blocked)"
fi
echo ""

# 4. Bad User Agent Test
echo "[4] Testing Bad User Agent 'scanner' (Should be BLOCKED)"
UA_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k -A "automated-scanner-v1" "https://$ALB_DNS/")
echo "HTTP Status: $UA_CODE"
if [[ "$UA_CODE" == "403" ]]; then
  echo "RESULT: PASS (Blocked)"
else
  echo "RESULT: FAIL (Not Blocked)"
fi
echo ""

echo "---------------------------------------------------"
echo "Testing Complete. Check CloudWatch Dashboard for metrics."
