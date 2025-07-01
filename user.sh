#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.kalyanu.xyz

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e " $2 ... $R Failed $N "
        exit 1
    else
        echo -e " $2 ... $G Success $N "
    fi
}


if [ $ID -ne 0 ]
then 
    echo -e " $R ERROR:: Please run this script with root access $N"
    exit 1
else 
    echo -e " you are root user "
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling current version"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "Enabling Nodejs:20 version"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? " Installing Nodejs "

id roboshop
if [ $? != 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
    VALIDATE $? "Creating System User"
else
    echo -e "System User already exist"
fi

mkdir -p /app
VALIDATE $? " Creating app directory "

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>> $LOGFILE
VALIDATE $? " Downloading user application "

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE 
VALIDATE $? " Unzipping user "

npm install &>> $LOGFILE
VALIDATE $? " Installing dependencies "

# we need to give absolute path because you are in /app directory currently.
cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? " Copying user service file "

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " User daemon-reload "

systemctl enable user &>> $LOGFILE
VALIDATE $? " Enable User "

systemctl start user &>> $LOGFILE
VALIDATE $? " Start User "

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? " copying mongodb repo "

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? " Installing mongodb client "

mongo --host $MONGODB_HOST </app/schema/user.js &>> $LOGFILE
VALIDATE $? " Loading user data into Mongodb "