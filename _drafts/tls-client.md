# TLS client

```bash
# Эта команда создаст приватный ключ в файле ca.key.
openssl genpkey -algorithm ed25519 -out ca.pem
# Эта команда создаст самоподписанный сертификат ca.crt на основе созданного ключа.
openssl req -new -x509 -key ca.pem -out ca.crt -days 3650 -subj "/CN=My ED25519 CA"
# Эта команда выведет информацию о созданном сертификате, включая его параметры.
openssl x509 -in ca.crt -text -noout

# генерируем клиентский ключ
openssl genpkey -algorithm ed25519 -out client.pem
# генерируем csr и приносим его на машину с CA
openssl req -key client.pem -new -out client.csr -subj "/CN=fsa@tavda.info"

# генерируем клиентский сертификат на основе csr
openssl x509 -req -in client.csr -out client.crt -CA ca.crt -CAkey ca.pem -CAcreateserial
# смотрим на него
openssl x509 -in client.crt -noout -text
# собираем на машине с ключом pkcs12 контейнер с ключом и сертификатом для браузера
openssl pkcs12 -export -out client.p12 -in client.crt -inkey client.pem
```

## Из статьи с Хабра

```bash
# генерируем ключ
openssl genrsa -out ca.pem 2048
# генерируем самоподписанный сертификат
openssl req -x509 -subj '/CN=test ca' -days 365 -key ca.pem -out ca.crt
# смотрим глазами на самоподписанный (root) CA
openssl x509 -in ca.crt -noout -text

# генерируем клиентский ключ
openssl genrsa -out client.pem 2048
# генерируем csr и приносим его на машину с CA
openssl req -key client.pem -new -out client.csr -subj '/CN=client'

# генерируем клиентский сертификат на основе csr
openssl x509 -req -in client.csr -out client.crt -CA ca.crt -CAkey ca.pem -CAcreateserial
# смотрим на него
openssl x509 -in client.crt -noout -text
# собираем на машине с ключом pkcs12 контейнер с ключом и сертификатом для браузера
openssl pkcs12 -export -out client.p12 -in client.crt -inkey client.pem

# !!! импортируем client.p12 в браузер
# прописываем в уже работающем по https nginx'е `ssl_client_verify` on, optional или optional_no_ca.  в первых двух случаях не забываем притащить nginx'у ca.crt и прописать в `ssl_client_certificate`

# пользуемся
```
