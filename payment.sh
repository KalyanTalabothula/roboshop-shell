#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.kalyanu.xyz

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "ERROR:: $2 ... $R  Failed $N"
        exit 1
    else 
        echo -e " $2 ... $G Success $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R ERROR: please run the script with root accuss $N"
    exit 1
else 
    echo "you are root user"
fi 


dnf install python3 gcc python3-devel -y

mkdir -p /app 

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip

cd /app 

unzip -o /tmp/payment.zip


pip3 install -r requirements.txt

vim /etc/systemd/system/payment.service

systemctl daemon-reload

systemctl enable payment 

systemctl start payment