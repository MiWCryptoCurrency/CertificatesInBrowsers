#/bin/bash

curve_list=$(perl -alne 'print $F[0];' openssl-NSS.map)
port=8443
for curve in $curve_list
do
	ecdhe_curve=$curve
	echo "starting server on port $port using $curve certificate and $ecdhe_curve for ecdhe"
	openssl s_server -tls1_2 -accept $port -cert $curve.crt -key $curve.key -named_curve $curve -www & 
	port=$(($port+1))
done

echo "Connection Table:"
echo "--------------------"
port=8443
for curve in $curve_list
do
	echo $curve on https://localhost:$port
	port=$(($port+1))
done
echo "--------------------"
