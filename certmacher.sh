#!/bin/bash

truststorepass= truststore_pass

[ -f ca.key ] || [ -f ca.crt ] && echo 'ca.key and/or ca.crt already exist. Exiting.' && exit 1
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -subj "/C=US/ST=NC/L=Utopia/O=Justron/OU=ca/CN=ca1" -sha256 -days 1024 -out ca.crt

fname=$1
for i in $(egrep -v '^\s*#' certz.list)
do
	filename=$(echo $i | cut -f1 -d '!')
	cn=$(echo $i | cut -f2 -d '!')
	ou=$(echo $i | cut -f3 -d '!')
	san=$(echo $i | cut -f4 -d '!')
	blah="/C=US/ST=NC/O=Justron/OU=$ou/CN=$cn"
	sanstring="\n[SAN]\nsubjectAltName=$san"
	if [ ! -f $filename.key ] && [ ! -f $filename.csr ]
	then
		openssl req -new -sha256 -newkey rsa:2048 -nodes -keyout $filename.key -subj $blah -reqexts SAN -config <(cat /etc/pki/tls/openssl.cnf <(printf $sanstring)) -out $filename.csr
	else
		echo "$filename.key or $filename.csr already exists. Skipping."
	fi
done

keytool -import -file ca.crt -alias localca -keystore truststore.jks -noprompt -storepass $truststorepass

for i in $(egrep -v '^\s*#' certz.list)
do
	filename=$(echo $i | cut -f1 -d '!')
	cn=$(echo $i | cut -f2 -d '!')
	ou=$(echo $i | cut -f3 -d '!')
	san=$(echo $i | cut -f4 -d '!')
	kspass=$(echo $i | cut -f5  -d '!')
	if [ ! -f $filename.crt ]
	then
		openssl x509 -req -in $filename.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out $filename.crt -days 500 -sha256
		openssl pkcs12 -export -out $filename.pfx -inkey $filename.key -in $filename.crt -password pass:$kspass
		keytool -importkeystore -srckeystore $filename.pfx -srcstoretype pkcs12 -srcalias 1 -srcstorepass $kspass -destkeystore $filename.jks -deststorepass $kspass -destalias $filename

		
	fi
	mkdir $filename
	mv $filename.* $filename/
	cp truststore.jks $filename/
done

