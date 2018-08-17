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
	mv CodeIgniter-3.1.9/ rest/
	rm -rf rest/contributing.md
	rm -rf rest/readme.rst
	rm -rf rest/user_guide
	rm -rf rest/license.txt
	sed -i -e "s%\[\'base_url\'\] = \'\'%\[\'base_url\'\] = \'http:\/\/localhost\/rest\/\'%g" rest/application/config/config.php
	cp -r codeigniter-restserver-master/application/* rest/application/
	#rm -rf codeigniter-restserver-master
	cp -r codeigniter-restclient-master/* rest/
	#rm -rf codeigniter-restclient-master
	cd rest/
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
	mv CodeIgniter/ rest/
	rm -rf rest/contributing.md
	rm -rf rest/readme.rst
	rm -rf rest/user_guide
	rm -rf rest/license.txt
	sed -i -e "s%\[\'base_url\'\] = \'\'%\[\'base_url\'\] = \'http:\/\/localhost\/rest\/\'%g" rest/application/config/config.php
	cp -r codeigniter-restserver/application/* rest/application/
	rm -rf codeigniter-restserver
	cp -r codeigniter-restclient/* rest/
	rm -rf codeigniter-restclient
	cd rest/
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
	sed -i -e "s%\'libraries\'\] = array();%\'libraries\'\] = array(\'database\');%g" application/config/autoload.php
	/Applications/MAMP/Library/bin/mysql --user=$user --password=$password --host=$host --execute='use '$database'; CREATE TABLE `user` (`user_id` int(11) NOT NULL,`user_name` varchar(40) NOT NULL,`user_password` varchar(40) NOT NULL,`user_type` varchar(15) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `keys` (`id` int(11) NOT NULL,`key` varchar(40) NOT NULL,`level` int(2) NOT NULL,`ignore_limits` tinyint(1) NOT NULL DEFAULT 0,`is_private_key` tinyint(1) NOT NULL DEFAULT 0,`ip_addresses` text,`date_created` int(11) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `logs` (`id` int(11) NOT NULL,`uri` varchar(255) NOT NULL,`method` varchar(6) NOT NULL,`params` text,`api_key` varchar(40) NOT NULL,`ip_address` varchar(45) NOT NULL,`time` int(11) NOT NULL,`rtime` float DEFAULT NULL,`authorized` varchar(1) NOT NULL,`response_code` smallint(3) DEFAULT 0) ENGINE=InnoDB DEFAULT CHARSET=utf8;'
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
	sed -i -e "s%rest_enable_keys\'\] = FALSE;%rest_enable_keys\'\] = TRUE;%g" application/config/rest.php
	sed -i -e "s%rest_logs_table\'\] = \'logs\';%rest_logs_table\'\] = \'logs\';%g" application/config/rest.php
	sed -i -e "s%rest_auth\'\] = FALSE;%rest_auth\'\] = \'basic\';%g" application/config/rest.php
	sed -i -e "s%auth_source\'\] = \'ldap\';%auth_source\'\] = \'\';%g" application/config/rest.php
	sed -i -e "s%rest_enable_logging\'\] = FALSE;%rest_enable_logging\'\] = TRUE;%g" application/config/rest.php
	replaceValueOfFile "application/controllers/api/Key.php" "\/\/ This can be removed if you use __autoload() in config.php OR use Modular Extensions" "require APPPATH . \'libraries\/REST_Controller.php\';"
	replaceValueOfFile "application/controllers/api/Key.php" "\/\*\* \@noinspection PhpIncludeInspection \*\/" "require APPPATH . \'libraries\/Format.php\';"
}

function openProject {
	open http://localhost/rest
}



configProject
configDatabase
configAuth
#openProject