# ! /bin/bash
# Just to fill DB with some data and then run benchmark
# Not fast and safe, but work for me

# Repeat quantity
echo -n "Please, enter numbers of query repeat: "
read repeatQ
scalar=`eval echo {1..$repeatQ}`

# MySQL connection settings
echo -n "Please, enter user name for MySQL: "
read username

echo -n	"Please, enter password for MySQL: "
read password

echo -n	"Please, enter host for MySQL: "
read host

echo -n	"Please, enter database for MySQL: "
read database

# Query builder
echo -n "Enter your query. In query you can use placeholder ^ as a cycle number. Don't use double quotes: "
read query
for number in $scalar
do
# replace all placeholders
commands+=${query//^/$number}
done

# prepare connection
connection="mysql"
if [ "$username" ]
then
	connection+=" --user=$username"
fi
if [ "$password" ]
then 
        connection+=" --password=$password"
fi
if [ "$host" ]
then 
        connection+=" --host=$host"
fi
if [ "$database" ]
then 
        connection+=" $database"
fi

echo "Connection formed
Work on $repeatQ queries"

# Run queries
$connection << EOF
$commands
EOF

echo "Done"
