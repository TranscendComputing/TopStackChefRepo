#
# Cookbook Name:: mysql
# Recipe:: server
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

#include_recipe "transcend_mysql::client"

class Chef::Recipe
  include Math
  include DeviceChecker
end

#------------------------------------------------------------------------------------------------

#--------------------------------FOR TESTING PURPOSES--------------------------------------------
execute "master user password is set" do
  command "echo '\n\nThe master password is not blank.\n\n'"
  only_if "/usr/bin/mysql -u #{node['mysql']['root_user']} -p#{node['mysql']['server_root_password']} -e 'show databases;'"
end
execute "master user password is blank" do
  command "echo '\n\nThe master password is blank.\n\n'"
  only_if "/usr/bin/mysql -u #{node['mysql']['root_user']} -p#{node['mysql']['server_root_password']} -e 'show databases;'"
end

# ------------------------------ run apt-get update -----------------------------------------------
#execute "apt-get-update" do
#  ignore_failure true
#  epic_fail true
#  command "apt-get update"
#  not_if do File.exists?('/var/lib/apt/periodic/update-success-stamp') end
#end
# -------------------------------------------------------------------------------------------------

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

# ----------------- override the default attributes -----------------------------------------------
node.set['mysql']['root_user'] 				= "#{req_params['mstrUsr']}"
node.set['mysql']['server_debian_password'] = "#{req_params['mstrPsswd']}"
node.set['mysql']['server_root_password']   = "#{req_params['mstrPsswd']}"
node.set['mysql']['server_repl_password']   = "#{req_params['mstrPsswd']}"

if(!req_params['dbName'].nil?)
	node.set['mysql']['db_name'] = "#{req_params['dbName']}"
end

if ((node['mysql']['datadir'].nil?) && (!db_params['datadir'].nil?))
  node.set['mysql']['data_dir']				= "#{db_params['datadir']['value']}"
end

if (node['mysql']['basedir'].nil? && (!db_params['basedir'].nil?))
  node.set['mysql']['conf_dir']				= "#{db_params['basedir']['value']}"
end
if (node['mysql']['socket'].nil? && (!db_params['socket'].nil?))
  node.set['mysql']['socket'] 				= "#{db_params['socket']['value']}"
end
if (node['mysql']['port'].nil? && (!db_params['port'].nil?))
  unless db_params['port'].eql? "{EndPointPort}"
    node.set['mysql']['port']				= "#{db_params['port']['value']}"
  else
    node.set['mysql']['port']				= "3306"
  end
end
if (node['mysql']['pid_file'].nil? && (!db_params['pid_file'].nil?))
  value = db_params['pid_file']['value']
  if value.include? "{EndPointPort}"
    indexBegin = value.index('{')
    indexEnd = value.index('}')
    Chef::Log.info("Mapping " + value[indexBegin, indexEnd] + " to the port value...")
    port = node['mysql']['port']
    newValue = value[0, indexBegin] + port + value[indexEnd + 1, value.length]
    Chef::Log.info("New value = " + newValue)
    node.set['mysql']['pid_file']				= newValue
  else
    node.set['mysql']['pid_file']				= "#{db_params['pid_file']['value']}"
  end
end
if (node['mysql']['tmpdir'].nil? && (!db_params['tmpdir'].nil?))
  node.set['mysql']['tmpdir']					= "#{db_params['tmpdir']['value']}"
end
unless db_params['thread_cache_size'].nil?
  node.set['mysql']['thread_cache_size']		= "#{db_params['thread_cache_size']['value']}"
end
if db_params['thread_cache_size'].nil?
  node.set['mysql']['thread_cache_size']		= nil
end
unless db_params['key_buffer_size'].nil?
  node.set['mysql']['key_buffer_size']		= "#{db_params['key_buffer_size']['value']}"
end
if db_params['key_buffer_size'].nil?
  node.set['mysql']['key_buffer_size']		= nil
end
unless db_params['sort_buffer_size'].nil?
  node.set['mysql']['sort_buffer_size']		= "#{db_params['sort_buffer_size']['value']}"
end
if db_params['sort_buffer_size'].nil?
  node.set['mysql']['sort_buffer_size']		= nil
end
unless db_params['read_buffer_size'].nil?
  node.set['mysql']['read_buffer_size']		= "#{db_params['read_buffer_size']['value']}"
end
if db_params['read_buffer_size'].nil?
  node.set['mysql']['read_buffer_size']		= nil
end
unless db_params['read_rnd_buffer_size'].nil?
  node.set['mysql']['read_rnd_buffer_size']	= "#{db_params['read_rnd_buffer_size']['value']}"
end
if db_params['read_rnd_buffer_size'].nil?
  node.set['mysql']['read_rnd_buffer_size']	= nil
end
unless db_params['max_allowed_packet'].nil?
  node.set['mysql']['max_allowed_packet']		= "#{db_params['max_allowed_packet']['value']}"
end
if db_params['max_allowed_packet'].nil?
  node.set['mysql']['max_allowed_packet']		= nil
end
unless db_params['max_heap_table_size'].nil?
  node.set['mysql']['max_heap_table_size']	= "#{db_params['max_heap_table_size']['value']}"
end
if db_params['max_heap_table_size'].nil?
  node.set['mysql']['max_heap_table_size']	= nil
end
unless db_params['tmp_table_size'].nil?
  node.set['mysql']['tmp_table_size']		= "#{db_params['tmp_table_size']['value']}"
end
if db_params['tmp_table_size'].nil?
  node.set['mysql']['tmp_table_size']		= nil
end
unless db_params['query_cache_size'].nil?
  node.set['mysql']['query_cache_size']		= "#{db_params['query_cache_size']['value']}"
end
unless db_params['query_cache_size'].nil?
  node.set['mysql']['query_cache_size']		= "#{db_params['query_cache_size']['value']}"
end
if db_params['query_cache_size'].nil?
  node.set['mysql']['query_cache_size']		= nil
end
if (node['mysql']['log_output'].nil? && (!db_params['log_output']['value'].nil?))
  node.set['mysql']['log_output']				= "#{db_params['log_output']['value']}"
end
unless db_params['slow_query_log'].nil?
  node.set['mysql']['slow_query_log']			= "#{db_params['slow_query_log']['value']}"
end
if db_params['slow_query_log'].nil?
  node.set['mysql']['slow_query_log']			= nil
end
if (node['mysql']['log_error'].nil? && (!db_params['log_error'].nil?))
  node.set['mysql']['log_error']	= "#{db_params['log_error']['value']}"
end
unless db_params['long_query_time'].nil?
  node.set['mysql']['long_query_time']		= "#{db_params['long_query_time']['value']}"
end
if db_params['long_query_time'].nil?
  node.set['mysql']['long_query_time']		= nil
end
if (node['mysql']['innodb_data_home_dir'].nil? && (!db_params['innodb_data_home_dir'].nil?))
  node.set['mysql']['innodb_data_home_dir']	= "#{db_params['innodb_data_home_dir']['value']}"
end
unless db_params['innodb_buffer_pool_size'].nil?
  value = db_params['innodb_buffer_pool_size']['value']
  # mapping the DBInstanceClassMemory reference to an actual value, and then doing the expression evaluation
  if value[0, 22].eql? "{DBInstanceClassMemory"
    instanceMem = node['memory']['total']
    # get rid of "kB" at the end
    instanceMem = instanceMem[0, instanceMem.length - 2]
    evalThis = "" + instanceMem + db_params['innodb_buffer_pool_size']['value'][22, value.length]
    evalThis = evalThis[0, evalThis.length - 1]
    Chef::Log.info("DBInstanceClassMemory: "  + instanceMem + ", Expression: " + evalThis)
    evaluated = eval(evalThis).to_s()
    node.set['mysql']['innodb_buffer_pool_size']= "" + evaluated + "kB"
  else
  node.set['mysql']['innodb_buffer_pool_size']= value
  end
end
if db_params['innodb_buffer_pool_size'].nil?
  node.set['mysql']['innodb_buffer_pool_size']= nil
end
unless db_params['innodb_flush_log_at_trx_commit'].nil?
  node.set['mysql']['innodb_flush_log_at_trx_commit']	= "#{db_params['innodb_flush_log_at_trx_commit']['value']}"
end
if db_params['innodb_flush_log_at_trx_commit'].nil?
  node.set['mysql']['innodb_flush_log_at_trx_commit']	= nil
end
unless db_params['innodb_additional_mem_pool_size'].nil?
  node.set['mysql']['innodb_additional_mem_pool_size']	= "#{db_params['innodb_additional_mem_pool_size']['value']}"
end
if db_params['innodb_additional_mem_pool_size'].nil?
  node.set['mysql']['innodb_additional_mem_pool_size']	= nil
end
unless db_params['innodb_support_xa'].nil?
  node.set['mysql']['innodb_support_xa']	= "#{db_params['innodb_support_xa']['value']}"
end
if db_params['innodb_support_xa'].nil?
  node.set['mysql']['innodb_support_xa']	= nil
end
unless db_params['innodb_lock_wait_timeout'].nil?
  node.set['mysql']['innodb_lock_wait_timeout']	= "#{db_params['innodb_lock_wait_timeout']['value']}"
end
if db_params['innodb_lock_wait_timeout'].nil?
  node.set['mysql']['innodb_lock_wait_timeout']	= nil
end
if (node['mysql']['innodb_flush_method'].nil? && (!db_params['innodb_flush_method'].nil?))
  node.set['mysql']['innodb_flush_method']	= "#{db_params['innodb_flush_method']['value']}"
end
if (node['mysql']['innodb_log_file_size'].nil? && (!db_params['innodb_log_file_size'].nil?))
  node.set['mysql']['innodb_log_file_size']	= "#{db_params['innodb_log_file_size']['value']}"
end
unless db_params['innodb_log_buffer_size'].nil?
  node.set['mysql']['innodb_log_buffer_size']	= "#{db_params['innodb_log_buffer_size']['value']}"
end
if db_params['innodb_log_buffer_size'].nil?
  node.set['mysql']['innodb_log_buffer_size']	= nil
end
unless db_params['innodb_thread_concurrency'].nil?
  node.set['mysql']['innodb_thread_concurrency']	= "#{db_params['innodb_thread_concurrency']['value']}"
end
if db_params['innodb_thread_concurrency'].nil?
  node.set['mysql']['innodb_thread_concurrency']	= nil
end
unless db_params['binlog_cache_size'].nil?
  node.set['mysql']['binlog_cache_size']	= "#{db_params['binlog_cache_size']['value']}"
end
if db_params['binlog_cache_size'].nil?
  node.set['mysql']['binlog_cache_size']	= nil
end
if (node['mysql']['binlog_format'].nil? && (!db_params['binlog_format'].nil?))
  node.set['mysql']['binlog_format']	= "#{db_params['binlog_format']['value']}"
end
if (node['mysql']['default_storage_engine'].nil? && (!db_params['default_storage_engine'].nil?))
  node.set['mysql']['default_storage_engine']	= "#{db_params['default_storage_engine']['value']}"
end
unless db_params['innodb_file_per_table'].nil?
  node.set['mysql']['innodb_file_per_table']	= "#{db_params['innodb_file_per_table']['value']}"
end
if db_params['innodb_file_per_table'].nil?
  node.set['mysql']['innodb_file_per_table']	= nil
end
if (node['mysql']['innodb_log_group_home_dir'].nil? && (!db_params['innodb_log_group_home_dir'].nil?))
  node.set['mysql']['innodb_log_group_home_dir']	= "#{db_params['innodb_log_group_home_dir']['value']}"
end
unless db_params['local_infile'].nil?
  node.set['mysql']['local_infile']	= "#{db_params['local_infile']['value']}"
end
if db_params['local_infile'].nil?
  node.set['mysql']['local_infile']	= nil
end
if (node['mysql']['log-bin'].nil? && (!db_params['log-bin'].nil?))
  node.set['mysql']['log-bin']	= "#{db_params['log-bin']['value']}"
end
if (node['mysql']['max_binlog_size'].nil? && (!db_params['max_binlog_size'].nil?))
  node.set['mysql']['max_binlog_size']	= "#{db_params['max_binlog_size']['value']}"
end
unless db_params['max_connections'].nil?
  value = db_params['max_connections']['value']
  # mapping the DBInstanceClassMemory reference to an actual value, and then doing the expression evaluation
  if value[0, 22].eql? "{DBInstanceClassMemory"
    instanceMem = node['memory']['total']
    # get rid of "kB" at the end
    instanceMem = instanceMem[0, instanceMem.length - 2]
    # convert the unit from kB to byteqq
    memBytes = Integer(instanceMem) * 1024
    evalThis = "" + memBytes.to_s() + db_params['max_connections']['value'][22, value.length]
    evalThis = evalThis[0, evalThis.length - 1]
    Chef::Log.info("DBInstanceClassMemory: "  + instanceMem + ", Expression: " + evalThis)
    evaluated = eval(evalThis).to_s()
    node.set['mysql']['max_connections']= "" + evaluated
  else
    node.set['mysql']['max_connections']	= "#{db_params['max_connections']['value']}"
  end
end
unless db_params['max_connections'].nil?
  node.set['mysql']['max_connections']	= nil
end
unless db_params['read_only'].nil?
  node.set['mysql']['read_only']	= "#{db_params['read_only']['value']}"
end
if db_params['read_only'].nil?
  node.set['mysql']['read_only']	= nil
end
if (node['mysql']['relay-log'].nil? && (!db_params['relay-log'].nil?))
  node.set['mysql']['relay-log']	= "#{db_params['relay-log']['value']}"
end
if (node['mysql']['secure_file_priv'].nil? && (!db_params['secure_file_priv'].nil?))
  node.set['mysql']['secure_file_priv']	= "#{db_params['secure_file_priv']['value']}"
end
if node['mysql']['server_id'].nil?
  unless db_params['server_id'].nil?
    value = db_params['server_id']['value']
    if (value.eql? "{ServerId}") || (node['mysql']['server_id'].eql? "{ServerId}")
      # generate a random server id if a value isn't already set
      random_num = rand(4294967296)
      node.set['mysql']['server_id'] = random_num
    elsif node['mysql']['server_id'].nil?
      node.set['mysql']['server_id']	= "#{db_params['server_id']['value']}"
    end
  end
end
unless db_params['thread_stack'].nil?
  node.set['mysql']['thread_stack']	= "#{db_params['thread_stack']['value']}"
end
if db_params['thread_stack'].nil?
  node.set['mysql']['thread_stack']	= nil
end
if (node['mysql']['allow-suspicious-udfs'].nil? && (!db_params['allow-suspicious-udfs'].nil?))
  node.set['mysql']['allow-suspicious-udfs']	= "#{db_params['allow-suspicious-udfs']['value']}"
end
unless db_params['auto_increment_increment'].nil?
  node.set['mysql']['auto_increment_increment']	= "#{db_params['auto_increment_increment']['value']}"
end
if db_params['auto_increment_increment'].nil?
  node.set['mysql']['auto_increment_increment']	= nil
end
unless db_params['auto_increment_offset'].nil?
  node.set['mysql']['auto_increment_offset']	= "#{db_params['auto_increment_offset']['value']}"
end
if db_params['auto_increment_offset'].nil?
  node.set['mysql']['auto_increment_offset']	= nil
end
unless db_params['autocommit'].nil?
  node.set['mysql']['autocommit']	= "#{db_params['autocommit']['value']}"
end
if db_params['autocommit'].nil?
  node.set['mysql']['autocommit']	= nil
end
unless db_params['automatic_sp_privileges'].nil?
  node.set['mysql']['automatic_sp_privileges']	= "#{db_params['automatic_sp_privileges']['value']}"
end
if db_params['automatic_sp_privileges'].nil?
  node.set['mysql']['automatic_sp_privileges']	= nil
end
unless db_params['back_log'].nil?
  node.set['mysql']['back_log']	= "#{db_params['back_log']['value']}"
end
if db_params['back_log'].nil?
  node.set['mysql']['back_log']	= nil
end
unless db_params['bulk_insert_buffer_size'].nil?
  node.set['mysql']['bulk_insert_buffer_size']	= "#{db_params['bulk_insert_buffer_size']['value']}"
end
if db_params['bulk_insert_buffer_size'].nil?
  node.set['mysql']['bulk_insert_buffer_size']	= nil
end
unless db_params['character-set-client-handshake'].nil?
  node.set['mysql']['character-set-client-handshake']	= "#{db_params['character-set-client-handshake']['value']}"
end
if db_params['character-set-client-handshake'].nil?
  node.set['mysql']['character-set-client-handshake']	= nil
end
unless db_params['character_set_client'].nil?
  node.set['mysql']['character_set_client']	= "#{db_params['character_set_client']['value']}"
end
if db_params['character_set_client'].nil?
  node.set['mysql']['character_set_client']	= nil
end
unless db_params['character_set_connection'].nil?
  node.set['mysql']['character_set_connection']	= "#{db_params['character_set_connection']['value']}"
end
if db_params['character_set_connection'].nil?
  node.set['mysql']['character_set_connection']	= nil
end
unless db_params['character_set_database'].nil?
  node.set['mysql']['character_set_database']	= "#{db_params['character_set_database']['value']}"
end
if db_params['character_set_database'].nil?
  node.set['mysql']['character_set_database']	= nil
end
unless db_params['character_set_filesystem'].nil?
  node.set['mysql']['character_set_filesystem']	= "#{db_params['character_set_filesystem']['value']}"
end
if db_params['character_set_filesystem'].nil?
  node.set['mysql']['character_set_filesystem']	= nil
end
unless db_params['character_set_result'].nil?
  node.set['mysql']['character_set_result']	= "#{db_params['character_set_result']['value']}"
end
if db_params['character_set_result'].nil?
  node.set['mysql']['character_set_result']	= nil
end
unless db_params['character_set_server'].nil?
  node.set['mysql']['character_set_server']	= "#{db_params['character_set_server']['value']}"
end
if db_params['character_set_server'].nil?
  node.set['mysql']['character_set_server']	= nil
end
unless db_params['collation_connection'].nil?
  node.set['mysql']['collation_connection']	= "#{db_params['collation_connection']['value']}"
end
if db_params['collation_connection'].nil?
  node.set['mysql']['collation_connection']	= nil
end
unless db_params['collation_server'].nil?
  node.set['mysql']['collation_server']	= "#{db_params['collation_server']['value']}"
end
if db_params['collation_server'].nil?
  node.set['mysql']['collation_server']	= nil
end
unless db_params['completion_type'].nil?
  node.set['mysql']['completion_type']	= "#{db_params['completion_type']['value']}"
end
if db_params['completion_type'].nil?
  node.set['mysql']['completion_type']	= nil
end
unless db_params['concurrent_insert'].nil?
  node.set['mysql']['concurrent_insert']	= "#{db_params['concurrent_insert']['value']}"
end
if db_params['concurrent_insert'].nil?
  node.set['mysql']['concurrent_insert']	= nil
end
unless db_params['connect_timeout'].nil?
  node.set['mysql']['connect_timeout']	= "#{db_params['connect_timeout']['value']}"
end
unless db_params['connect_timeout'].nil?
  node.set['mysql']['connect_timeout']	= nil
end
if (node['mysql']['default_time_zone'].nil? && (!db_params['default_time_zone'].nil?))
  node.set['mysql']['default_time_zone']	= "#{db_params['default_time_zone']['value']}"
end
unless db_params['default_week_format'].nil?
  node.set['mysql']['default_week_format']	= "#{db_params['default_week_format']['value']}"
end
if db_params['default_week_format'].nil?
  node.set['mysql']['default_week_format']	= nil
end
unless db_params['delay_key_write'].nil?
  node.set['mysql']['delay_key_write']	= "#{db_params['delay_key_write']['value']}"
end
if db_params['delay_key_write'].nil?
  node.set['mysql']['delay_key_write']	= nil
end
unless db_params['delayed_insert_limit'].nil?
  node.set['mysql']['delayed_insert_limit']	= "#{db_params['delayed_insert_limit']['value']}"
end
if db_params['delayed_insert_limit'].nil?
  node.set['mysql']['delayed_insert_limit']	= nil
end
unless db_params['delayed_insert_timeout'].nil?
  node.set['mysql']['delayed_insert_timeout']	= "#{db_params['delayed_insert_timeout']['value']}"
end
if db_params['delayed_insert_timeout'].nil?
  node.set['mysql']['delayed_insert_timeout']	= nil
end
unless db_params['delayed_queue_size'].nil?
  node.set['mysql']['delayed_queue_size']	= "#{db_params['delayed_queue_size']['value']}"
end
if db_params['delayed_queue_size'].nil?
  node.set['mysql']['delayed_queue_size']	= nil
end
unless db_params['div_precision_increment'].nil?
  node.set['mysql']['div_precision_increment']	= "#{db_params['div_precision_increment']['value']}"
end
if db_params['div_precision_increment'].nil?
  node.set['mysql']['div_precision_increment']	= nil
end
unless db_params['event_scheduler'].nil?
  node.set['mysql']['event_scheduler']	= "#{db_params['event_scheduler']['value']}"
end
if db_params['event_scheduler'].nil?
  node.set['mysql']['event_scheduler']	= nil
end
if (node['mysql']['flush'].nil? && (!db_params['flush'].nil?))
  node.set['mysql']['flush']	= "#{db_params['flush']['value']}"
end
unless db_params['flush_time'].nil?
  node.set['mysql']['flush_time']	= "#{db_params['flush_time']['value']}"
end
if db_params['flush_time'].nil?
  node.set['mysql']['flush_time']	= nil
end
if (node['mysql']['ft_boolean_syntax'].nil? && (!db_params['ft_boolean_syntax'].nil?))
  node.set['mysql']['ft_boolean_syntax']	= "#{db_params['ft_boolean_syntax']['value']}"
end
unless db_params['ft_max_word_len'].nil?
  node.set['mysql']['ft_max_word_len']	= "#{db_params['ft_max_word_len']['value']}"
end
if db_params['ft_max_word_len'].nil?
  node.set['mysql']['ft_max_word_len']	= nil
end
unless db_params['ft_min_word_len'].nil?
  node.set['mysql']['ft_min_word_len']	= "#{db_params['ft_min_word_len']['value']}"
end
if db_params['ft_min_word_len'].nil?
  node.set['mysql']['ft_min_word_len']	= nil
end
unless db_params['ft_query_expansion_limit'].nil?
  node.set['mysql']['ft_query_expansion_limit']	= "#{db_params['ft_query_expansion_limit']['value']}"
end
if db_params['ft_query_expansion_limit'].nil?
  node.set['mysql']['ft_query_expansion_limit']	= nil
end
unless db_params['general_log'].nil?
  node.set['mysql']['general_log']	= "#{db_params['general_log']['value']}"
end
if db_params['general_log'].nil?
  node.set['mysql']['general_log']	= nil
end
unless db_params['group_concat_max_len'].nil?
  node.set['mysql']['group_concat_max_len']	= "#{db_params['group_concat_max_len']['value']}"
end
if db_params['group_concat_max_len'].nil?
  node.set['mysql']['group_concat_max_len']	= nil
end
unless db_params['init_connect'].nil?
  node.set['mysql']['init_connect']	= "#{db_params['init_connect']['value']}"
end
if db_params['init_connect'].nil?
  node.set['mysql']['init_connect']	= nil
end
unless db_params['innodb_adaptive_flushing'].nil?
  node.set['mysql']['innodb_adaptive_flushing']	= "#{db_params['innodb_adaptive_flushing']['value']}"
end
if db_params['innodb_adaptive_flushing'].nil?
  node.set['mysql']['innodb_adaptive_flushing']	= nil
end
unless db_params['innodb_adaptive_hash_index'].nil?
  node.set['mysql']['innodb_adaptive_hash_index']	= "#{db_params['innodb_adaptive_hash_index']['value']}"
end
if db_params['innodb_adaptive_hash_index'].nil?
  node.set['mysql']['innodb_adaptive_hash_index']	= nil
end
unless db_params['innodb_autoextend_increment'].nil?
  node.set['mysql']['innodb_autoextend_increment']	= "#{db_params['innodb_autoextend_increment']['value']}"
end
if db_params['innodb_autoextend_increment'].nil?
  node.set['mysql']['innodb_autoextend_increment']	= nil
end
unless db_params['innodb_autoinc_lock_mode'].nil?
  node.set['mysql']['innodb_autoinc_lock_mode']	= "#{db_params['innodb_autoinc_lock_mode']['value']}"
end
if db_params['innodb_autoinc_lock_mode'].nil?
  node.set['mysql']['innodb_autoinc_lock_mode']	= nil
end
unless db_params['innodb_buffer_pool_instances'].nil?
  node.set['mysql']['innodb_buffer_pool_instances']	= "#{db_params['innodb_buffer_pool_instances']['value']}"
end
if db_params['innodb_buffer_pool_instances'].nil?
  node.set['mysql']['innodb_buffer_pool_instances']	= nil
end
unless db_params['innodb_change_buffering'].nil?
  node.set['mysql']['innodb_change_buffering']	= "#{db_params['innodb_change_buffering']['value']}"
end
if db_params['innodb_change_buffering'].nil?
  node.set['mysql']['innodb_change_buffering']	= nil
end
unless db_params['innodb_commit_concurrency'].nil?
  node.set['mysql']['innodb_commit_concurrency']	= "#{db_params['innodb_commit_concurrency']['value']}"
end
if db_params['innodb_commit_concurrency'].nil?
  node.set['mysql']['innodb_commit_concurrency']	= nil
end
unless db_params['innodb_concurrency_tickets'].nil?
  node.set['mysql']['innodb_concurrency_tickets']	= "#{db_params['innodb_concurrency_tickets']['value']}"
end
if db_params['innodb_concurrency_tickets'].nil?
  node.set['mysql']['innodb_concurrency_tickets']	= nil
end
unless db_params['innodb_file_format'].nil?
  node.set['mysql']['innodb_file_format']	= "#{db_params['innodb_file_format']['value']}"
end
if db_params['innodb_file_format'].nil?
  node.set['mysql']['innodb_file_format']	= nil
end
if (node['mysql']['innodb_force_load_corrupted'].nil? && (!db_params['innodb_force_load_corrupted'].nil?))
  node.set['mysql']['innodb_force_load_corrupted']	= "#{db_params['innodb_force_load_corrupted']['value']}"
end
unless db_params['innodb_io_capacity'].nil?
  node.set['mysql']['innodb_io_capacity']	= "#{db_params['innodb_io_capacity']['value']}"
end
if db_params['innodb_io_capacity'].nil?
  node.set['mysql']['innodb_io_capacity']	= nil
end
unless db_params['innodb_large_prefix'].nil?
  node.set['mysql']['innodb_large_prefix']	= "#{db_params['innodb_large_prefix']['value']}"
end
if db_params['innodb_large_prefix'].nil?
  node.set['mysql']['innodb_large_prefix']	= nil
end
if (node['mysql']['innodb_locks_unsafe_for_binlog'].nil? && (!db_params['innodb_locks_unsafe_for_binlog'].nil?))
  node.set['mysql']['innodb_locks_unsafe_for_binlog']	= "#{db_params['innodb_locks_unsafe_for_binlog']['value']}"
end
unless db_params['innodb_max_dirty_pages_pct'].nil?
  node.set['mysql']['innodb_max_dirty_pages_pct']	= "#{db_params['innodb_max_dirty_pages_pct']['value']}"
end
if db_params['innodb_max_dirty_pages_pct'].nil?
  node.set['mysql']['innodb_max_dirty_pages_pct']	= nil
end
unless db_params['innodb_max_purge_lag'].nil?
  node.set['mysql']['innodb_max_purge_lag']	= "#{db_params['innodb_max_purge_lag']['value']}"
end
if db_params['innodb_max_purge_lag'].nil?
  node.set['mysql']['innodb_max_purge_lag']	= nil
end
unless db_params['innodb_old_blocks_pct'].nil?
  node.set['mysql']['innodb_old_blocks_pct']	= "#{db_params['innodb_old_blocks_pct']['value']}"
end
if db_params['innodb_old_blocks_pct'].nil?
  node.set['mysql']['innodb_old_blocks_pct']	= nil
end
unless db_params['innodb_old_blocks_time'].nil?
  node.set['mysql']['innodb_old_blocks_time']	= "#{db_params['innodb_old_blocks_time']['value']}"
end
if db_params['innodb_old_blocks_time'].nil?
  node.set['mysql']['innodb_old_blocks_time']	= nil
end
unless db_params['innodb_open_files'].nil?
  node.set['mysql']['innodb_open_files']	= "#{db_params['innodb_open_files']['value']}"
end
if db_params['innodb_open_files'].nil?
  node.set['mysql']['innodb_open_files']	= nil
end
unless db_params['innodb_purge_batch_size'].nil?
  node.set['mysql']['innodb_purge_batch_size']	= "#{db_params['innodb_purge_batch_size']['value']}"
end
if db_params['innodb_purge_batch_size'].nil?
  node.set['mysql']['innodb_purge_batch_size']	= nil
end
unless db_params['innodb_purge_threads'].nil?
  node.set['mysql']['innodb_purge_threads']	= "#{db_params['innodb_purge_threadss']['value']}"
end
if db_params['innodb_purge_threads'].nil?
  node.set['mysql']['innodb_purge_threads']	= nil
end
unless db_params['innodb_random_read_ahead'].nil?
  node.set['mysql']['innodb_random_read_ahead']	= "#{db_params['innodb_random_read_ahead']['value']}"
end
if db_params['innodb_random_read_ahead'].nil?
  node.set['mysql']['innodb_random_read_ahead']	= nil
end
unless db_params['innodb_read_ahead_threshold'].nil?
  node.set['mysql']['innodb_read_ahead_threshold']	= "#{db_params['innodb_read_ahead_threshold']['value']}"
end
if db_params['innodb_read_ahead_threshold'].nil?
  node.set['mysql']['innodb_read_ahead_threshold']	= nil
end
unless db_params['innodb_read_io_threads'].nil?
  node.set['mysql']['innodb_read_io_threads']	= "#{db_params['innodb_read_io_threads']['value']}"
end
if db_params['innodb_read_io_threads'].nil?
  node.set['mysql']['innodb_read_io_threads']	= nil
end
unless db_params['innodb_replication_delay'].nil?
  node.set['mysql']['innodb_replication_delay']	= "#{db_params['innodb_replication_delay']['value']}"
end
if db_params['innodb_replication_delay'].nil?
  node.set['mysql']['innodb_replication_delay']	= nil
end
unless db_params['innodb_rollback_on_timeout'].nil?
  node.set['mysql']['innodb_rollback_on_timeout']	= "#{db_params['innodb_rollback_on_timeout']['value']}"
end
if db_params['innodb_rollback_on_timeout'].nil?
  node.set['mysql']['innodb_rollback_on_timeout']	= nil
end
unless db_params['innodb_spin_wait_delay'].nil?
  node.set['mysql']['innodb_spin_wait_delay']	= "#{db_params['innodb_spin_wait_delay']['value']}"
end
if db_params['innodb_spin_wait_delay'].nil?
  node.set['mysql']['innodb_spin_wait_delay']	= nil
end
unless db_params['innodb_stats_on_metadata'].nil?
  node.set['mysql']['innodb_stats_on_metadata']	= "#{db_params['innodb_stats_on_metadata']['value']}"
end
if db_params['innodb_stats_on_metadata'].nil?
  node.set['mysql']['innodb_stats_on_metadata']	= nil
end
unless db_params['innodb_stats_sample_pages'].nil?
  node.set['mysql']['innodb_stats_sample_pages']	= "#{db_params['innodb_stats_sample_pages']['value']}"
end
if db_params['innodb_stats_sample_pages'].nil?
  node.set['mysql']['innodb_stats_sample_pages']	= nil
end
unless db_params['innodb_strict_mode'].nil?
  node.set['mysql']['innodb_strict_mode']	= "#{db_params['innodb_strict_mode']['value']}"
end
if db_params['innodb_strict_mode'].nil?
  node.set['mysql']['innodb_strict_mode']	= nil
end
unless db_params['innodb_sync_spin_loops'].nil?
  node.set['mysql']['innodb_sync_spin_loops']	= "#{db_params['innodb_sync_spin_loops']['value']}"
end
if db_params['innodb_sync_spin_loops'].nil?
  node.set['mysql']['innodb_sync_spin_loops']	= nil
end
unless db_params['innodb_table_locks'].nil?
  node.set['mysql']['innodb_table_locks']	= "#{db_params['innodb_table_locks']['value']}"
end
if db_params['innodb_table_locks'].nil?
  node.set['mysql']['innodb_table_locks']	= nil
end
unless db_params['innodb_thread_sleep_delay'].nil?
  node.set['mysql']['innodb_thread_sleep_delay']	= "#{db_params['innodb_thread_sleep_delay']['value']}"
end
if db_params['innodb_thread_sleep_delay'].nil?
  node.set['mysql']['innodb_thread_sleep_delay']	= nil
end
unless db_params['innodb_use_native_aio'].nil?
  node.set['mysql']['innodb_use_native_aio']	= "#{db_params['innodb_use_native_aio']['value']}"
end
if db_params['innodb_use_native_aio'].nil?
  node.set['mysql']['innodb_use_native_aio']	= nil
end
unless db_params['innodb_use_sys_malloc'].nil?
  node.set['mysql']['innodb_use_sys_malloc']	= "#{db_params['innodb_use_sys_malloc']['value']}"
end
if db_params['innodb_use_sys_malloc'].nil?
  node.set['mysql']['innodb_use_sys_malloc']	= nil
end
unless db_params['innodb_write_io_threads'].nil?
  node.set['mysql']['innodb_write_io_threads']	= "#{db_params['innodb_write_io_threads']['value']}"
end
if db_params['innodb_write_io_threads'].nil?
  node.set['mysql']['innodb_write_io_threads']	= nil
end
unless db_params['interactive_timeout'].nil?
  node.set['mysql']['interactive_timeout']	= "#{db_params['interactive_timeouts']['value']}"
end
if db_params['interactive_timeout'].nil?
  node.set['mysql']['interactive_timeout']	= nil
end
unless db_params['join_buffer_size'].nil?
  node.set['mysql']['join_buffer_size']	= "#{db_params['join_buffer_size']['value']}"
end
if db_params['join_buffer_size'].nil?
  node.set['mysql']['join_buffer_size']	= nil
end
unless db_params['keep_files_on_create'].nil?
  node.set['mysql']['keep_files_on_create']	= "#{db_params['keep_files_on_create']['value']}"
end
if db_params['keep_files_on_create'].nil?
  node.set['mysql']['keep_files_on_create']	= nil
end
unless db_params['key_cache_age_threshold'].nil?
  node.set['mysql']['key_cache_age_threshold']	= "#{db_params['key_cache_age_threshold']['value']}"
end
if db_params['key_cache_age_threshold'].nil?
  node.set['mysql']['key_cache_age_threshold']	= nil
end
unless db_params['key_cache_block_size'].nil?
  node.set['mysql']['key_cache_block_size']	= "#{db_params['key_cache_block_size']['value']}"
end
if db_params['key_cache_block_size'].nil?
  node.set['mysql']['key_cache_block_size']	= nil
end
unless db_params['key_cache_division_limit'].nil?
  node.set['mysql']['key_cache_division_limit']	= "#{db_params['key_cache_division_limit']['value']}"
end
if db_params['key_cache_division_limit'].nil?
  node.set['mysql']['key_cache_division_limit']	= nil
end
unless db_params['lc_time_names'].nil?
  node.set['mysql']['lc_time_names']	= "#{db_params['lc_time_names']['value']}"
end
if db_params['lc_time_names'].nil?
  node.set['mysql']['lc_time_names']	= nil
end
unless db_params['lock_wait_timeout'].nil?
  node.set['mysql']['lock_wait_timeout']	= "#{db_params['lock_wait_timeout']['value']}"
end
if db_params['lock_wait_timeout'].nil?
  node.set['mysql']['lock_wait_timeout']	= nil
end
unless db_params['log_bin_trust_function_creators'].nil?
  node.set['mysql']['log_bin_trust_function_creators']	= "#{db_params['log_bin_trust_function_creators']['value']}"
end
if db_params['log_bin_trust_function_creators'].nil?
  node.set['mysql']['log_bin_trust_function_creators']	= nil
end
unless db_params['log_queries_not_using_indexes'].nil?
  node.set['mysql']['log_queries_not_using_indexes']	= "#{db_params['log_queries_not_using_indexes']['value']}"
end
if db_params['log_queries_not_using_indexes'].nil?
  node.set['mysql']['log_queries_not_using_indexes']	= nil
end
unless db_params['log_warnings'].nil?
  node.set['mysql']['log_warnings']	= "#{db_params['log_warnings']['value']}"
end
if db_params['log_warnings'].nil?
  node.set['mysql']['log_warnings']	= nil
end
unless db_params['low_priority_updates'].nil?
  node.set['mysql']['low_priority_updates']	= "#{db_params['low_priority_updates']['value']}"
end
if db_params['low_priority_updates'].nil?
  node.set['mysql']['low_priority_updates']	= nil
end
unless db_params['lower_case_table_names'].nil?
  node.set['mysql']['lower_case_table_names']	= "#{db_params['lower_case_table_names']['value']}"
end
if db_params['lower_case_table_names'].nil?
  node.set['mysql']['lower_case_table_names']	= nil
end
unless db_params['max_binlog_cache_size'].nil?
  node.set['mysql']['max_binlog_cache_size']	= "#{db_params['max_binlog_cache_size']['value']}"
end
if db_params['max_binlog_cache_size'].nil?
  node.set['mysql']['max_binlog_cache_size']	= nil
end
unless db_params['max_connect_errors'].nil?
  node.set['mysql']['max_connect_errors']	= "#{db_params['max_connect_errors']['value']}"
end
if db_params['max_connect_errors'].nil?
  node.set['mysql']['max_connect_errors']	= nil
end
unless db_params['max_delayed_threads'].nil?
  node.set['mysql']['max_delayed_threads']	= "#{db_params['max_delayed_threads']['value']}"
end
if db_params['max_delayed_threads'].nil?
  node.set['mysql']['max_delayed_threads']	= nil
end
unless db_params['max_error_count'].nil?
  node.set['mysql']['max_error_count']	= "#{db_params['max_error_count']['value']}"
end
if db_params['max_error_count'].nil?
  node.set['mysql']['max_error_count']	= nil
end
unless db_params['max_insert_delayed_threads'].nil?
  node.set['mysql']['max_insert_delayed_threads']	= "#{db_params['max_insert_delayed_threads']['value']}"
end
if db_params['max_insert_delayed_threads'].nil?
  node.set['mysql']['max_insert_delayed_threads']	= nil
end
unless db_params['max_join_size'].nil?
  node.set['mysql']['max_join_size']	= "#{db_params['max_join_size']['value']}"
end
if db_params['max_join_size'].nil?
  node.set['mysql']['max_join_size']	= nil
end
unless db_params['max_length_for_sort_data'].nil?
  node.set['mysql']['max_length_for_sort_data']	= "#{db_params['max_length_for_sort_data']['value']}"
end
if db_params['max_length_for_sort_data'].nil?
  node.set['mysql']['max_length_for_sort_data']	= nil
end
unless db_params['max_prepared_stmt_count'].nil?
  node.set['mysql']['max_prepared_stmt_count']	= "#{db_params['max_prepared_stmt_count']['value']}"
end
if db_params['max_prepared_stmt_count'].nil?
  node.set['mysql']['max_prepared_stmt_count']	= nil
end
unless db_params['max_seeks_for_key'].nil?
  node.set['mysql']['max_seeks_for_key']	= "#{db_params['max_seeks_for_key']['value']}"
end
if db_params['max_seeks_for_key'].nil?
  node.set['mysql']['max_seeks_for_key']	= nil
end
unless db_params['max_sort_length'].nil?
  node.set['mysql']['max_sort_length']	= "#{db_params['max_sort_length']['value']}"
end
if db_params['max_sort_length'].nil?
  node.set['mysql']['max_sort_length']	= nil
end
unless db_params['max_sp_recursion_depth'].nil?
  node.set['mysql']['max_sp_recursion_depth']	= "#{db_params['max_sp_recursion_depth']['value']}"
end
if db_params['max_sp_recursion_depth'].nil?
  node.set['mysql']['max_sp_recursion_depth']	= nil
end
unless db_params['max_tmp_tables'].nil?
  node.set['mysql']['max_tmp_tables']	= "#{db_params['max_tmp_tables']['value']}"
end
if db_params['max_tmp_tables'].nil?
  node.set['mysql']['max_tmp_tables']	= nil
end
unless db_params['max_user_connections'].nil?
  node.set['mysql']['max_user_connections']	= "#{db_params['max_user_connections']['value']}"
end
if db_params['max_user_connections'].nil?
  node.set['mysql']['max_user_connections']	= nil
end
unless db_params['max_write_lock_count'].nil?
  node.set['mysql']['max_write_lock_count']	= "#{db_params['max_write_lock_count']['value']}"
end
if db_params['max_write_lock_count'].nil?
  node.set['mysql']['max_write_lock_count']	= nil
end
unless db_params['metadata_locks_cache_size'].nil?
  node.set['mysql']['metadata_locks_cache_size']	= "#{db_params['metadata_locks_cache_sizes']['value']}"
end
if db_params['metadata_locks_cache_size'].nil?
  node.set['mysql']['metadata_locks_cache_size']	= nil
end
unless db_params['min_examined_row_limit'].nil?
  node.set['mysql']['min_examined_row_limit']	= "#{db_params['min_examined_row_limit']['value']}"
end
if db_params['min_examined_row_limit'].nil?
  node.set['mysql']['min_examined_row_limit']	= nil
end
unless db_params['myisam_data_pointer_size'].nil?
  node.set['mysql']['myisam_data_pointer_size']	= "#{db_params['myisam_data_pointer_size']['value']}"
end
if db_params['myisam_data_pointer_size'].nil?
  node.set['mysql']['myisam_data_pointer_size']	= nil
end
unless db_params['myisam_max_sort_file_size'].nil?
  node.set['mysql']['myisam_max_sort_file_size']	= "#{db_params['myisam_max_sort_file_size']['value']}"
end
if db_params['myisam_max_sort_file_size'].nil?
  node.set['mysql']['myisam_max_sort_file_size']	= nil
end
unless db_params['myisam_mmap_size'].nil?
  node.set['mysql']['myisam_mmap_size']	= "#{db_params['myisam_mmap_size']['value']}"
end
if db_params['myisam_mmap_size'].nil?
  node.set['mysql']['myisam_mmap_size']	= nil
end
unless db_params['myisam_sort_buffer_size'].nil?
  node.set['mysql']['myisam_sort_buffer_size']	= "#{db_params['myisam_sort_buffer_size']['value']}"
end
if db_params['myisam_sort_buffer_size'].nil?
  node.set['mysql']['myisam_sort_buffer_size']	= nil
end
unless db_params['myisam_stats_method'].nil?
  node.set['mysql']['myisam_stats_method']	= "#{db_params['myisam_stats_method']['value']}"
end
if db_params['myisam_stats_method'].nil?
  node.set['mysql']['myisam_stats_method']	= nil
end
unless db_params['myisam_use_mmap'].nil?
  node.set['mysql']['myisam_use_mmap']	= "#{db_params['myisam_use_mmap']['value']}"
end
if db_params['myisam_use_mmap'].nil?
  node.set['mysql']['myisam_use_mmap']	= nil
end
unless db_params['net_buffer_length'].nil?
  node.set['mysql']['net_buffer_length']	= "#{db_params['net_buffer_length']['value']}"
end
if db_params['net_buffer_length'].nil?
  node.set['mysql']['net_buffer_length']	= nil
end
unless db_params['net_read_timeout'].nil?
  node.set['mysql']['net_read_timeout']	= "#{db_params['net_read_timeout']['value']}"
end
if db_params['net_read_timeout'].nil?
  node.set['mysql']['net_read_timeout']	= nil
end
unless db_params['net_retry_count'].nil?
  node.set['mysql']['net_retry_count']	= "#{db_params['net_retry_count']['value']}"
end
if db_params['net_retry_count'].nil?
  node.set['mysql']['net_retry_count']	= nil
end
unless db_params['net_write_timeout'].nil?
  node.set['mysql']['net_write_timeout']	= "#{db_params['net_write_timeout']['value']}"
end
if db_params['net_write_timeout'].nil?
  node.set['mysql']['net_write_timeout']	= nil
end
unless db_params['old-style-user-limits'].nil?
  node.set['mysql']['old-style-user-limits']	= "#{db_params['old-style-user-limits']['value']}"
end
if db_params['old-style-user-limits'].nil?
  node.set['mysql']['old-style-user-limits']	= nil
end
unless db_params['old_passwords'].nil?
  node.set['mysql']['old_passwords']	= "#{db_params['old_passwords']['value']}"
end
if db_params['old_passwords'].nil?
  node.set['mysql']['old_passwords']	= nil
end
unless db_params['optimizer_prune_level'].nil?
  node.set['mysql']['optimizer_prune_level']	= "#{db_params['optimizer_prune_level']['value']}"
end
if db_params['optimizer_prune_level'].nil?
  node.set['mysql']['optimizer_prune_level']	= nil
end
unless db_params['optimizer_search_depth'].nil?
  node.set['mysql']['optimizer_search_depth']	= "#{db_params['optimizer_search_depth']['value']}"
end
if db_params['optimizer_search_depth'].nil?
  node.set['mysql']['optimizer_search_depth']	= nil
end
unless db_params['optimizer_switch'].nil?
  node.set['mysql']['optimizer_switch']	= "#{db_params['optimizer_switch']['value']}"
end
if db_params['optimizer_switch'].nil?
  node.set['mysql']['optimizer_switch']	= nil
end
unless db_params['performance_schema'].nil?
  node.set['mysql']['performance_schema']	= "#{db_params['performance_schema']['value']}"
end
if (node['mysql']['plugin_dir'].nil? && (!db_params['plugin_dir'].nil?))
  node.set['mysql']['plugin_dir']	= "#{db_params['plugin_dir']['value']}"
end
unless db_params['preload_buffer_size'].nil?
  node.set['mysql']['preload_buffer_size']	= "#{db_params['preload_buffer_size']['value']}"
end
if db_params['preload_buffer_size'].nil?
  node.set['mysql']['preload_buffer_size']	= nil
end
unless db_params['profiling_history_size'].nil?
  node.set['mysql']['profiling_history_size']	= "#{db_params['profiling_history_size']['value']}"
end
if db_params['profiling_history_size'].nil?
  node.set['mysql']['profiling_history_size']	= nil
end
unless db_params['query_alloc_block_size'].nil?
  node.set['mysql']['query_alloc_block_size']	= "#{db_params['query_alloc_block_size']['value']}"
end
if db_params['query_alloc_block_size'].nil?
  node.set['mysql']['query_alloc_block_size']	= nil
end
unless db_params['query_cache_limit'].nil?
  node.set['mysql']['query_cache_limit']	= "#{db_params['query_cache_limit']['value']}"
end
if db_params['query_cache_limit'].nil?
  node.set['mysql']['query_cache_limit']	= nil
end
unless db_params['query_cache_min_res_unit'].nil?
  node.set['mysql']['query_cache_min_res_unit']	= "#{db_params['query_cache_min_res_unit']['value']}"
end
if db_params['query_cache_min_res_unit'].nil?
  node.set['mysql']['query_cache_min_res_unit']	= nil
end
unless db_params['query_cache_wlock_invalidate'].nil?
  node.set['mysql']['query_cache_wlock_invalidate']	= "#{db_params['query_cache_wlock_invalidate']['value']}"
end
if db_params['query_cache_wlock_invalidate'].nil?
  node.set['mysql']['query_cache_wlock_invalidate']	= nil
end
unless db_params['query_prealloc_size'].nil?
  node.set['mysql']['query_prealloc_size']	= "#{db_params['query_prealloc_size']['value']}"
end
if db_params['query_prealloc_size'].nil?
  node.set['mysql']['query_prealloc_size']	= nil
end
unless db_params['range_alloc_block_size'].nil?
  node.set['mysql']['range_alloc_block_size']	= "#{db_params['range_alloc_block_size']['value']}"
end
if db_params['range_alloc_block_size'].nil?
  node.set['mysql']['range_alloc_block_size']	= nil
end
unless db_params['safe-user-create'].nil?
  node.set['mysql']['safe-user-create']	= "#{db_params['safe-user-create']['value']}"
end
if db_params['safe-user-create'].nil?
  node.set['mysql']['safe-user-create']	= nil
end
unless db_params['secure_auth'].nil?
  node.set['mysql']['secure_auth']	= "#{db_params['secure_auth']['value']}"
end
if db_params['secure_auth'].nil?
  node.set['mysql']['secure_auth']	= nil
end
unless db_params['skip-character-set-client-handshake'].nil?
  node.set['mysql']['skip-character-set-client-handshake']	= "#{db_params['skip-character-set-client-handshake']['value']}"
end
if db_params['skip-character-set-client-handshake'].nil?
  node.set['mysql']['skip-character-set-client-handshake']	= nil
end
if (node['mysql']['skip_external_locking'].nil? && (!db_params['skip_external_locking'].nil?))
  node.set['mysql']['skip_external_locking']	= "#{db_params['skip_external_locking']['value']}"
end
unless db_params['skip_name_resolve'].nil?
  node.set['mysql']['skip_name_resolve']	= "#{db_params['skip_name_resolve']['value']}"
end
if db_params['skip_name_resolve'].nil?
  node.set['mysql']['skip_name_resolve']	= nil
end
if (node['mysql']['skip_show_database'].nil? && (!db_params['skip_show_database'].nil?))
  node.set['mysql']['skip_show_database']	= "#{db_params['skip_show_database']['value']}"
end
unless db_params['slow_launch_time'].nil?
  node.set['mysql']['slow_launch_time']	= "#{db_params['slow_launch_time']['value']}"
end
if db_params['slow_launch_time'].nil?
  node.set['mysql']['slow_launch_time']	= nil
end
unless db_params['sql_mode'].nil?
  node.set['mysql']['sql_mode']	= "#{db_params['sql_mode']['value']}"
end
if db_params['sql_mode'].nil?
  node.set['mysql']['sql_mode']	= nil
end
unless db_params['sql_select_limit'].nil?
  node.set['mysql']['sql_select_limit']	= "#{db_params['sql_select_limit']['value']}"
end
if db_params['sql_select_limit'].nil?
  node.set['mysql']['sql_select_limit']	= nil
end
unless db_params['sync_binlog'].nil?
  node.set['mysql']['sync_binlog']	= "#{db_params['sync_binlog']['value']}"
end
if db_params['sync_binlog'].nil?
  node.set['mysql']['sync_binlog']	= nil
end
unless db_params['sync_frm'].nil?
  node.set['mysql']['sync_frm']	= "#{db_params['sync_frm']['value']}"
end
if db_params['sync_frm'].nil?
  node.set['mysql']['sync_frm']	= nil
end
unless db_params['sysdate-is-now'].nil?
  node.set['mysql']['sysdate-is-now']	= "#{db_params['sysdate-is-now']['value']}"
end
if db_params['sysdate-is-now'].nil?
  node.set['mysql']['sysdate-is-now']	= nil
end
unless db_params['table_definition_cache'].nil?
  node.set['mysql']['table_definition_cache']	= "#{db_params['table_definition_cache']['value']}"
end
if db_params['table_definition_cache'].nil?
  node.set['mysql']['table_definition_cache']	= nil
end
unless db_params['table_open_cache'].nil?
  node.set['mysql']['table_open_cache']	= "#{db_params['table_open_cache']['value']}"
end
if db_params['table_open_cache'].nil?
  node.set['mysql']['table_open_cache']	= nil
end
unless db_params['temp-pool'].nil?
  node.set['mysql']['temp-pool']	= "#{db_params['temp-pool']['value']}"
end
if db_params['temp-pool'].nil?
  node.set['mysql']['temp-pool']	= nil
end
unless db_params['timed_mutexes'].nil?
  node.set['mysql']['timed_mutexes']	= "#{db_params['timed_mutexes']['value']}"
end
if db_params['timed_mutexes'].nil?
  node.set['mysql']['timed_mutexes']	= nil
end
unless db_params['transaction_alloc_block_size'].nil?
  node.set['mysql']['transaction_alloc_block_size']	= "#{db_params['transaction_alloc_block_size']['value']}"
end
if db_params['transaction_alloc_block_size'].nil?
  node.set['mysql']['transaction_alloc_block_size']	= nil
end
unless db_params['transaction_prealloc_size'].nil?
  node.set['mysql']['transaction_prealloc_size']	= "#{db_params['transaction_prealloc_size']['value']}"
end
if db_params['transaction_prealloc_size'].nil?
  node.set['mysql']['transaction_prealloc_size']	= nil
end
unless db_params['tx_isolation'].nil?
  node.set['mysql']['tx_isolation']	= "#{db_params['tx_isolation']['value']}"
end
if db_params['tx_isolation'].nil?
  node.set['mysql']['tx_isolation']	= nil
end
unless db_params['updatable_views_with_limit'].nil?
  node.set['mysql']['updatable_views_with_limit']	= "#{db_params['updatable_views_with_limit']['value']}"
end
if db_params['updatable_views_with_limit'].nil?
  node.set['mysql']['updatable_views_with_limit']	= nil
end
unless db_params['wait_timeout'].nil?
  node.set['mysql']['wait_timeout']	= "#{db_params['wait_timeout']['value']}"
end
if db_params['wait_timeout'].nil?
  node.set['mysql']['wait_timeout']	= nil
end
# -------------------------------------------------------------------------------------------------

# ------------------------ Attach/Mount the volume and format the volume ---------------------------------
# look for the device, start with KVM model
disk = node[:mysql][:volume][:device]
disk0 = ""
if disk.nil?
  if node[:virtualization][:system].eql? "kvm"
    devid = Dir.glob('/dev/vd?').sort.last[-1,1].succ
    disk0 = "vd" + devid
  end
  # now look for the device in XEN model if nothing if found previously
  if node[:virtualization][:system].eql? "xen"
    devid = Dir.glob('/dev/xvd?').sort.last[-1,1].succ
    disk0 = "xvd" + devid
  end
  if node[:virtualization][:system].eql? "lxc"
    # TODO
  end

  disk = "/dev/" + disk0
  diskEnc = "%2Fdev%2F" + disk0
  Chef::Log.info("Virtual disk name is " + disk)

  # Call RDSQuery server to attach the volume to the next device available
  http_request "Signal server to attach the volume" do
    action :post
    url "#{req_params['ServletUrl']}?Action=MountDBVolume&AcId=#{req_params['AcId']}&StackId=#{req_params['StackId']}&Device=#{diskEnc}"
  end

  # wait for the next available virtual device
  ruby_block "wait for volume attachment" do
    block do
	  lim = 0
	  while (!File.exists?(disk) && lim < 50) do
	    sleep(10)
	    lim += 1
	  end
	  if (!File.exists?(disk) && lim == 50)
	    Chef::Log.info(disk + " was never attached!")
		http_request "FailHook0" do
	      url "#{req_params['PostWaitUrl']}?Action=RemoteFailSignal&StackId=#{req_params['StackId']}&AcId=#{req_params['AcId']}"
		  action :post
		end
	  end
    end
  end

  # rewrite the /etc/fstab written by cloudinit; manage the volumes with chef instead
  bash "modify /etc/fstab" do
	user "root"
	cwd "/etc"
	code <<-EOC
	DEVICE=`mount | grep -i "on / " | awk '{print $1}'`
	TYPE=` mount | grep -i "on / " | awk '{print $5}'`
	echo -e "$DEVICE\t/\t$TYPE\tdefaults\t0\t0\n#{disk}\t/rdsdbdata\text3\tdefaults,bootwait\t0\t2" > /etc/fstab
	EOC
  end

  node.set[:mysql][:volume][:device] = disk
  node.save
end

# don't do anything until volume is attached
if ((!disk.nil?) && (!disk.eql? "/dev/"))

# create a directory to mount data volume
directory "create mount directory" do
  path "/rdsdbdata"
  owner "root"
  group "root"
  mode "0755"
  action :create
  only_if do !File.exists?("/rdsdbdata") end
end

=begin
rebooted = node[:mysql][:rebooted]
if !rebooted
  # check if reboot is needed; it's needed when the disk we picked is already formatted/mounted => attachment was unsuccessful, so reboot to fix it
  bash "check mounts" do
    user "root"
    cwd "/tmp"
    code <<-EOH
  	volume=#{disk}
  	if mount|grep $volume; then
  	  touch /tmp/reboot_needed
  	else
  	  echo "not mounted"
  	fi
    EOH
  end

  # reboot the instance if necessary; rebooting will attach the device correctly
  Chef::Log.debug("Restarting this instance to fix the volume attachment problem.")
  execute "rm /tmp/reboot_needed && reboot" do
    node[:mysql][:rebooted] = true
	node.save
    action :run
    only_if do File.exists?("/tmp/reboot_needed") end
  end  

  execute "sleep 5" do
    action :run
  end
end
=end

# format the volume
execute "mkfs.ext3 -F #{disk}" do
  action :run
  only_if do !File.exists?("/rdsdbdata/lost+found") end
end

# mount the volume; xvdb is always picked for XEN, Ruby File has to run detection for KVM
execute "mount #{disk} /rdsdbdata" do
  action :run
  only_if do !File.exists?("/rdsdbdata/lost+found") end
end
# -------------------------------------------------------------------------------------------------

# --------------------- Run OS-specific errands for debian and ubuntu -----------------------------
if platform?(%w{debian ubuntu})

  directory "/var/cache/local/preseeding" do
    owner "root"
    group "root"
    mode 0755
    recursive true
	only_if do !File.exists?("/var/cache/local/preseeding") end
  end

  execute "preseed mysql-server" do
    command "debconf-set-selections /var/cache/local/preseeding/mysql-server.seed"
    action :nothing
  end

  template "/var/cache/local/preseeding/mysql-server.seed" do
    source "mysql-server.seed.erb"
    owner "root"
    group "root"
    mode "0600"
	only_if do !File.exists?("/var/cache/local/preseeding/mysql-server.seed") end
    notifies :run, resources(:execute => "preseed mysql-server"), :immediately
  end

  directory "/etc/mysql" do
    owner "root"
    group "root"
    mode 0755
    recursive true
	only_if do !File.exists?("/etc/mysql") end
  end

  template "/etc/mysql/debian.cnf" do
    source "debian.cnf.erb"
    owner "root"
    group "root"
    mode "0644"
	only_if do !File.exists?("/etc/mysql/debian.cnf") end
  end
end
# -------------------------------------------------------------------------------------------------

# --------------------- Modify the chef-client run configuration -----------------------------
template "/etc/default/chef-client" do
  source "chef-client.erb"
  owner "root"
  group "root"
  mode "0600"
  not_if { File.exists? "/rdsdbdata/first_run" }
end
# -------------------------------------------------------------------------------------------------

# ------------------- Install mysql-server and define the service ---------------------------------
execute "mysql-server print" do
 command "echo '\n\npackage mysql-server\n\n'"
end

execute "apt-get-update" do
  command "apt-get update"
  not_if { File.exists? "/rdsdbdata/first_run" }
end

# package "mysql-server" do
#   action :install
#   notifies :run, resources(:execute => "master user password is blank"), :immediately
#   not_if { File.exists? "/rdsdbdata/first_run" }
# end

ruby_block "topstack install mysql-server" do
    block do
	include_recipe "transcend_topstack_host::install"
    end
    notifies :run, resources(:execute => "master user password is blank"), :immediately
    not_if { File.exists? "/rdsdbdata/first_run" }
end

service "mysql" do
  service_name value_for_platform([ "centos", "redhat", "suse", "fedora", "scientific", "amazon" ] => {"default" => "mysqld"}, "default" => "mysql")
  if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
    restart_command "restart mysql"
    stop_command "stop mysql"
    start_command "start mysql"
  end
  supports :status => true, :restart => true, :reload => true
  action :nothing
end
# -------------------------------------------------------------------------------------------------

# --------------------------------------- create softlink for basedir -----------------------------
basedir = node['mysql']['conf_dir']
if basedir.rindex('/') == (basedir.length - 1)
  basedir = basedir[0, basedir.length - 1]
end
unless basedir.rindex('/').nil?
  basedir = basedir[0, basedir.rindex('/')]
end
directory "#{basedir}" do
  owner "mysql"
  group "adm"
  mode "0755"
  recursive true
  action :create
  not_if { File.exists? "/rdsdbdata/first_run" }
end

execute "Softlink for basedir" do
  basedirSL = node['mysql']['conf_dir']
  if basedirSL.rindex('/') == (basedirSL.length - 1)
    basedirSL = basedirSL[0, basedirSL.length - 1]
  end
  command "ln -s /usr " + basedirSL
  action :run
  not_if { File.exists? "#{basedirSL}/usr" }
  not_if { File.exists? "/rdsdbdata/first_run" }
end
# -------------------------------------------------------------------------------------------------

# ------------------------------ Create log-bin directory and log file ----------------------------

logbindir = node['mysql']['log-bin']
unless logbindir.rindex('/').nil?
  logbindir = logbindir[0, logbindir.rindex('/') + 1]
end
directory "#{logbindir}" do
  owner "mysql"
  group "adm"
  mode "0755"
  recursive true
  action :create
end

logbinFN = node['mysql']['log-bin']
unless logbinFN[-6, 6].eql? ".index"
  logbinFN = logbinFN + ".index"
end
file "#{logbinFN}" do
  owner "mysql"
  group "adm"
  mode "0755"
  action :create
end

# -------------------------------------------------------------------------------------------------

# ------------------------------ Create relay-log directory and log file ----------------------------

logRelay = node['mysql']['relay-log']
unless logRelay.rindex('/').nil?
  logRelay = logRelay[0, logRelay.rindex('/') + 1]
end
directory "#{logRelay}" do
  owner "mysql"
  group "adm"
  mode "0755"
  recursive true
  action :create
end

logRelayFN = node['mysql']['relay-log']
unless logRelayFN[-6, 6].eql? ".index"
  logRelayFN = logRelayFN + ".index"
end
file "#{logRelayFN}" do
  owner "mysql"
  group "adm"
  mode "0755"
  action :create
end

# -------------------------------------------------------------------------------------------------

# ----------------------------------------- move the datadir --------------------------------------
directory "#{node['mysql']['data_dir']}" do
  owner "mysql"
  group "adm"
  mode "0755"
  recursive true
  action :create
  # notifies :stop, resources(:service => "mysql"), :immediately
  not_if { File.exists? "#{node['mysql']['data_dir']}" }
end

execute "Copy files from old datadir to new datadir" do
  command "mv /var/lib/mysql/* #{node['mysql']['data_dir']}"
  action :run
  only_if { File.exists? "/var/lib/mysql/#{node['hostname']}.pid" }
end

# -------------------------------------------------------------------------------------------------

# ----------------------------------------- create tmpdir -----------------------------------------
directory "#{node['mysql']['tmpdir']}" do
  owner "mysql"
  group "adm"
  mode "1777"
  recursive true
  action :create
  not_if { File.exists? "#{node['mysql']['tmpdir']}" }
end
# -------------------------------------------------------------------------------------------------

# ---------------------------------- create innodb_data_home_dir -----------------------------------
directory "#{node['mysql']['innodb_data_home_dir']}" do
  owner "mysql"
  group "adm"
  mode "0775"
  recursive true
  action :create
  not_if { File.exists? "#{node['mysql']['innodb_data_home_dir']}" }
end

directory "#{node['mysql']['innodb_log_group_home_dir']}" do
  owner "mysql"
  group "adm"
  mode "0775"
  recursive true
  action :create
  not_if { File.exists? "#{node['mysql']['innodb_log_group_home_dir']}" }
end
# -------------------------------------------------------------------------------------------------

# ----------------------------------- create pid-file directory -----------------------------------
pidfiledir = "#{node['mysql']['pid_file']}"
pidfiledir = pidfiledir[0, pidfiledir.rindex('/')]
directory "#{pidfiledir}" do
  owner "mysql"
  group "adm"
  mode "0775"
  recursive true
  action :create
  not_if { File.exists? "#{pidfiledir}" }
end

execute "chown #{pidfiledir}" do
  command "chown mysql:adm #{pidfiledir}"
  action :run
end
# -------------------------------------------------------------------------------------------------

# ---------------------------------- update and restart apparmor ----------------------------------

# TODO Resources below can be used only in Ubuntu 11; Ubuntu 12 does not seem to have apparmor

template "/etc/apparmor.d/usr.sbin.mysqld" do
  logbindir = node['mysql']['log-bin']
  unless logbindir.rindex('/').nil?
    logbindir = logbindir[0, logbindir.rindex('/') + 1]
  end
  relaylogdir = node['mysql']['relay-log']
  unless relaylogdir.rindex('/').nil?
    relaylogdir = relaylogdir[0, relaylogdir.rindex('/') + 1]
  end
  variables(:logbindir => logbindir, :pidfiledir => pidfiledir, :relaylogdir => relaylogdir)
  source "usr.sbin.mysqld.erb"
  owner "root"
  group "root"
  mode "0600"
  not_if { ! File.exists? "/etc/apparmor.d" }
  not_if { File.exists? "/rdsdbdata/first_run" }
end

execute "Restart apparmor" do
  command "/etc/init.d/apparmor restart"
  action :run
  notifies :start, resources(:service => "mysql"), :immediately
  not_if { ! File.exists? "/etc/init.d/apparmor" }
  not_if { File.exists? "/rdsdbdata/first_run" }
end

# -------------------------------------------------------------------------------------------------


# ---------------------------- Populate the my.cnf and put it into use ----------------------------
skip_federated = case node['platform']
                 when 'fedora', 'ubuntu', 'amazon'
                   true
                 when 'centos', 'redhat', 'scientific'
                   node['platform_version'].to_f < 6.0
                 else
                   false
                 end

execute "Repopulate mysql core tables at new locations" do
  command "mysql_install_db --user=mysql --basedir=#{node['mysql']['conf_dir']} --datadir=#{node['mysql']['data_dir']}"
  action :run
  notifies :run, resources(:execute => "master user password is blank"), :immediately
  not_if { File.exists? "/rdsdbdata/first_run" }
end

template "/etc/mysql/my.cnf" do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mysql"), :immediately
  variables :skip_federated => skip_federated
end
# -------------------------------------------------------------------------------------------------

# ------------- Set root password w/o pre-seeding for OS other than debian and ubuntu -------------
unless platform?(%w{debian ubuntu})
  execute "assign-root-password" do
    command "/usr/bin/mysqladmin -uroot password #{node['mysql']['server_root_password']}"
    action :run
    only_if "/usr/bin/mysql -u #{node['mysql']['root_user']} -e 'show databases;'"
  end
end
# -------------------------------------------------------------------------------------------------

# --------------------------------- Add a new mysql root user -------------------------------------
execute "Reset root password" do
  command "mysqladmin -u root password '#{node['mysql']['server_root_password']}';echo '\n\nReset root password\n\n'"
  action :run
  notifies :run, "execute[master user password is blank]", :immediately
end

execute "run createUser.sh" do
  command "sh #{node[:mysql][:conf_dir]}/createUser.sh; echo '\n\nrun createUser.sh\n\n'"
  action :nothing
  notifies :run, "execute[master user password is blank]", :immediately
  not_if { File.exists? "/rdsdbdata/first_run" }
end
template "#{node[:mysql][:conf_dir]}/createUser.sh" do
  source "createUser.sh.erb"
  owner "root"
  group "root"
  mode "0755"
  not_if { File.exists? "#{node[:mysql][:conf_dir]}/createUser.sh" }
  notifies :run, resources(:execute => "run createUser.sh"), :immediately
  notifies :run, resources(:execute => "master user password is blank"), :immediately
  not_if { File.exists? "/rdsdbdata/first_run" }
end

# -------------------------------------------------------------------------------------------------

# --------------------- Either pick up the old grants path or create a new one --------------------
grants_path = "/etc/mysql/mysql_grants.sql"

begin
  t = resources("template[#{grants_path}]")
rescue
  Chef::Log.info("Could not find previously defined grants.sql resource")
  t = template grants_path do
    source "grants.sql.erb"
    owner "root"
    group "root"
    mode "0600"
    action :create
	not_if { File.exists? "/rdsdbdata/first_run" }
  end
end
# -------------------------------------------------------------------------------------------------

# --------------------- Edit mysql privileges -------------------------------------------------
execute "mysql-install-privileges" do
  command "/usr/bin/mysql -uroot #{node['mysql']['server_root_password'].empty? ? '' : '-p' }#{node['mysql']['server_root_password']} < #{grants_path}"
  action :nothing
  subscribes :run, resources("template[#{grants_path}]"), :immediately
  not_if { File.exists? "/rdsdbdata/first_run" }
end
# -------------------------------------------------------------------------------------------------

# ----------------------------------- Save the node data ------------------------------------------
unless Chef::Config[:solo]
  ruby_block "save node data" do
    block do
      node.save
    end
    action :create
  end
end
# -------------------------------------------------------------------------------------------------

# -------------------- Call percona_xtrabackup recipe to install backup tools ---------------------
include_recipe "transcend_mysql::percona_xtrabackup"
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
if req_params['PostWaitUrl'].nil?
  Chef::Log.info("No PostWait call required")
else
  url = "#{req_params['PostWaitUrl']}?Action=PostWait&PhysicalId=#{req_params['PhysicalId']}&StackId=#{req_params['StackId']}&AcId=#{req_params['AcId']}&Status=success&Restoring=#{req_params['RestoredDBInstance']}"
  Chef::Log.info("PostWait Call to: " + "#{url}")
end

http_request "postwait" do
  action :post
  url "#{url}"
  not_if { File.exists? "/rdsdbdata/first_run" }
end

if(File.exists? "#{node[:mysql][:conf_dir]}/createUser.sh")
  req_params['PostWaitUrl'] = nil
  req_params['RestoredDBInstance'] = "false"
end

config.save
# -------------------------------------------------------------------------------------------------

execute "touch /rdsdbdata/first_run" do
  action :run
  not_if { File.exists? "/rdsdbdata/first_run" }
end

end
