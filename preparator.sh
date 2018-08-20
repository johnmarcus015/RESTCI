#!/bin/bash
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
	wget -v http://github.com/firebase/php-jwt/archive/master.zip
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
	mv php-jwt-master/ php-jwt/
	rm -rf php-jwt/composer.json
	rm -rf php-jwt/README.md
	rm -rf php-jwt/LICENSE
	mv php-jwt/src/* php-jwt/src/..
	mkdir api/application/third_party/php-jwt
	cp -r php-jwt/ api/application/third_party/php-jwt
	rm -rf php-jwt
	cd api/
	touch .htaccess
	echo "RewriteEngine On" >> .htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-f" >> .htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-d" >> .htaccess
	echo "RewriteRule ^(.*)$ index.php/\$1 [L]" >> .htaccess 
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

function configDatabase {
	echo "-> Type HOST of mysql:"
	read host
	echo "-> Type USER of mysql:"
	read user
	echo "-> Type PASSWORD of mysql:"
	read -s password
	echo "-> Type DATABASE of mysql:"
	read database
	sed -i -e "s%\'hostname\' => \'localhost\'%\'hostname\' => \'$host\'%g" application/config/database.php
	sed -i -e "s%\'username\' => \'\'%\'username\' => \'$user\'%g" application/config/database.php
	sed -i -e "s%\'password\' => \'\'%\'password\' => \'$password\'%g" application/config/database.php
	sed -i -e "s%\'database\' => \'\'%\'database\' => \'$database\'%g" application/config/database.php
	sed -i -e "s%\'libraries\'\] = array();%\'libraries\'\] = array(\'database\', \'form_validation\');%g" application/config/autoload.php
	/Applications/MAMP/Library/bin/mysql --user=$user --password=$password --host=$host --execute='use '$database'; CREATE TABLE `keys` (`id` int(11) NOT NULL,`key` varchar(40) NOT NULL,`level` int(2) NOT NULL,`ignore_limits` tinyint(1) NOT NULL DEFAULT 0,`is_private_key` tinyint(1) NOT NULL DEFAULT 0,`ip_addresses` text,`date_created` int(11) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `logs` (`id` int(11) NOT NULL,`uri` varchar(255) NOT NULL,`method` varchar(6) NOT NULL,`params` text,`api_key` varchar(40) NOT NULL,`ip_address` varchar(45) NOT NULL,`time` int(11) NOT NULL,`rtime` float DEFAULT NULL,`authorized` varchar(1) NOT NULL,`response_code` smallint(3) DEFAULT 0) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `users` (`id` int(11) NOT NULL,`username` varchar(15) NOT NULL,`email` varchar(100) NOT NULL,`password` longtext CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,`full_name` text NOT NULL,`created_at` text NOT NULL,`updated_at` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8; ALTER TABLE `users` ADD PRIMARY KEY (`id`); ALTER TABLE `users` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;'
}

replaceValueOfFile(){
    FILE_NAME=$1
    FILE__OLD_VALUE=$2
    FILE__NEW_VALUE=$3

    cat $FILE_NAME | grep "${FILE__OLD_VALUE}" | sed "s/${FILE__OLD_VALUE}/${FILE__NEW_VALUE}/g" < $FILE_NAME > aux.php
    cat aux.php < aux.php > $FILE_NAME
    rm aux.php
}

function configAuth {
	#sed -i -e "s%rest_enable_keys\'\] = FALSE;%rest_enable_keys\'\] = TRUE;%g" application/config/rest.php
	sed -i -e "s%rest_logs_table\'\] = \'logs\';%rest_logs_table\'\] = \'logs\';%g" application/config/rest.php
	#sed -i -e "s%rest_auth\'\] = FALSE;%rest_auth\'\] = \'basic\';%g" application/config/rest.php
	sed -i -e "s%auth_source\'\] = \'ldap\';%auth_source\'\] = \'\';%g" application/config/rest.php
	sed -i -e "s%rest_enable_logging\'\] = FALSE;%rest_enable_logging\'\] = TRUE;%g" application/config/rest.php
	replaceValueOfFile "application/controllers/api/Key.php" "\/\/ This can be removed if you use __autoload() in config.php OR use Modular Extensions" "require APPPATH . \'libraries\/REST_Controller.php\';"
	replaceValueOfFile "application/controllers/api/Key.php" "\/\*\* \@noinspection PhpIncludeInspection \*\/" "require APPPATH . \'libraries\/Format.php\';"
}

function openProject {
	open http://localhost/rest
}

function createControllerUser {
	cd ..
	COMMAND="$(pwd)/./creator.sh Users"
	$COMMAND
}


configProject
configDatabase
configAuth
createControllerUser
#openProject