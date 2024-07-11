#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo "$SERVICES"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # show services
  echo -e "\nOur services"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME" 
  done
  echo Choose the service you want to appoint: 
  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services where service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTED ]]
  then
  MAIN_MENU "Please choose a valid option"
  else
  # request phone
  echo Enter your phone number:
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
  echo Enter your name:
  read CUSTOMER_NAME
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # set appointment
  echo What time do you want to reserve?
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(service_id,customer_id,time) VALUES($SERVICE_ID_SELECTED,$CUSTOMER_ID,'$SERVICE_TIME')")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_INFO_FORMATTED=$(echo $SERVICE_NAME | sed 's/ |/"/')
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ |/"/')
  echo "I have put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}

echo -e "\n~~~~~ Salon ~~~~~\n"
MAIN_MENU
