#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"


MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "select service_id, name from services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    # Gets the service name for info menu
      SERV_NAME=$($PSQL "select name from services where service_id = '$SERVICE_ID_SELECTED'")
  fi
  

  case $SERVICE_ID_SELECTED in
  1|2|3|4|5) INFO_MENU $SERV_NAME $SERVICE_ID_SELECTED ;;
  *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

INFO_MENU(){

  SERVICE_NAME=$1

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  ID_PHONE=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE' ")
  echo -e "$ID_PHONE"

  if [[ -z $ID_PHONE ]]
  then
    # Phone number not in system
    echo -e "\nI don't have a record for that phoner number, what's your name?"
    read CUSTOMER_NAME
    MAKE_RECORD=$($PSQL "insert into customers (name, phone) values ('$CUSTOMER_NAME', '$CUSTOMER_PHONE') ")
  fi

  CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE' ")
  echo -e "What time would you like your $1,$CUSTOMER_NAME?"
  read SERVICE_TIME

  APPT_CUST=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE' ")
  APPT_SERV=$2
  INSERT_APPT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($APPT_CUST, $2, '$SERVICE_TIME') ")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME.\n"

}

MAIN_MENU
