#!/bin/bash
function getInformationProject {
	printf "autentication mode: ['t' - token, 'b' - basic, 'n' - no auth]('t')"
	read autentication
	if [ "${autentication}" = "" ]
		then
				autentication='token'
	elif ["${autentication}" = "t"]
		then
				autentication='token'
	elif ["${autentication}" = "b"]
		then
				autentication='basic'
	elif ["${autentication}" = "n"]
		then
				autentication='FALSE'
	fi
	printf "host name: (localhost) "
	read host
	if [ "${host}" = "" ]
		then
				host='localhost'
	fi
	printf "database name: (rest) "
	read database
	if [ "${database}" = "" ]
		then
				database='rest'
	fi
	printf "username: (root) "
	read user
	if [ "${user}" = "" ]
		then
				user='root'
	fi
	printf "password: (root) "
	read -s password
	if [ "${password}" = "" ]
		then
				password='root'
	fi
}

replaceValueOfFile(){
    FILE_NAME=$1
    FILE__OLD_VALUE=$2
    FILE__NEW_VALUE=$3

    cat $FILE_NAME | grep "${FILE__OLD_VALUE}" | sed "s/${FILE__OLD_VALUE}/${FILE__NEW_VALUE}/g" < $FILE_NAME > aux.php
    cat aux.php < aux.php > $FILE_NAME
    rm aux.php
}

function configProject {
	wget -v https://github.com/bcit-ci/CodeIgniter/archive/3.1.9.zip 
	unzip 3.1.9.zip
	rm -rf 3.1.9.zip
	wget -v https://github.com/chriskacerguis/codeigniter-restserver/archive/master.zip
	unzip master.zip
	rm -rf master.zip
	wget -v https://github.com/philsturgeon/codeigniter-restclient/archive/master.zip
	unzip master.zip
	rm -rf master.zip
	mv CodeIgniter-3.1.9/ api/
	rm -rf api/contributing.md
	rm -rf api/readme.rst
	rm -rf api/user_guide
	rm -rf api/license.txt
	sed -i -e "s%\[\'base_url\'\] = \'\'%\[\'base_url\'\] = \'http:\/\/\'.\$_SERVER\[\'HTTP_HOST\'\].\'\/api\/\'%g" api/application/config/config.php
	cp -r codeigniter-restserver-master/application/* api/application/
	rm -rf codeigniter-restserver-master
	cp -r codeigniter-restclient-master/* api/
	rm -rf codeigniter-restclient-master
	if [ "${autentication}" = "token" ]
	then
		wget -v http://github.com/firebase/php-jwt/archive/master.zip
		unzip master.zip
		rm -rf master.zip
		mv php-jwt-master/ php-jwt/
		rm -rf php-jwt/composer.json
		rm -rf php-jwt/README.md
		rm -rf php-jwt/LICENSE
		mv php-jwt/src/* php-jwt/src/..
		mkdir api/application/third_party/php-jwt
		cp -r php-jwt/ api/application/third_party/php-jwt
		rm -rf php-jwt
	fi
}

function configProject2 {
	git clone https://github.com/bcit-ci/CodeIgniter/
	git clone https://github.com/chriskacerguis/codeigniter-restserver/
	git clone https://github.com/philsturgeon/codeigniter-restclient/
	git clone https://github.com/firebase/php-jwt/
	mv CodeIgniter/ api/
	rm -rf api/contributing.md
	rm -rf api/readme.rst
	rm -rf api/user_guide
	rm -rf api/license.txt
	sed -i -e "s%\[\'base_url\'\] = \'\'%\[\'base_url\'\] = \'http:\/\/localhost\/rest\/\'%g" api/application/config/config.php
	cp -r codeigniter-restserver/application/* api/application/
	rm -rf codeigniter-restserver
	cp -r codeigniter-restclient/* api/
	rm -rf codeigniter-restclient
	cd api/
	touch .htaccess
	echo "RewriteEngine On" >> .htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-f" >> .htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-d" >> .htaccess
	echo "RewriteRule ^(.*)$ index.php/\$1 [L]" >> .htaccess 
}

function configHtaccess {
	cd api/
	touch .htaccess
	echo "RewriteEngine On" >> .htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-f" >> .htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-d" >> .htaccess
	echo "RewriteRule ^(.*)$ index.php/\$1 [L]" >> .htaccess 
}

function configDatabase {
	replaceValueOfFile "application/config/database.php" "\'hostname\' => \'localhost\'" "\'hostname\' => \'$host\'"
	replaceValueOfFile "application/config/database.php" "\'username\' => \'\'" "\'username\' => \'$user\'"
	replaceValueOfFile "application/config/database.php" "\'password\' => \'\'" "\'password\' => \'$password\'"
	replaceValueOfFile "application/config/database.php" "\'database\' => \'\'" "\'database\' => \'$database\'"
	replaceValueOfFile "application/config/autoload.php" "\'libraries\'\] = array();" "\'libraries\'\] = array(\'database\', \'form_validation\');" 
	/Applications/MAMP/Library/bin/mysql --user=$user --password=$password --host=$host --execute='use '$database'; CREATE TABLE `keys` (`id` int(11) NOT NULL,`key` TEXT NOT NULL,`level` int(2) NOT NULL,`ignore_limits` tinyint(1) NOT NULL DEFAULT 0,`is_private_key` tinyint(1) NOT NULL DEFAULT 0,`ip_addresses` text,`date_created` int(11) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `logs` (`id` int(11) NOT NULL,`uri` varchar(255) NOT NULL,`method` varchar(6) NOT NULL,`params` text,`api_key` varchar(40) NOT NULL,`ip_address` varchar(45) NOT NULL,`time` int(11) NOT NULL,`rtime` float DEFAULT NULL,`authorized` varchar(1) NOT NULL,`response_code` smallint(3) DEFAULT 0) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `users` (`id` int(11) NOT NULL,`username` varchar(15) NOT NULL,`email` varchar(100) NOT NULL,`password` longtext CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,`full_name` text NOT NULL,`created_at` text NOT NULL,`updated_at` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8; ALTER TABLE `users` ADD PRIMARY KEY (`id`); ALTER TABLE `users` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT; CREATE TABLE `limits` (`id` INT(11) NOT NULL AUTO_INCREMENT,`uri` VARCHAR(255) NOT NULL,`count` INT(10) NOT NULL,`hour_started` INT(11) NOT NULL,`api_key` VARCHAR(40) NOT NULL,PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;'
}

function configAuth {
	#sed -i -e "s%rest_enable_keys\'\] = FALSE;%rest_enable_keys\'\] = TRUE;%g" application/config/rest.php
	#sed -i -e "s%rest_auth\'\] = FALSE;%rest_auth\'\] = \'basic\';%g" application/config/rest.php
	#replaceValueOfFile "application/config/rest.php" "rest_logs_table\'\] = \'logs\';" "rest_logs_table\'\] = \'logs\';" 
	replaceValueOfFile "application/config/rest.php" "auth_source\'\] = \'ldap\';" "auth_source\'\] = \'\';" 
	replaceValueOfFile "application/config/rest.php" "rest_enable_logging\'\] = FALSE;" "rest_enable_logging\'\] = TRUE;"
	replaceValueOfFile "application/controllers/api/Key.php" "\/\/ This can be removed if you use __autoload() in config.php OR use Modular Extensions" "require APPPATH . \'libraries\/REST_Controller.php\';"
	replaceValueOfFile "application/controllers/api/Key.php" "\/\*\* \@noinspection PhpIncludeInspection \*\/" "require APPPATH . \'libraries\/Format.php\';"
	replaceValueOfFile "application/config/rest.php" "\$config\[\'rest_enable_limits\'\] = FALSE;" "\$config\[\'rest_enable_limits\'\] = TRUE;"
}

function openProject {
	open http://localhost/rest
}

function createControllerUser {
	cd ..
	COMMAND="$(pwd)/./creator.sh Users"
	$COMMAND
}

getInformationProject 
configProject
configHtaccess 
configDatabase
configAuth 
createControllerUser
#openProject
#https://stackoverflow.com/questions/43406721/token-based-authentication-in-codeigniter-rest-server-library