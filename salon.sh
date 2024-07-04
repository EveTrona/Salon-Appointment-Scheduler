#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"



MAIN_MENU() {
  if [[ $1 ]]
  then echo -e "\n$1"
  else
    echo -e "\n~~~~~ MY SALON ~~~~~\n"
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi
  SHOW_SERVICE_LIST
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1) NEXT_MENU $SERVICE_ID_SELECTED 'cut';;
    2) NEXT_MENU $SERVICE_ID_SELECTED 'color';;
    3) NEXT_MENU $SERVICE_ID_SELECTED 'perm';;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

SHOW_SERVICE_LIST () {
  #get service 
  SERVICE=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICE" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

NEXT_MENU () {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ ! -z $CUSTOMER_ID ]]
  then
    #get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your $2, $CUSTOMER_NAME?"
    read SERVICE_TIME
    echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
    EXIT
  else
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    CUSTOMER_NAME_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    #get customer id after insert
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your $2, $CUSTOMER_NAME?"
    read SERVICE_TIME
    APPOINTMENTS_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
    EXIT
  fi
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU