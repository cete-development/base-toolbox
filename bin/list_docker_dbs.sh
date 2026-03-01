#!/bin/bash

CONTAINER="maria_db"        # change to your container name
DB_USER="root"
DB_PASS="yourpassword"     # change this

read -s -p "Enter DB name: " CONTAINER
echo ""

read -s -p "Enter DB password: " DB_PASS
echo ""

echo "Databases and tables inside container: $CONTAINER"
echo "--------------------------------------------------"

# Get all database names (excluding system DBs)
DATABASES=$(docker exec -e MYSQL_PWD="$DB_PASS" "$CONTAINER" \
  mysql -u "$DB_USER" -N -e "SHOW DATABASES;" | \
  grep -Ev "^(information_schema|performance_schema|mysql|sys)$")

for DB in $DATABASES; do
  echo ""
  echo "Database: $DB"
  echo "Tables:"
  
  docker exec -e MYSQL_PWD="$DB_PASS" "$CONTAINER" \
    mysql -u "$DB_USER" -N -e "SHOW TABLES FROM \`$DB\`;" | sed 's/^/  - /'
done

echo ""
echo "Done."