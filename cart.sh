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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling current NodeJS Version"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "Enabling NodeJS:20 Version"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS "

id roboshop # if roboshop does not exit then it failure, I mean set -e petti unte inka mundu velladu
if [ $? -ne 0 ]
then 
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating APP directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading Cart application "

cd /app &>> $LOGFILE
VALIDATE $? "Change Directory to Application"

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unziping Cart "

npm install &>> $LOGFILE
VALIDATE $? "Installing Dependences"

# use absolute, because cart.service exists there
cp /home/centos/roboshop-shell/cart.service /etc/systemd/system/cart.service
VALIDATE $? "Coping Cart service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Cart Demon reload"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enable Cart "

systemctl start cart &>> $LOGFILE
VALIDATE $? "Start Cart "
