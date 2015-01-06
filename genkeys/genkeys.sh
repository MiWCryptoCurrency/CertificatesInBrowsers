#/bin/bash -X
# Uses OpenSSL:NSS naming map
curve_list=$(perl -alne 'print $F[0];' openssl-NSS.map)
serial=$((16#$(openssl rand 16 -hex)))
echo "clearing existing keys and certs..."
rm *.key *.crt
echo "generating test root ca cert"
openssl ecparam -name secp256k1 -genkey -out root.key
openssl req -key root.key -new -config openssl-root-cert.cnf -x509 -batch -verify -out root.crt
echo "generating roots"
if ! [ -f root.crt ];
then
	echo "Problem with generating Root CA cert"
	return h 
fi

for curve in $curve_list
do
	echo "-----------------------------------------------"
	echo "generating $curve key"
	openssl ecparam -name $curve -genkey -out $curve.key
	perl -0777 -i.bak -ne 's/(-----BEGIN EC PRIVATE KEY.*-----END EC PRIVATE KEY-----)//sg; print $1' $curve.key
	rm $curve.key.bak
	if [ -s $curve.key ];
	then
		openssl ec -in. $curve.key -text 2>> /dev/null | grep "OID"
	else
		rm $curve.key
	fi
	if [ -f $curve.key ];
	then
		echo "$curve key OK! Generating Self-Signed (TEST) Certificate"
		openssl req -key $curve.key -new -config openssl-test-certs.cnf -batch -verify |  openssl x509 -req -CA root.crt -CAkey root.key -out $curve.crt -sha256 -days 365 -set_serial $serial 2>> /dev/null
		serial=$(($serial+1))
	fi
done

