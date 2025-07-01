#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf module disable redis -y &>> $LOGFILE
VALIDATE $? " Disabling redis default version number 6 "

dnf module enable redis:7 -y -y &>> $LOGFILE
VALIDATE $? " Enabling redis version 7 "

dnf install redis -y &>> $LOGFILE
VALIDATE $? " Installing redis "

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE
VALIDATE $? " allowing remote connections "

systemctl enable redis &>> $LOGFILE
VALIDATE $? " Enabling redis "

systemctl start redis &>> $LOGFILE
VALIDATE $? " starting redis "