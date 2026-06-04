#!/bin/sh
set -e

mkdir -p /app/config

if [ ! -f /app/config/rsa_private_key.pem ]; then
    openssl genrsa -out /app/config/rsa_private_key.pem 1024 2>/dev/null
fi

if [ -f /app/config/FutuOpenD.xml ]; then
    exec /app/FutuOpenD -cfg_file=/app/config/FutuOpenD.xml
fi

if [ -n "$FUTU_LOGIN_ACCOUNT" ]; then
    if [ ! -f /app/config/FutuOpenD.xml ]; then
        cat > /app/config/FutuOpenD.xml <<EOF
<futu_opend>
    <ip>0.0.0.0</ip>
    <api_port>11111</api_port>
    <login_account>${FUTU_LOGIN_ACCOUNT}</login_account>
    <login_pwd>${FUTU_LOGIN_PWD}</login_pwd>
    <lang>chs</lang>
    <log_level>info</log_level>
    <push_proto_type>0</push_proto_type>
    <telnet_ip>0.0.0.0</telnet_ip>
    <telnet_port>22222</telnet_port>
    <rsa_private_key>/app/config/rsa_private_key.pem</rsa_private_key>
    <price_reminder_push>1</price_reminder_push>
    <auto_hold_quote_right>1</auto_hold_quote_right>
    <future_trade_api_time_zone>UTC+8</future_trade_api_time_zone>
</futu_opend>
EOF
    fi
    exec /app/FutuOpenD -cfg_file=/app/config/FutuOpenD.xml
fi

echo "ERROR: No config file and no FUTU_LOGIN_ACCOUNT env var set." >&2
echo "Mount config:  docker run -v ./config:/app/config futu-opend" >&2
echo "Or use env:    docker run -e FUTU_LOGIN_ACCOUNT=xxx -e FUTU_LOGIN_PWD=yyy futu-opend" >&2
exit 1
