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
}

main $1
