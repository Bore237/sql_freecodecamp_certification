#!/bin/bash

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

parse() {  
  echo "$1" | while IFS="|" read type_id atomic_number atomic_mass melting_point_celsius boiling_point_celsius  symbol name type
  do
    if [[ -z $atomic_number || -z $name ]]; then
    echo "I could not find that element in the database."
    exit 0
  fi
    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
  done
}

if [[ "$1" =~ ^-?[0-9]+$ ]]; then

    result=$(psql -U freecodecamp -d periodic_table -t -A -c "SELECT * FROM properties INNER JOIN elements USING (atomic_number) INNER JOIN types USING (type_id) WHERE atomic_number = $1;")
    parse $result

elif [[ ${#1} -le 2 ]]; then

    result=$(psql -U freecodecamp -d periodic_table -t -A -c "SELECT * FROM properties INNER JOIN elements USING (atomic_number) INNER JOIN types USING (type_id) WHERE symbol = '$1';")
    parse $result

elif  [[ $1 =~ ^[A-Z] ]]; then

  result=$(psql -U freecodecamp -d periodic_table -t -A -c "SELECT * FROM properties INNER JOIN elements USING (atomic_number) INNER JOIN types USING (type_id) WHERE name = '$1';")
    parse $result
else
  echo "I could not find that element in the database."
fi
