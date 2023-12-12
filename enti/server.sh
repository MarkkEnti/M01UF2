#!/bin/bash
PORT=3333
TIMEOUT=4
CLIENT="10.65.0.58"
echo "Servidor de EFTP"

echo "(0) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA



echo "(3) Test & Send"

if [ "$DATA" != "EFTP 1.0" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1 
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1
fi


echo "OK_HEADER"
sleep 1
echo "OK_HEADER" | nc $CLIENT $PORT

echo "(4) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

sleep 1

echo $DATA

if [ "$DATA" != "BOOOM" ]
then
	echo "ERROR 2:BAD HANDSHAKE2"
	sleep 1
	echo "KO_HANDSHAKE" | nc $CLIENT $PORT
	exit 2
fi

echo "OK_HANDSHAKE"
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT $PORT

echo "(7a) Listen NUM_FILES"

DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(7b) Send OK/KO_NUM_FILES"

PREFIX=`echo $DATA | cut -d " " -f 1` 

if [ "$PREFIX" != "NUM_FILES" ]
then echo "ERROR 3a: WRONG NUM_FILES"

echo "KO_FILE_NUM" | nc $CLIENT $PORT

echo "OK_FILE_NAME" | nc $CLIENT $PORT

exit 3
fi

echo "OK_FILE_NUM" | nc $CLIENT $PORT
FILE_NAME=`echo $DATA | cut -d " " -f 2`

for N in `seq $FILE_NAME`
do

	echo "Archivo Numero $N"
	
echo "(8) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA
echo "(8a) Listen"


echo "(12) Test & Store & Send"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_NAME" ]
then
	echo "ERROR 3: WRONG FILE NAME PREFIX"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi

sleep 1
echo "OK_FILE_NAME" | nc $CLIENT $PORT

FILE_NAME=`echo $DATA | cut -d " " -f 2`

MD5=`echo fary1.txt | md5sum`
MD5=`echo $MD5 | cut -d " " -f 1`
MD5A=`echo $DATA | cut -d " " -f 3`

echo $MD5
echo $MD5A

if [ "$MD5" != "$MD5A" ]
then
	echo "ERROR 5: Archivo corrupto"
	sleep 1
	echo "Archivo corrupto" | nc $CLIENT $PORT
	exit 5
fi

echo "(13) Listen"

`nc -l -p $PORT -w $TIMEOUT > inbox/$FILE_NAME`

echo "(16)Store & Send"

DATA=`cat inbox/$FILE_NAME`
if [ "$DATA"  == "" ]
then
	echo "ERROR 5: ARCHIVO VACIO"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
	exit 5
fi
sleep 1
echo "OK_DATA" | nc $CLIENT $PORT

echo "(17) Listen"

PREFIX=`nc -l -p $PORT -w $TIMEOUT | cut -d " " -f 1`
HASHFL=`nc -l -p $PORT -w $TIMEOUT | cut -d " " -f 2`

echo $DATA

echo "(20) Test&Send"

if [ "$PREFIX" != "FILE_MD5" ]
then
	echo "ERROR 5: BAD FILE M5D PREFIX"
	sleep 1
	echo "KO_PREFIX_MD5" | nc $CLIENT $PORT
	exit 5
fi

HASH2=`cat inbox/fary1.txt | md5sum | cut -d " " -f 1`

echo "OK_FILE_MD5" | nc $CLIENT $PORT

if [ "$HASHFL" != "$HASH2" ]
then
	echo "ERROR 7: WRONG HASH"
	sleep 1
	echo "KO_HASH" | nc $CLIENT $PORT
	exit 7
fi

echo "OK_FILE_MD5" | nc $CLIENT $SERVER

done


echo "FIN"
exit

