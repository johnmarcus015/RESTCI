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
                \$this->load->model('"$ctrlM"_model');
            }

            public function "$ctrlM"_get(){
                \$r = \$this->"$ctrlM"_model->read();
                \$this->response(\$r); 
            }

            public function "$ctrlM"_put(){
                \$id = \$this->uri->segment(3);
                \$data = array('name' => \$this->input->get('name'),
                'pass' => \$this->input->get('pass'),
                'type' => \$this->input->get('type')
                );
                \$r = \$this->"$ctrlM"_model->update(\$id,\$data);
                \$this->response(\$r); 
            }

            public function "$ctrlM"_post(){
                \$data = array('name' => \$this->input->post('name'),
                'pass' => \$this->input->post('pass'),
                'type' => \$this->input->post('type')
                );
                \$r = \$this->"$ctrlM"_model->insert(\$data);
                \$this->response(\$r); 
            }

            public function "$ctrlM"_delete(){
                \$id = \$this->uri->segment(3);
                \$r = \$this->"$ctrlM"_model->delete(\$id);
                \$this->response(\$r); 
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
                \$query = \$this->db->query('select * from "$ctrlM"');
                return \$query->result_array();
            }

            public function insert(\$data){
                \$this->user_name    = \$data['name'];
                \$this->user_password  = \$data['pass'];
                \$this->user_type = \$data['type'];
                if(\$this->db->insert('"$ctrlM"',\$this)){    
                    return 'Data is inserted successfully';
                } else {
                    return 'Error has occured';
                }
            }

            public function update(\$id,\$data){
                \$this->user_name    = \$data['name'];
                \$this->user_password  = \$data['pass'];
                \$this->user_type = \$data['type'];
                \$result = \$this->db->update('"$ctrlM"',\$this,array('id' => \$id));
                if(\$result){
                    return 'Data is updated successfully';
                } else {
                    return 'Error has occurred';
                }
            }

            public function delete(\$id){
                \$result = \$this->db->query('delete from "$ctrlM" where id = \$id');
                if(\$result){
                    return 'Data is deleted successfully';
                } else {
                    return 'Error has occurred';
                }
            }
        }
    " >> $fileModel
}

cd rest/
echo "Type name of ctrl, followed by [ENTER]:"
read ctrl
ctrlM=$(echo "$ctrl" | tr 'A-Z' 'a-z')
configController
configModel