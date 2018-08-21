#!/bin/bash
function configController {
    fileController='application/controllers/'$ctrl'.php'
    touch $fileController
    echo "
        <?php

        use Restserver\Libraries\REST_Controller;

        defined('BASEPATH') or exit('No direct script access allowed');

        require APPPATH . 'libraries/REST_Controller.php';
        require APPPATH . 'libraries/Format.php';

        class "$ctrl" extends REST_Controller {

            public function __construct() {
                parent::__construct();
                \$this->methods['index_get']['limit'] = 5; // 500 requests per hour per user/key
                \$this->methods['index_post']['limit'] = 5; // 100 requests per hour per user/key
                \$this->methods['index_delete']['limit'] = 5; // 50 requests per hour per user/key

                \$this->load->model('"$ctrlM"_model');
                \$this->load->library('Authorization_Token');
                \$isTokenValid = \$this->authorization_token->validateToken();
                if (!empty(\$isTokenValid) and \$isTokenValid['status'] === true) {
                } else {
                    \$r = array(
                        'status' => false,
                        'message' => \$isTokenValid['message'],
                    );
                    \$this->response(\$r, REST_Controller::HTTP_BAD_REQUEST);
                }
            }

            public function index_get(){
                \$id = \$this->get('id');
                if (!empty(\$id)){
                    \$r = \$this->"$ctrlM"_model->readById(\$id);
                    if(count(\$r) == 0){
                        \$r=array(
                            'status' => FALSE, 
                            'message' => '"$ctrl" not found!'
                        );
                    }
                } else {
                    \$r = \$this->"$ctrlM"_model->read();
                    if(count(\$r) == 0){
                        \$r=array(
                            'status' => FALSE, 
                            'message' => 'No one "$ctrl" registered!'
                        );
                    }
                }
                \$this->response(\$r, REST_Controller::HTTP_OK); 
            }

            public function index_put(){

                \$_POST = json_decode(\$this->security->xss_clean(file_get_contents(\"php://input\")), true);

                \$id = \$this->input->post('id');
                \$username = \$this->input->post('username');
                \$email = \$this->input->post('email');
                \$password = \$this->input->post('password');
                \$fullName = \$this->input->post('full_name');

                \$this->form_validation->set_data([
                    'id' => \$id, 
                    'username' => \$username, 
                    'email' => \$email, 
                    'password' => \$password, 
                    'full_name' => \$fullName
                ]);

                \$this->form_validation->set_rules('id', 'ID', 'trim|required|numeric');
                \$this->form_validation->set_rules('username', 'Username', 'trim|required|alpha_numeric|max_length[20]');
                \$this->form_validation->set_rules('email', 'Email', 'trim|required|valid_email|max_length[80]');
                \$this->form_validation->set_rules('password', 'Password', 'trim|required|max_length[100]');
                \$this->form_validation->set_rules('full_name', 'Full Name', 'trim|required|max_length[50]');

                if(\$this->form_validation->run() == FALSE){
                    \$r=array(
                        'status' => FALSE, 
                        'error' => \$this->form_validation->error_array(), 
                        'message' => validation_errors()
                    );
                    \$this->response(\$r, REST_Controller::HTTP_BAD_REQUEST); 
                } else {
                    \$data = array(
                        'id' => \$id, 
                        'username' => \$username,
                        'email' => \$email,
                        'password' => md5(\$password),
                        'full_name' => \$fullName,
                        'updated_at' => date('Y-m-d h:i:s'),
                    );
                    \$r = \$this->"$ctrlM"_model->update(\$data);
                    if(\$r > 0 AND !empty(\$r)) {
                        \$r=array(
                            'status' => TRUE, 
                            'message' => '"$ctrl" updated sucessfull!'
                        );
                        \$this->response(\$r, REST_Controller::HTTP_OK); 
                    } else {
                        \$r=array(
                            'status' => FALSE, 
                            'message' => 'Not updated data!'
                        );
                        \$this->response(\$r, REST_Controller::HTTP_NOT_FOUND); 
                    }
                }
                \$r = \$this->"$ctrlM"_model->update(\$id,\$data);
                \$this->response(\$r, REST_Controller::HTTP_OK); 
            }

            public function index_post(){

                \$this->form_validation->set_rules('username', 'Username', 'trim|required|is_unique["$ctrlM".username]|alpha_numeric|max_length[20]', array('is_unique'=>'This %s already exists, please enter another username'));
                \$this->form_validation->set_rules('email', 'Email', 'trim|required|valid_email|max_length[80]|is_unique["$ctrlM".email]', array('is_unique'=>'This %s already exists, please enter another email'));
                \$this->form_validation->set_rules('password', 'Password', 'trim|required|max_length[100]');
                \$this->form_validation->set_rules('full_name', 'Full Name', 'trim|required|max_length[50]');

                \$username = \$this->post('username');
                \$email = \$this->post('email');
                \$password = \$this->post('password');
                \$fullName = \$this->post('full_name');

                if(\$this->form_validation->run() == FALSE){
                    \$r=array(
                        'status' => FALSE, 
                        'error' => \$this->form_validation->error_array(), 
                        'message' => validation_errors()
                    );
                    \$this->response(\$r, REST_Controller::HTTP_BAD_REQUEST); 
                } else {
                    \$data = array(
                        'username' => \$username,
                        'email' => \$email,
                        'password' => md5(\$password),
                        'full_name' => \$fullName,
                        'created_at' => date('Y-m-d h:i:s'),
                        'updated_at' => date('Y-m-d h:i:s'),
                    );
                    \$r = \$this->"$ctrlM"_model->insert(\$data);
                    if(\$r > 0 AND !empty(\$r)) {
                        \$r=array(
                            'status' => TRUE, 
                            'message' => '"$ctrl" registration sucessfull!'
                        );
                        \$this->response(\$r, REST_Controller::HTTP_OK); 
                    } else {
                        \$r=array(
                            'status' => FALSE, 
                            'message' => 'Not register your account!'
                        );
                        \$this->response(\$r, REST_Controller::HTTP_NOT_FOUND); 
                    }
                }
            }

            public function index_delete(){
                \$id = \$this->uri->segment(2);
                if(empty(\$id) AND !is_numeric(\$id)){
                    //ID IS NOT VALID 
                    \$r = array(
                        'status' => false,
                        'message' => 'Invalid ID!',
                    );
                    \$this->response(\$r, REST_Controller::HTTP_BAD_REQUEST); 
                } else {
                    \$output = \$this->"$ctrlM"_model->delete(\$id);
                    if(\$output == true AND !empty(\$output)){
                        \$r = array(
                            'status' => true,
                            'message' => '"$ctrl" deleted with sucessfull!',
                        );
                        \$this->response(\$r, REST_Controller::HTTP_OK); 
                    } else {
                        \$r = array(
                            'status' => true,
                            'message' => '"$ctrl" not deleted!',
                        );
                    }
                    \$this->response(\$r, REST_Controller::HTTP_OK); 
                }
            }
        }
    " >> $fileController
}

function configModel {
    fileModel='application/models/'$ctrl'_model.php'
    touch $fileModel
    echo "
        <?php

        defined('BASEPATH') OR exit('No direct script access allowed');

        class "$ctrl"_model extends CI_Model {

            public function read(){
                return \$this->db->get('"$ctrlM"')->result_array();
            }

            public function readById(\$id){
                \$this->db->where('id',\$id);
                return \$this->db->get('"$ctrlM"')->result_array();
            }

            public function insert(\$data){
                \$this->id    = null;
                \$this->username    = \$data['username'];
                \$this->email  = \$data['email'];
                \$this->password = \$data['password'];
                \$this->full_name = \$data['full_name'];
                \$this->created_at = \$data['created_at'];
                \$this->updated_at = \$data['updated_at'];
                if(\$this->db->insert('"$ctrlM"',\$this)){    
                    return \$this->db->insert_id();
                } else {
                    return 0;
                }
            }

            public function update(\$data){
                \$this->id = \$data['id'];
                \$this->username = \$data['username'];
                \$this->email = \$data['email'];
                \$this->password = \$data['password'];
                \$this->full_name = \$data['full_name'];
                \$this->updated_at = \$data['updated_at'];
                \$this->db->where('id', \$this->id);
                \$this->db->get('"$ctrlM"');
                if(\$this->db->affected_rows() > 0){
                    return \$this->db->update('"$ctrlM"', \$this);
                } else {
                    return false;
                }
            }

            public function delete(\$id){
                \$this->db->where('id', \$id);
                \$this->db->get('"$ctrlM"');
                if(\$this->db->affected_rows() > 0){
                    \$this->db->where('id', \$id);
                    \$this->db->delete('"$ctrlM"');
                    if(\$this->db->affected_rows() > 0){
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    return false;
                }
            }
        }
    " >> $fileModel
}

function configControllerCredential {
    fileController='application/controllers/Credential.php'
    touch $fileController
    echo "
        <?php

        use Restserver\Libraries\REST_Controller;

        defined('BASEPATH') or exit('No direct script access allowed');

        require APPPATH . 'libraries/REST_Controller.php';
        require APPPATH . 'libraries/Format.php';

        class Credential extends REST_Controller {

            public function __construct() {
                parent::__construct();
                \$this->load->model('credential_model');
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
                    \$resultLogin = \$this->credential_model->login(\$email,\$password);
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

                        \$level = \$this->put('level') ? \$this->put('level') : 1;
                        \$ignore_limits = ctype_digit(\$this->put('ignore_limits')) ? (int) \$this->put('ignore_limits') : 1;

                        if (\$this->_insert_key(\$token, ['level' => \$level, 'ignore_limits' => \$ignore_limits])){
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

            private function _insert_key(\$key, \$data){
                \$data[config_item('rest_key_column')] = \$key;
                \$data['date_created'] = function_exists('now') ? now() : time();

                return \$this->rest->db
                    ->set(\$data)
                    ->insert(config_item('rest_keys_table'));
            }
        }
    " >> $fileController
}

function configModelCredential {
    fileModel='application/models/credential_model.php'
    touch $fileModel
    echo "
        <?php

        defined('BASEPATH') OR exit('No direct script access allowed');

        class Credential_model extends CI_Model {

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

function configLibraryAuthorization {
    fileLibrary='application/libraries/Authorization_Token.php'
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

function configJWT {
    fileJWT='application/config/jwt.php'
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

function main {
    if [ -z "$1" ]
    then
        echo "route name: "
        read ctrl
    else
        ctrl=$1
    fi
    cd api/
    ctrlM=$(echo "$ctrl" | tr 'A-Z' 'a-z')
    configController
    configModel
    configLibraryAuthorization
    configJWT
    configControllerCredential
    configModelCredential
}

main $1
