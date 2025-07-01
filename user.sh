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

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading user application "

cd /app &>> $LOGFILE
VALIDATE $? "Change Directory to Application"

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unziping user"

npm install &>> $LOGFILE
VALIDATE $? "Installing Dependences"

# use absolute, because user.service exists there
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service
VALIDATE $? "Coping user service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " user Demon reload"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE
VALIDATE $? "Start user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? " Installing Mongodb Client"

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE
VALIDATE $? " Loading user data into Mongodb"