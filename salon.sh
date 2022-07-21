#! /bin/bash

PSQL='psql -X --username=freecodecamp --dbname=salon --tuples-only -c'

echo -e "\n~~~~~ Salon Shop ~~~~~~\n"

MAIN_MENU() {

  #get available services
  SERVICES=$($PSQL "SELECT * FROM services")

  echo -e "How may I help you?\n"


  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  echo -e "\nWhich service would you like to use?"
  read SERVICE_ID_SELECTED


  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid service number."
  else
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_AVAILABILITY  ]]
    then
      printf "\nSorry that service is unavailable\n"
      MAIN_MENU
    else
      printf "\nPlease enter your phone number: \n"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      if [[ -z $CUSTOMER_NAME ]]
      then
        printf "\nWhat's your name?\n"
        read CUSTOMER_NAME

        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers where phone = '$CUSTOMER_PHONE'")

      printf "\nWhat time would you like your appointment?\n"
      read SERVICE_TIME

      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      printf "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi

  fi

  
  #if [[ -z $SERVICE_AVAILABILITY ]]
  #then
  #  MAIN_MENU "That service is not available"
  #fi
}
MAIN_MENU


