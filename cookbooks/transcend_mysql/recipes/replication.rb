#
# Cookbook Name:: mysql
# Recipe:: replication
#
# Copyright 2008-2011, MomentumSoftware, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ---------------------------- Get the data bag item(s) needed ------------------------------------
Chef::Log.info("Variables for RDS config platform: #{node[:platform]}")
data_bag_name = node[:__TRANSCEND__DATABAG__]
Chef::Log.info("Found configuration: #{data_bag_name}" )

config = data_bag_item(data_bag_name, "config")
if config.nil? 
 Chef::Log.info("failed to get databag item: config")
else
 Chef::Log.info(config.to_s)
end

replication = data_bag_item(data_bag_name, "Replication")
if replication.nil? 
 Chef::Log.info("failed to get databag item: Replication")
else
 Chef::Log.info(replication.to_s)
end

req_params = config['request_parameters']
if req_params.nil? 
 Chef::Log.info("failed to get req_params")
else
 Chef::Log.info(req_params.to_s)
end

db_params = config['db_parameter_group']['Parameters']
if db_params.nil? 
 Chef::Log.info("failed to get db_params")
else
 Chef::Log.info(db_params.to_s)
end
# -------------------------------------------------------------------------------------------------

# ---------------------------------- Check which task is requested --------------------------------
task = replication['Task']
if(task.eql? "mysqldump")
  Chef::Log.info("mysqldump will be created for the read replica")
  execute "create mysqldump for replication" do
    command "mysqldump -uroot -p#{node['mysql']['server_root_password']} --all-database --lock-all-tables > replicate.sql; echo "" >> mysqldump"
    cwd "/root"
    action :run
  end
  replication['Task'] = "mysqldump_complete"
  replication.save
elsif(task.eql? "scp")
  Chef::Log.info("scp the mysqldump file into the read replica DBInstance")
  slave = replication['TargetHostname']
  key = replication['Key']
  if(File.exists? "/root/mysqldump")
	execute "scp the dump file" do
	  command "scp -o StrictHostKeyChecking=no -i /root/#{key} /root/replicate.sql root@#{slave}:/root"
	  action :run
	end
	execute "remove the leftovers" do
	  command "rm /root/mysqldump; rm /root/replicate.sql; rm /root/#{key}"
	  action :run	  
	end
  end
  replication['Task'] = "scp_complete"
  replication.save
else
  if(task.eql? "slave")
    Chef::Log.info("Setting slave configuration")
    execute "full db restoration" do
	  command "mysql -uroot -p#{node['mysql']['server_root_password']} < /root/replicate.sql"
	  action :run
	end
	execute "remove init backup" do
	  command "rm /root/replicate.sql"
	  action :run
	end
    node['mysql']['read_only'] = true
	node.save
	db_params['read_only']['value'] = true
	config.save
    replication['Task'] = "slave_complete"
    replication.save
  end
end
# -------------------------------------------------------------------------------------------------









