#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){

  echo -e "Welcome to My Salon, how can I help you?\n"

  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while read SERVICE_ID SERVICE_NAME
  do
    echo -e $SERVICE_ID $SERVICE_NAME | sed 's/ |/)/'
  done

  read SERVICE_ID_SELECTED

  # if service does not exist
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
  then
    # send to main menu
    MAIN_MENU "Sorry, that service doesn't exist, please pick another."
  else
    # ask for customer's phone number
    echo -e "\nWhat is your phone number?"

    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

    # if phone number does not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # ask for customer's name
      echo -e "\nI don't have a record of that phone number, what's your name?"

      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
    fi

    # find service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")


    # make appointment
    echo -e "\nWhat time would you like your appointment for your $(echo $SERVICE_NAME | sed -r 's/^ *//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"

    read SERVICE_TIME

    # find customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # input appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME');")

    echo -e "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

  fi

}

MAIN_MENU
