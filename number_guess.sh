#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"
echo -e "\n~~~Number Guessing Game~~~"
NUMBER=$(($RANDOM % 1000 +1)) 
echo "Enter your username:"
read USERNAME
USERNAME_RESULT="$($PSQL "SELECT username FROM player WHERE username='$USERNAME'")"
if [[ -z $USERNAME_RESULT ]]
then
 echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
 INSERT_USER_RESULT="$($PSQL" INSERT INTO player(username,games_played) VALUES('$USERNAME',1);")"
 GAMES_PLAYED=0
 BEST_GAME="$($PSQL "SELECT best_game_guesses FROM player WHERE username='$USERNAME'")"
else
 GAMES_PLAYED="$($PSQL "SELECT games_played FROM player WHERE username ='$USERNAME'")"
 BEST_GAME="$($PSQL "SELECT best_game_guesses FROM player WHERE username='$USERNAME'")"
 echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESSED_NUMBER
while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
do
 echo -e "\nThat is not an integer, guess again:"
 read GUESSED_NUMBER
done
NUMBER_OF_GUESSES=1
while [ $GUESSED_NUMBER -ne $NUMBER ] 
do
 if [[ $GUESSED_NUMBER -gt $NUMBER ]] 
 then
  echo -e "\nIt's lower than that, guess again:"
  read GUESSED_NUMBER
  while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  do
   echo -e "\nThat is not an integer, guess again:"
   read GUESSED_NUMBER
  done
  (( NUMBER_OF_GUESSES=NUMBER_OF_GUESSES+1 ))
  fi
 if [[ $GUESSED_NUMBER -lt $NUMBER ]] 
 then
  echo -e "\nIt's higher than that, guess again:"
  read GUESSED_NUMBER
  while [[ ! $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  do
   echo -e "\nThat is not an integer, guess again:"
   read GUESSED_NUMBER
  done
  (( NUMBER_OF_GUESSES=NUMBER_OF_GUESSES+1 ))
  fi
done
(( GAMES_PLAYED=GAMES_PLAYED +1 ))
UPDATE_GAMES_RESULT="$($PSQL "UPDATE player SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")"
if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt  $BEST_GAME ]]
then
 UPDATE_BESTGAME_RESULT="$($PSQL "UPDATE player SET best_game_guesses=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")"
fi
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"


  