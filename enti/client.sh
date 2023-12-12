#!/bin/bash


SERVER="localhost"

IP=`ip address | grep inet | grep np0s3 | cut -d " " -f 6 | cut -d "/" -f 1`
echo $IP

PORT="3333"
TIMEOUT=1

echo "Cliente de EFTP"
echo "(1) Send"
echo "EFTP 1.0" | nc $SERVER $PORT

sleep 1
echo "(2) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(5) Test & Send"
if [ "$DATA" != "OK_HEADER" ]
then 
	echo "ERROR 1:BAD HEADER"
	exit 1
fi

echo "BOOM" | nc $SERVER $PORT
sleep 1

echo "(6) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT` 

echo $DATA
echo "(9) Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then
	sleep 1
	echo "ERROR 3: BAD HANDSHAKE"
	exit 3
fi
echo "(9a) Send NUM_FILES"

NUM_FILES=`ls imgs/ | wc -l`

sleep 1

echo "NUM_FILES $NUM_FILES" | nc $SERVER $PORT




echo "(9b) Listen OK/KO"

DATA=`nc -l -p $PORT -w $TIMEOUT`



if [ "$DATA" != "OK_FILE_NUM" ]
then
	echo "ERROR KO_FILE_NAME"
	exit 3

	echo "(10a) Loop Num"

for FILE_NAME in `ls imgs/` 
do






echo "(10) Send File Name"


MD5=`echo fary1.txt | md5sum | cut -d " " -f 1`
NOMBRE="FILE_NAME fary1.txt $MD5"
sleep 1
echo "$NOMBRE" | nc $SERVER $PORT

echo "(11) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA
echo "(14) Test&Send"

if [ "$DATA" != "OK_FILE_NAME" ]
then
	echo "ERROR 4: BAD FILE NAME PREFIX"
	exit 4
fi
sleep 1
cat imgs/fary1.txt | nc $SERVER $PORT

echo "(15) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

if [ "$DATA" != "OK_DATA" ]
then
	echo "ERROR 6: EMPTY DATA"
	exit 6
fi

echo "(18) Send"

HASHFL=`cat imgs/fary1.txt | md5sum | cut -d " " -f 1`

sleep 1
echo "FILE_MD5 $HASHFL" | nc $SERVER $PORT

echo $HASHFL

echo "(19) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo "(21) Test"

if [ "$DATA" != "OK_FILE_MD5" ]
then
	echo "ERROR: FILE MD5"
	exit 5
fi
done

echo "FIN"
exit 0

