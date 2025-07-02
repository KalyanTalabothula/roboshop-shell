#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? " Downloading erlang script"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? " Downloading rabbitmq script"

dnf install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? " Installing RabbitMQ server"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? " Enabling RabbitMQ server "

systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? " Starting RabbitMQ server "

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? " Creating user "

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? " Setting permission "