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
    echo -e " $R ERROR:: Please Run the script Root Access $N "
    exit 1
else 
    echo -e " You are a root user "
fi

dnf install mysql-server -y  &>> $LOGFILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld  &>> $LOGFILE
VALIDATE $? "Enable mysql server"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting mysql server "

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" &>> $LOGFILE
VALIDATE $? "Setting mysql root password "