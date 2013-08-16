log_level            :info
log_location         STDOUT
node_name           '@node.name@'
cache_type          'BasicFile'
cache_options( :path => "@user.chef.dir@/checksums" )
client_key             "@client.keys.dir@/@env@.pem"


chef_server_url    "http://@chef.url@:4000"

validation_key      "/etc/chef/validation.pem"
validation_client_name "chef-validator"
