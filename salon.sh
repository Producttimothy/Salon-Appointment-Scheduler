#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_ID") 
  
  if [[ -z $SERVICES ]]
  then 
  echo -e  "\nI could not find that service. What would you like today?\n"
  else 
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do echo "$SERVICE_ID) $NAME"
    done

    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then 
    MAIN_MENU "\nI could not find that service. What would you like today?\n"
    else
      SERV_AVAIL=$($PSQL " SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      NAME_CUS=$($PSQL " SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERV_AVAIL ]]
      then 
      MAIN_MENU "\nI could not find that service. What would you like today?\n"
      else 
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL " SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
        echo "I don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RES=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 

        fi
      echo -e "\nWhat time would you like your $NAME_CUS, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ $SERVICE_TIME ]]
      then
        INS_SERV_RES=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        if [[ $INS_SERV_RES ]]
        then 
         echo -e "\nI have put you down for a $NAME_CUS at $SERVICE_TIME, $CUSTOMER_NAME."
          fi
        fi
      fi
    fi
  fi
}

MAIN_MENU