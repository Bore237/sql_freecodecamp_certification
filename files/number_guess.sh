#!/bin/bash

# Variable pour simplifier l'exécution des commandes psql
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

# Génération d'un nombre aléatoire entre 1 et 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Vérification de l'utilisateur dans la base de données
USER_DATA=$($PSQL "SELECT games_played, best_game FROM username WHERE name='$USERNAME';")

if [[ -z $USER_DATA ]]
then
  # Nouvel utilisateur
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
  BEST_GAME=0
else
  # Utilisateur existant
  IFS="|" read -r GAMES_PLAYED BEST_GAME <<< "$USER_DATA"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
TRIES=1

# Boucle de jeu
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
  
  read GUESS
  TRIES=$(( TRIES + 1 ))
done

# Message de victoire
echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Mise à jour des statistiques dans la base de données
NEW_GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

if [[ -z $USER_DATA ]]
then
  # Insérer le nouveau joueur avec ses stats du premier match
  INSERT_USER_RESULT=$($PSQL "INSERT INTO username(name, games_played, best_game) VALUES('$USERNAME', 1, $TRIES);")
else
  # Mettre à jour le joueur existant
  if [[ $BEST_GAME -eq 0 || $TRIES -lt $BEST_GAME ]]
  then
    UPDATE_USER_RESULT=$($PSQL "UPDATE username SET games_played=$NEW_GAMES_PLAYED, best_game=$TRIES WHERE name='$USERNAME';")
  else
    UPDATE_USER_RESULT=$($PSQL "UPDATE username SET games_played=$NEW_GAMES_PLAYED WHERE name='$USERNAME';")
  fi
fi