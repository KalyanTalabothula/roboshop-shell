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

dnf install maven -y &>> $LOGFILE
VALIDATE $? " Installing maven "

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? " Downloading shopping application "

cd /app &>> $LOGFILE
VALIDATE $? "Changing to app directory"

unzip -o /tmp/shipping.zip 
VALIDATE $? "Unzipping shipping"

mvn clean package &>> $LOGFILE
VALIDATE $? " Installing Dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "renaming jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? " copying shipping service "

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " daemon-reloading "

systemctl enable shipping &>> $LOGFILE
VALIDATE $? " Enable shipping "

systemctl start shipping &>> $LOGFILE
VALIDATE $? " Starting shipping "

dnf install mysql -y &>> $LOGFILE
VALIDATE $? " Installing mysql client "

mysql -h mysql.kalyanu.xyz -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? " loding shipping data & creating user and password not to use root "

systemctl restart shipping &>> $LOGFILE
VALIDATE $? " Restarting shipping "