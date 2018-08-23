#!/bin/bash
function getInformationProject {
	printf "host name: (localhost) "
	read host
	if [ "${host}" = "" ]
		then
				host='localhost'
	fi
	printf "database name: (api) "
	read database
	if [ "${database}" = "" ]
		then
				database='api'
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

function replaceValueOfFile {
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
	mv CodeIgniter-3.1.9/ api/
	rm -rf api/contributing.md
	rm -rf api/readme.rst
	rm -rf api/user_guide
	rm -rf api/license.txt
	sed -i -e "s%\[\'base_url\'\] = \'\'%\[\'base_url\'\] = \'http:\/\/\'.\$_SERVER\[\'HTTP_HOST\'\].\'\/api\/\'%g" api/application/config/config.php
	cp -r codeigniter-restserver-master/application/* api/application/
	rm -rf codeigniter-restserver-master
	rm -rf api/application/config/*-e
	rm -rf api/application/config/*.sample
	wget -v http://github.com/firebase/php-jwt/archive/master.zip
	unzip master.zip
	rm -rf master.zip
	mv php-jwt-master/ php-jwt/
	rm -rf php-jwt/composer.json
	rm -rf php-jwt/README.md
	rm -rf php-jwt/LICENSE
	mv php-jwt/src/* php-jwt/src/..
	rm -rf php-jwt/src/
	mkdir api/application/third_party/php-jwt
	cp -r php-jwt/ api/application/third_party/php-jwt
	rm -rf php-jwt
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
	sed -i -e "s%\[\'base_url\'\] = \'\'%\[\'base_url\'\] = \'http:\/\/localhost\/api\/\'%g" api/application/config/config.php
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

function removeView {
	rm -rf api/application/controllers/Rest_server.php
	rm -rf api/application/controllers/Welcome.php
	rm -rf api/application/views/rest_server.php
	rm -rf api/application/views/welcome_message.php
	replaceValueOfFile "api/application/config/routes.php" "\$route\[\'default_controller\'\] = \'welcome\';" "\$route\[\'default_controller\'\] = \'\';"
}

function configHtaccess {
	touch api/.htaccess
	echo "RewriteEngine On" >> api/.htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-f" >> api/.htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-d" >> api/.htaccess
	echo "RewriteRule ^(.*)$ index.php/\$1 [L]" >> api/.htaccess 
}

function configDatabase {
	replaceValueOfFile "api/application/config/database.php" "\'hostname\' => \'localhost\'" "\'hostname\' => \'$host\'"
	replaceValueOfFile "api/application/config/database.php" "\'username\' => \'\'" "\'username\' => \'$user\'"
	replaceValueOfFile "api/application/config/database.php" "\'password\' => \'\'" "\'password\' => \'$password\'"
	replaceValueOfFile "api/application/config/database.php" "\'database\' => \'\'" "\'database\' => \'$database\'"
	replaceValueOfFile "api/application/config/autoload.php" "\'libraries\'\] = array();" "\'libraries\'\] = array(\'database\', \'form_validation\');" 
	#/Applications/MAMP/Library/bin/mysql --user=$user --password=$password --host=$host --execute='use '$database'; CREATE TABLE `keys` (`id` int(11) NOT NULL,`key` TEXT NOT NULL,`level` int(2) NOT NULL,`ignore_limits` tinyint(1) NOT NULL DEFAULT 0,`is_private_key` tinyint(1) NOT NULL DEFAULT 0,`ip_addresses` text,`date_created` int(11) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `logs` (`id` int(11) NOT NULL,`uri` varchar(255) NOT NULL,`method` varchar(6) NOT NULL,`params` text,`api_key` varchar(40) NOT NULL,`ip_address` varchar(45) NOT NULL,`time` int(11) NOT NULL,`rtime` float DEFAULT NULL,`authorized` varchar(1) NOT NULL,`response_code` smallint(3) DEFAULT 0) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `users` (`id` int(11) NOT NULL,`username` varchar(15) NOT NULL,`email` varchar(100) NOT NULL,`password` longtext CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,`full_name` text NOT NULL,`created_at` text NOT NULL,`updated_at` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8; ALTER TABLE `users` ADD PRIMARY KEY (`id`); ALTER TABLE `users` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT; CREATE TABLE `limits` (`id` INT(11) NOT NULL AUTO_INCREMENT,`uri` VARCHAR(255) NOT NULL,`count` INT(10) NOT NULL,`hour_started` INT(11) NOT NULL,`api_key` VARCHAR(40) NOT NULL,PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;'
	/Applications/MAMP/Library/bin/mysql --user=$user --password=$password --host=$host --execute='CREATE DATABASE IF NOT EXISTS '$database'; USE '$database'; CREATE TABLE `logs` (`id` int(11) NOT NULL,`uri` varchar(255) NOT NULL,`method` varchar(6) NOT NULL,`params` text,`api_key` varchar(40) NOT NULL,`ip_address` varchar(45) NOT NULL,`time` int(11) NOT NULL,`rtime` float DEFAULT NULL,`authorized` varchar(1) NOT NULL,`response_code` smallint(3) DEFAULT 0) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `users` (`id` int(11) NOT NULL,`username` varchar(15) NOT NULL,`email` varchar(100) NOT NULL,`password` longtext CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,`full_name` text NOT NULL,`created_at` text NOT NULL,`updated_at` text NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8; ALTER TABLE `users` ADD PRIMARY KEY (`id`); ALTER TABLE `users` MODIFY `id` int(11) NOT NULL AUTO_INCREMENT; CREATE TABLE `limits` (`id` INT(11) NOT NULL AUTO_INCREMENT,`uri` VARCHAR(255) NOT NULL,`count` INT(10) NOT NULL,`hour_started` INT(11) NOT NULL,`api_key` VARCHAR(40) NOT NULL,PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8; CREATE TABLE `api_tokens` (`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,`token` TEXT NOT NULL,`created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,PRIMARY KEY (`id`))'
}

function configAuth {
	#sed -i -e "s%rest_enable_keys\'\] = FALSE;%rest_enable_keys\'\] = TRUE;%g" api/application/config/rest.php
	#sed -i -e "s%rest_auth\'\] = FALSE;%rest_auth\'\] = \'basic\';%g" api/application/config/rest.php
	#replaceValueOfFile "api/application/config/rest.php" "rest_logs_table\'\] = \'logs\';" "rest_logs_table\'\] = \'logs\';" 
	replaceValueOfFile "api/application/config/rest.php" "rest_auth\'\] = FALSE;" "rest_auth\'\] = \'token\';"
	ex -sc "202i|\$config['auth_override_class_method_http']['auth']['*']['post'] = 'none';" -cx api/application/config/rest.php
	ex -sc "203i|\$config['auth_override_class_method_http']['users']['*']['post'] = 'none';" -cx api/application/config/rest.php
	replaceValueOfFile "api/application/config/rest.php" "auth_source\'\] = \'ldap\';" "auth_source\'\] = \'\';" 
	replaceValueOfFile "api/application/config/rest.php" "rest_enable_logging\'\] = FALSE;" "rest_enable_logging\'\] = TRUE;"
	replaceValueOfFile "api/application/controllers/api/Key.php" "\/\/ This can be removed if you use __autoload() in config.php OR use Modular Extensions" "require APPPATH . \'libraries\/REST_Controller.php\';"
	replaceValueOfFile "api/application/controllers/api/Key.php" "\/\*\* \@noinspection PhpIncludeInspection \*\/" "require APPPATH . \'libraries\/Format.php\';"
	replaceValueOfFile "api/application/config/rest.php" "\$config\[\'rest_enable_limits\'\] = FALSE;" "\$config\[\'rest_enable_limits\'\] = TRUE;"
}


function configJWT {
    fileJWT='api/application/config/jwt.php'
    touch $fileJWT
    echo "
        <?php

        defined('BASEPATH') OR exit('No direct script access allowed');

        /*
        |--------------------------------------------------------------------------
        | JWT Secure Key
        |--------------------------------------------------------------------------
        */
        \$config['jwt_key'] = 'eyJ0eXAiOiJKV1QiLCJhbGciTWvLUzI1NiJ9IiRkYXRhIg';
        /*
        |--------------------------------------------------------------------------
        | JWT Algorithm Type
        |--------------------------------------------------------------------------
        */
        \$config['jwt_algorithm'] = 'HS256';
    " >> $fileJWT
}

function configProjectToAcceptJWTAsDefaultAutentication {
    ex -sc "584i|   case 'token':" -cx api/application/libraries/REST_Controller.php
    ex -sc "585i|       \$this->_check_token();" -cx api/application/libraries/REST_Controller.php
    ex -sc "586i|   break;" -cx api/application/libraries/REST_Controller.php
    ex -sc "2365i| " -cx api/application/libraries/REST_Controller.php
    ex -sc "2366i|   /** Check to see if the user is logged in with a token" -cx api/application/libraries/REST_Controller.php
    ex -sc "2367i|    * @access protected" -cx api/application/libraries/REST_Controller.php
    ex -sc "2368i|    */" -cx api/application/libraries/REST_Controller.php
    ex -sc "2369i|    protected function _check_token () {" -cx api/application/libraries/REST_Controller.php
    ex -sc "2370i|       if (!empty(\$this->_args[\$this->config->item('rest_token_name')])" -cx api/application/libraries/REST_Controller.php
    ex -sc "2371i|           && \$row = \$this->rest->db->where('token', \$this->_args[\$this->config->item('rest_token_name')])->get(\$this->config->item('rest_tokens_table'))->row()) {" -cx api/application/libraries/REST_Controller.php
    ex -sc "2372i|          \$this->api_token = \$row;" -cx api/application/libraries/REST_Controller.php
    ex -sc "2373i|       } else {" -cx api/application/libraries/REST_Controller.php
    ex -sc "2374i|           \$this->response([" -cx api/application/libraries/REST_Controller.php
    ex -sc "2375i|           \$this->config->item('rest_status_field_name') => FALSE," -cx api/application/libraries/REST_Controller.php
    ex -sc "2376i|           \$this->config->item('rest_message_field_name') => \$this->lang->line('text_rest_unauthorized')" -cx api/application/libraries/REST_Controller.php
    ex -sc "2377i|                               ], self::HTTP_UNAUTHORIZED);" -cx api/application/libraries/REST_Controller.php
    ex -sc "2378i|                   }" -cx api/application/libraries/REST_Controller.php
    ex -sc "2379i|               }" -cx api/application/libraries/REST_Controller.php
    echo "
// *** Tokens ***
/* Default table schema:
* CREATE TABLE \`api_tokens\` (
    \`id\` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    \`token\` TEXT NOT NULL,
    \`created\` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (\`id\`)
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
*/
\$config['rest_token_name'] = 'Authorization';
\$config['rest_tokens_table'] = 'api_tokens';
    " >> 'api/application/config/rest.php'
}


function configLibraryAuthorization {
    fileLibrary='api/application/libraries/Authorization_Token.php'
    touch $fileLibrary
    echo "
        <?php defined('BASEPATH') OR exit('No direct script access allowed');

/**
*   Authorization_Token
* -------------------------------------------------------------------
* API Token Check and Generate
*
* @author: Jeevan Lal
* @version: 0.0.5
*/

require_once APPPATH . 'third_party/php-jwt/JWT.php';
require_once APPPATH . 'third_party/php-jwt/BeforeValidException.php';
require_once APPPATH . 'third_party/php-jwt/ExpiredException.php';
require_once APPPATH . 'third_party/php-jwt/SignatureInvalidException.php';

use \Firebase\JWT\JWT;

class Authorization_Token {

    /**
     * Token Key
     */
    protected \$token_key;

    /**
     * Token algorithm
     */
    protected \$token_algorithm;

    /**
     * Request Header Name
     */
    protected \$token_header = ['authorization','Authorization'];

    /**
     * Token Expire Time
     * ----------------------
     * ( 1 Day ) : 60 * 60 * 24 = 86400
     * ( 1 Hour ) : 60 * 60     = 3600
     */
    protected \$token_expire_time = 86400; 


    public function __construct(){
        \$this->CI =& get_instance();

        /** 
         * jwt config file load
         */
        \$this->CI->load->config('jwt');

        /**
         * Load Config Items Values 
         */
        \$this->token_key        = \$this->CI->config->item('jwt_key');
        \$this->token_algorithm  = \$this->CI->config->item('jwt_algorithm');
    }

    /**
     * Generate Token
     * @param: user data
     */
    public function generateToken(\$data){
        try {
            return JWT::encode(\$data, \$this->token_key, \$this->token_algorithm);
        } catch(Exception \$e) {
            return 'Message: ' .\$e->getMessage();
        }
    }

    /**
     * Validate Token with Header
     * @return : user informations
     */
    public function validateToken() {
        /**
         * Request All Headers
         */
        \$headers = \$this->CI->input->request_headers();
        
        /**
         * Authorization Header Exists
         */
        \$token_data = \$this->tokenIsExist(\$headers);
        if(\$token_data['status'] === TRUE){
            try{
                /**
                 * Token Decode
                 */
                try {
                    \$token_decode = JWT::decode(\$headers[\$token_data['key']], \$this->token_key, array(\$this->token_algorithm));
                }catch(Exception \$e) {
                    return ['status' => FALSE, 'message' => \$e->getMessage()];
                }

                if(!empty(\$token_decode) AND is_object(\$token_decode)){
                    // Check User ID (exists and numeric)
                    if(empty(\$token_decode->id) OR !is_numeric(\$token_decode->id)) {
                        return ['status' => FALSE, 'message' => 'User ID Not Define!'];

                    // Check Token Time
                    }else if(empty(\$token_decode->time OR !is_numeric(\$token_decode->time))) {
                        
                        return ['status' => FALSE, 'message' => 'Token Time Not Define!'];
                    } else {
                        /**
                         * Check Token Time Valid 
                         */
                        \$time_difference = strtotime('now') - \$token_decode->time;
                        if( \$time_difference >= \$this->token_expire_time ){
                            return ['status' => FALSE, 'message' => 'Token Time Expire.'];

                        } else {
                            /**
                             * All Validation False Return Data
                             */
                            return ['status' => TRUE, 'data' => \$token_decode];
                        }
                    }
                }else{
                    return ['status' => FALSE, 'message' => 'Forbidden'];
                }
            } catch(Exception \$e) {
                return ['status' => FALSE, 'message' => \$e->getMessage()];
            }
        } else {
            // Authorization Header Not Found!
            return ['status' => FALSE, 'message' => \$token_data['message'] ];
        }
    }

    /**
     * Validate Token with POST Request
     */
    public function validateTokenPost()
    {
        if(isset(\$_POST['token']))
        {
            \$token = \$this->CI->input->post('token', TRUE);
            if(!empty(\$token) AND is_string(\$token) AND !is_array(\$token))
            {
                try
                {
                    /**
                     * Token Decode
                     */
                    try {
                        \$token_decode = JWT::decode(\$token, \$this->token_key, array(\$this->token_algorithm));
                    }
                    catch(Exception \$e) {
                        return ['status' => FALSE, 'message' => \$e->getMessage()];
                    }
    
                    if(!empty(\$token_decode) AND is_object(\$token_decode))
                    {
                        // Check User ID (exists and numeric)
                        if(empty(\$token_decode->id) OR !is_numeric(\$token_decode->id)) 
                        {
                            return ['status' => FALSE, 'message' => 'User ID Not Define!'];
    
                        // Check Token Time
                        }else if(empty(\$token_decode->time OR !is_numeric(\$token_decode->time))) {
                            
                            return ['status' => FALSE, 'message' => 'Token Time Not Define!'];
                        }
                        else
                        {
                            /**
                             * Check Token Time Valid 
                             */
                            \$time_difference = strtotime('now') - \$token_decode->time;
                            if( \$time_difference >= \$this->token_expire_time )
                            {
                                return ['status' => FALSE, 'message' => 'Token Time Expire.'];
    
                            }else
                            {
                                /**
                                 * All Validation False Return Data
                                 */
                                return ['status' => TRUE, 'data' => \$token_decode];
                            }
                        }
                        
                    }else{
                        return ['status' => FALSE, 'message' => 'Forbidden'];
                    }
                }
                catch(Exception \$e) {
                    return ['status' => FALSE, 'message' => \$e->getMessage()];
                }
            }else
            {
                return ['status' => FALSE, 'message' => 'Token is not defined.' ];
            }
        } else {
            return ['status' => FALSE, 'message' => 'Token is not defined.'];
        }
    }

    /**
     * Token Header Check
     * @param: request headers
     */
    public function tokenIsExist(\$headers)
    {
        if(!empty(\$headers) AND is_array(\$headers)) {
            foreach (\$this->token_header as \$key) {
                if (array_key_exists(\$key, \$headers) AND !empty(\$key))
                    return ['status' => TRUE, 'key' => \$key];
            }
        }
        return ['status' => FALSE, 'message' => 'Token is not defined.'];
    }

    /**
     * Fetch User Data
     * -----------------
     * @param: token
     * @return: user_data
     */
    public function userData()
    {
        /**
         * Request All Headers
         */
        \$headers = \$this->CI->input->request_headers();

        /**
         * Authorization Header Exists
         */
        \$token_data = \$this->tokenIsExist(\$headers);
        if(\$token_data['status'] === TRUE)
        {
            try
            {
                /**
                 * Token Decode
                 */
                try {
                    \$token_decode = JWT::decode(\$headers[\$token_data['key']], \$this->token_key, array(\$this->token_algorithm));
                }
                catch(Exception \$e) {
                    return ['status' => FALSE, 'message' => \$e->getMessage()];
                }

                if(!empty(\$token_decode) AND is_object(\$token_decode))
                {
                    return \$token_decode;
                }else{
                    return ['status' => FALSE, 'message' => 'Forbidden'];
                }
            }
            catch(Exception \$e) {
                return ['status' => FALSE, 'message' => \$e->getMessage()];
            }
        }else
        {
            // Authorization Header Not Found!
            return ['status' => FALSE, 'message' => \$token_data['message'] ];
        }
    }
}
    " >> $fileLibrary
}

function configModelAuth {
    fileModel='api/application/models/auth_model.php'
    touch $fileModel
    echo "
        <?php

        defined('BASEPATH') OR exit('No direct script access allowed');

        class Auth_model extends CI_Model {

            public function login(\$email, \$password){
                \$this->db->where('email',\$email);
                \$this->db->where('password',\$password);
                \$user = \$this->db->get('users');
                if(\$user->num_rows() > 0){
                    \$dbPassword = \$user->row('password');
                    if(\$dbPassword === \$password){
                        return \$user->row();
                    } else {
                        return FALSE;
                    }
                } else {
                    return FALSE;
                }
            }

        }
    " >> $fileModel
}

function configControllerAuth {
    fileController='api/application/controllers/Auth.php'
    touch $fileController
    echo "
        <?php

        use Restserver\Libraries\REST_Controller;

        defined('BASEPATH') or exit('No direct script access allowed');

        require APPPATH . 'libraries/REST_Controller.php';
        require APPPATH . 'libraries/Format.php';

        class Auth extends REST_Controller {

            public function __construct() {
                parent::__construct();
                \$this->load->model('auth_model');
            }

            public function index_post(){
                \$this->form_validation->set_rules('email', 'Email', 'trim|required|valid_email|max_length[80]');
                \$this->form_validation->set_rules('password', 'Password', 'trim|required|max_length[100]');

                \$email = \$this->post('email');
                \$password = md5(\$this->post('password'));

                if(\$this->form_validation->run() == FALSE){
                    \$r=array(
                        'status' => FALSE, 
                        'error' => \$this->form_validation->error_array(), 
                        'message' => validation_errors()
                    );
                    \$this->response(\$r, REST_Controller::HTTP_BAD_REQUEST); 
                } else {
                    \$resultLogin = \$this->auth_model->login(\$email,\$password);
                    if(!empty(\$resultLogin) AND \$resultLogin != FALSE){
                        \$this->load->library('Authorization_Token');
                        \$tokenData['id'] = \$resultLogin->id;
                        \$tokenData['full_name'] = \$resultLogin->full_name;
                        \$tokenData['username'] = \$resultLogin->username;
                        \$tokenData['email'] = \$resultLogin->email;
                        \$tokenData['created_at'] = \$resultLogin->created_at;
                        \$tokenData['updated_at'] = \$resultLogin->updated_at;
                        \$tokenData['time'] = time();
                        \$token = \$this->authorization_token->generateToken(\$tokenData);

                        if (\$this->_insert_key(\$token)){
                            \$returnData = array(
                                'id' => \$resultLogin->id,
                                'username' => \$resultLogin->username,
                                'email' => \$resultLogin->email,
                                'full_name' => \$resultLogin->full_name,
                                'token' => \$token
                            );
                            \$r=array(
                                'status' => TRUE, 
                                'data' => \$returnData,
                                'message' => 'User logged with successfull!'
                            );
                            \$this->response(\$r, REST_Controller::HTTP_OK);
                        } else {
                            \$r=array(
                                'status' => FALSE, 
                                'message' => 'Token is not generated!'
                            );
                            \$this->response(\$r, REST_Controller::HTTP_BAD_REQUEST);
                        }
                    } else {
                        \$r=array(
                            'status' => FALSE, 
                            'message' => 'Invalid email or password!'
                        );
                        \$this->response(\$r, REST_Controller::HTTP_BAD_REQUEST);
                    }
                    
                }
            }

            private function _insert_key(\$key){
                \$data['token'] = \$key;
                \$data['created'] = date('Y-m-d h:i:s');

                return \$this->rest->db
                    ->set(\$data)
                    ->insert(config_item('rest_tokens_table'));
            }
        }
    " >> $fileController
}

function openProject {
	open http://localhost/rest
}

function createControllerUser {
	cd ..
	COMMAND="$(pwd)/./creator.sh Users"
	$COMMAND
}

function main {
	getInformationProject 
	configProject
	configHtaccess 
	configDatabase
	configAuth 
	removeView
	configJWT
	configLibraryAuthorization
	configProjectToAcceptJWTAsDefaultAutentication
	configControllerAuth
	configModelAuth
	createControllerUser
	#openProject
}

main

#https://stackoverflow.com/questions/43406721/token-based-authentication-in-codeigniter-rest-server-library