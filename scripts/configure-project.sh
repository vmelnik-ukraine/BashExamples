# ! /bin/bash
# For fedora 17
# Configure new project and restart apache. Works, but not completed yet.

# config
hostsFile="/etc/hosts"
httpdConfFile="/etc/httpd/conf/httpd.conf"

documentRoot=`pwd`
logsDirectory="logs"

# Checks permissions to config files
function checkPermissions {
	echo "Checking permissions"
	if [ -w $hostsFile -a -w $httpdConfFile ]
	then
		echo "Permissions are ok"
	else
		echo "Can't write to config files
Please, run this script as user who has write permission to next files:
$hostsFile
$httpdConfFile"
		exit 1
	fi	
}


# Check if project name already used and if not - make it current project
function setupProjectName {
	echo -n "Please, specify project name: "
	read projectName
	if [ "$projectName" ]
	then
		echo "Checking files..."
       		if [ "`cat $hostsFile | grep $projectName$`" -o "`cat $httpdConfFile | grep "ServerName $projectName$"`" ]
        	then
                	echo "Records already exists, try again"
                	setupProjectName
		else
			echo "No matches, good news"
        	fi
	else
    		echo "Project name can't be empty, try again"
        	setupProjectName
	fi
}

# Configure email
function setupEmail {
	echo -n "Please, enter admin email: "
	read email
	if [ -z "$email" ]
	then
		echo "Email can't be empty, try again"
		setupEmail
	fi	
}

# Configure document root directory for project
function setupDocumentRoot {
	echo -n "Is '$documentRoot' a project root directory? [yes/no]: "
	read answer
	if [ "$answer" = "no" ]
	then
		echo -n "Please, enter a document root directory: "
		read tmpDocumentRoot
		if [ -z "$tmpDocumentRoot" ]
		then
			echo "Document root directory can't be empty, try again"
			setupDocumentRoot
		else
			let documentRoot=tmpDocumentRoot
		fi
	fi
}

# Configure logs directory
function setupLogsDirectory {
	echo -n "Is '$logsDirectory' a logs directory? [yes/no]: "
        read answer
        if [ "$answer" = "no" ]
        then
            	echo -n "Please, enter a logs directory: "
                read tmpLogsDirectory
                if [ -z "$tmpLogsDirectory" ]
                then
                    	echo "Logs directory can't be empty, try again"
                        setupLogsDirectory
		else
			let logsDirectory=tmpLogsDirectory
                fi
        fi
}

# Configure project
function configureProject {
	echo "First you need to configure project"
	setupProjectName
	setupEmail
	setupDocumentRoot
	setupLogsDirectory
	echo "Configuration completed"
}

# Adds record to /etc/hosts
function configureHosts {
	echo "Adding record to $hostsFile..."
        echo "127.0.0.1 $projectName" >> $hostsFile
	echo "Done"
}

# Adds record to virtual hosts
function configureHttpd {
	echo "Adding record to $httpdConfFile..."
	echo "<VirtualHost *:80>
    ServerAdmin $email
    DocumentRoot $documentRoot
    ServerName $projectName
    ErrorLog $logsDirectory/$projectName
</VirtualHost>" >> $httpdConfFile
	echo "Done"
}

# Restarting apache
function restartHttpd {
	echo "Restarting apache..."
	service httpd restart
	echo "Done"
}


# run script
checkPermissions
configureProject
configureHosts 
configureHttpd
restartHttpd
exit 0
