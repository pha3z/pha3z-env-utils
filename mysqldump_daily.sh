################################################################
##
##   MySQL Database Backup Script
##   Original By: Rahul Kumar
##   Modified by: James Houx
##
################################################################

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"Y%m%d"`

################################################################
################## Update below values  ########################

DB_BACKUP_PATH='/opt/prod_db_backups/backups'
MYSQL_PROD_HOST=''
MYSQL_PROD_PORT='3306'
MYSQL_PROD_USER='username'
MYSQL_PROD_PASSWORD=''
DATABASE_NAME='dbname'

#################################################################

mkdir -p ${DB_BACKUP_PATH}
echo "Backup started for database - ${DATABASE_NAME}"

SQL_FILE="${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.sql"

mysqldump -h ${MYSQL_PROD_HOST} \
   -P ${MYSQL_PROD_PORT} \
   -u ${MYSQL_PROD_USER} \
   -p${MYSQL_PROD_PASSWORD} \
   --databases ${DATABASE_NAME} --add-drop-database --routines=true  --column-statistics=0 --set-gtid-purged=OFF > "$SQL_FILE"

if [ $? -eq 0 ]; then
  echo "Database backup successfully completed"
else
  echo "Error found during backup"
  exit 1
fi

tar -zcvf "${SQL_FILE}.tar.gz" "$SQL_FILE"



### End of script ####