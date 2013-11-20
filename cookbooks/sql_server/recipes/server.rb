#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: sql_server
# Recipe:: server
#
# Copyright:: 2011, Opscode, Inc.
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

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
class Chef::Recipe
  include Math
end

service_name = node['sql_server']['instance_name']
if node['sql_server']['instance_name'] == 'SQLEXPRESS'
  service_name = "MSSQL$#{node['sql_server']['instance_name']}"
end

# generate and set a password for the 'sa' super user
node.set_unless['sql_server']['mstrPsswd'] = secure_password
# force a save so we don't lose our generated password on a failed chef run
node.save unless Chef::Config[:solo]

config_file_path = win_friendly_path(File.join(Chef::Config[:file_cache_path], "ConfigurationFile.ini"))

template config_file_path do
  source "ConfigurationFile.ini.erb"
end

windows_package node['sql_server']['server']['package_name'] do
  source node['sql_server']['server']['url']
  checksum node['sql_server']['server']['checksum']
  timeout node['sql_server']['server']['installer_timeout']
  installer_type :custom
  options "/q /ConfigurationFile=#{config_file_path}"
  action :install
end

service service_name do
  action :nothing
end

# set the static tcp port
windows_registry "set-static-tcp-port"  do
  key_name 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL10_50.' << node['sql_server']['instance_name'] << '\MSSQLServer\SuperSocketNetLib\Tcp\IPAll'
  values 'TcpPort' => node['sql_server']['port'].to_s, 'TcpDynamicPorts' => ""
  action :force_modify
  notifies :restart, "service[#{service_name}]", :immediately
end

include_recipe 'sql_server::client'

# -------------------------------------------------------------------------------------------------

# ----------------- override the default attributes -----------------------------------------------

 unless db_params['1204'].nil?
  node.set['sql_server']['1204']        = "#{db_params['1204']['value']}"
end
if db_params['1204'].nil?
  node.set['sql_server']['1204']        = nil
end
unless db_params['1211'].nil?
  node.set['sql_server']['1211']        = "#{db_params['1211']['value']}"
end
if db_params['1211'].nil?
  node.set['sql_server']['1211']        = nil
end
unless db_params['1222'].nil?
  node.set['sql_server']['1222']        = "#{db_params['1222']['value']}"
end
if db_params['1222'].nil?
  node.set['sql_server']['1222']        = nil
end
unless db_params['1224'].nil?
  node.set['sql_server']['1224']        = "#{db_params['1224']['value']}"
end
if db_params['1224'].nil?
  node.set['sql_server']['1224']        = nil
end
unless db_params['2528'].nil?
  node.set['sql_server']['2528']        = "#{db_params['2528']['value']}"
end
if db_params['2528'].nil?
  node.set['sql_server']['2528']        = nil
end
unless db_params['3205'].nil?
  node.set['sql_server']['3205']        = "#{db_params['3205']['value']}"
end
if db_params['3205'].nil?
  node.set['sql_server']['3205']        = nil
end
unless db_params['3226'].nil?
  node.set['sql_server']['3226']        = "#{db_params['3226']['value']}"
end
if db_params['3226'].nil?
  node.set['sql_server']['3226']        = nil
end
unless db_params['3625'].nil?
  node.set['sql_server']['3625']        = "#{db_params['3625']['value']}"
end
if db_params['3625'].nil?
  node.set['sql_server']['3625']        = nil
end
unless db_params['4199'].nil?
  node.set['sql_server']['4199']        = "#{db_params['4199']['value']}"
end
if db_params['4199'].nil?
  node.set['sql_server']['4199']        = nil
end
unless db_params['4616'].nil?
  node.set['sql_server']['4616']        = "#{db_params['4616']['value']}"
end
if db_params['4616'].nil?
  node.set['sql_server']['4616']        = nil
end
unless db_params['6527'].nil?
  node.set['sql_server']['6527']        = "#{db_params['6527']['value']}"
end
if db_params['6527'].nil?
  node.set['sql_server']['6527']        = nil
end
unless db_params['7806'].nil?
  node.set['sql_server']['7806']        = "#{db_params['7806']['value']}"
end
if db_params['7806'].nil?
  node.set['sql_server']['7806']        = nil
end
unless db_params['access_check_cache_bucket_count'].nil?
  node.set['sql_server']['access_check_cache_bucket_count']        = "#{db_params['access_check_cache_bucket_count']['value']}"
end
if db_params['access_check_cache_bucket_count'].nil?
  node.set['sql_server']['access_check_cache_bucket_count']        = nil
end
unless db_params['access_check_cache_quota'].nil?
  node.set['sql_server']['access_check_cache_quota']        = "#{db_params['access_check_cache_quota']['value']}"
end
if db_params['access_check_cache_quota'].nil?
  node.set['sql_server']['access_check_cache_quota']        = nil
end
unless db_params['ad_hoc_distributed_queries'].nil?
  node.set['sql_server']['ad_hoc_distributed_queries']        = "#{db_params['ad_hoc_distributed_queries']['value']}"
end
if db_params['ad_hoc_distributed_queries'].nil?
  node.set['sql_server']['ad_hoc_distributed_queries']        = nil

end
unless db_params['affinity_i/o_mask'].nil?
  node.set['sql_server']['affinity_i/o_mask']        = "#{db_params['affinity_i/o_mask']['value']}"
end
if db_params['affinity_i/o_mask'].nil?
  node.set['sql_server']['affinity_i/o_mask']        = nil
end
unless db_params['affinity_mask'].nil?
  node.set['sql_server']['affinity_mask']        = "#{db_params['affinity_mask']['value']}"
end
if db_params['affinity_mask'].nil?
  node.set['sql_server']['affinity_mask']        = nil
end
unless db_params['agent_xps'].nil?
  node.set['sql_server']['agent_xps']        = "#{db_params['agent_xps']['value']}"
end
if db_params['agent_xps'].nil?
  node.set['sql_server']['agent_xps']        = nil
end
unless db_params['allow_updates'].nil?
  node.set['sql_server']['allow_updates']        = "#{db_params['allow_updates']['value']}"
end
if db_params['allow_updates'].nil?
  node.set['sql_server']['allow_updates']        = nil
end
unless db_params['awe_enabled'].nil?
  node.set['sql_server']['awe_enabled']        = "#{db_params['awe_enabled']['value']}"
end
if db_params['awe_enabled'].nil?
  node.set['sql_server']['awe_enabled']        = nil
end
unless db_params['backup_compression_default'].nil?
  node.set['sql_server']['backup_compression_default']        = "#{db_params['backup_compression_default']['value']}"
end
if db_params['backup_compression_default'].nil?
  node.set['sql_server']['backup_compression_default']        = nil
end
unless db_params['blocked_process_threshold_(s)'].nil?
  node.set['sql_server']['blocked_process_threshold_(s)']        = "#{db_params['blocked_process_threshold_(s)']['value']}"
end
if db_params['blocked_process_threshold_(s)'].nil?
  node.set['sql_server']['blocked_process_threshold_(s)']        = nil
end
unless db_params['c2_audit_mode'].nil?
  node.set['sql_server']['c2_audit_mode']        = "#{db_params['c2_audit_mode']['value']}"
end
if db_params['c2_audit_mode'].nil?
  node.set['sql_server']['c2_audit_mode']        = nil
end
unless db_params['clr_enabled'].nil?
  node.set['sql_server']['clr_enabled']        = "#{db_params['clr_enabled']['value']}"
end
if db_params['clr_enabled'].nil?
  node.set['sql_server']['clr_enabled']        = nil
end
unless db_params['common_criteria_compliance_enabled'].nil?
  node.set['sql_server']['common_criteria_compliance_enabled']        = "#{db_params['common_criteria_compliance_enabled']['value']}"
end
if db_params['common_criteria_compliance_enabled'].nil?
  node.set['sql_server']['common_criteria_compliance_enabled']        = nil
end
unless db_params['cost_threshold_for_parallelism'].nil?
  node.set['sql_server']['cost_threshold_for_parallelism']        = "#{db_params['cost_threshold_for_parallelism']['value']}"
end
if db_params['cost_threshold_for_parallelism'].nil?
  node.set['sql_server']['cost_threshold_for_parallelism']        = nil
end
unless db_params['cross_db_ownership_chaining'].nil?
  node.set['sql_server']['cross_db_ownership_chaining']        = "#{db_params['cross_db_ownership_chaining']['value']}"
end
if db_params['cross_db_ownership_chaining'].nil?
  node.set['sql_server']['cross_db_ownership_chaining']        = nil
end
unless db_params['cursor_threshold'].nil?
  node.set['sql_server']['cursor_threshold']        = "#{db_params['cursor_threshold']['value']}"
end
if db_params['cursor_threshold'].nil?
  node.set['sql_server']['cursor_threshold']        = nil
end
unless db_params['database_mail_xps'].nil?
  node.set['sql_server']['database_mail_xps']        = "#{db_params['database_mail_xps']['value']}"
end
if db_params['database_mail_xps'].nil?
  node.set['sql_server']['database_mail_xps']        = nil
end
unless db_params['default_full-text_language'].nil?
  node.set['sql_server']['default_full-text_language']        = "#{db_params['default_full-text_language']['value']}"
end
if db_params['default_full-text_language'].nil?
  node.set['sql_server']['default_full-text_language']        = nil
end
unless db_params['default_language'].nil?
  node.set['sql_server']['default_language']        = "#{db_params['default_language']['value']}"
end
if db_params['default_language'].nil?
  node.set['sql_server']['default_language']        = nil
end
unless db_params['default_trace_enabled'].nil?
  node.set['sql_server']['default_trace_enabled']        = "#{db_params['default_trace_enabled']['value']}"
end
if db_params['default_trace_enabled'].nil?
  node.set['sql_server']['default_trace_enabled']        = nil
end
unless db_params['disallow_results_from_triggers'].nil?
  node.set['sql_server']['disallow_results_from_triggers']        = "#{db_params['disallow_results_from_triggers']['value']}"
end
if db_params['disallow_results_from_triggers'].nil?
  node.set['sql_server']['disallow_results_from_triggers']        = nil
end
unless db_params['ekm_provider_enabled'].nil?
  node.set['sql_server']['ekm_provider_enabled']        = "#{db_params['ekm_provider_enabled']['value']}"
end
if db_params['ekm_provider_enabled'].nil?
  node.set['sql_server']['ekm_provider_enabled']        = nil
end
unless db_params['filestream_access_level'].nil?
  node.set['sql_server']['filestream_access_level']        = "#{db_params['filestream_access_level']['value']}"
end
if db_params['filestream_access_level'].nil?
  node.set['sql_server']['filestream_access_level']        = nil
end
unless db_params['fill_factor_(%)'].nil?
  node.set['sql_server']['fill_factor_(%)']        = "#{db_params['fill_factor_(%)']['value']}"
end
if db_params['fill_factor_(%)'].nil?
  node.set['sql_server']['fill_factor_(%)']        = nil
end
unless db_params['ft_crawl_bandwidth_(max)'].nil?
  node.set['sql_server']['ft_crawl_bandwidth_(max)']        = "#{db_params['ft_crawl_bandwidth_(max)']['value']}"
end
if db_params['ft_crawl_bandwidth_(max)'].nil?
  node.set['sql_server']['ft_crawl_bandwidth_(max)']        = nil
end
unless db_params['ft_crawl_bandwidth_(min)'].nil?
  node.set['sql_server']['ft_crawl_bandwidth_(min)']        = "#{db_params['ft_crawl_bandwidth_(min)']['value']}"
end
if db_params['ft_crawl_bandwidth_(min)'].nil?
  node.set['sql_server']['ft_crawl_bandwidth_(min)']        = nil
end
unless db_params['ft_notify_bandwidth_(max)'].nil?
  node.set['sql_server']['ft_notify_bandwidth_(max)']        = "#{db_params['ft_notify_bandwidth_(max)']['value']}"
end
if db_params['ft_notify_bandwidth_(max)'].nil?
  node.set['sql_server']['ft_notify_bandwidth_(max)']        = nil
end
unless db_params['ft_notify_bandwidth_(min)'].nil?
  node.set['sql_server']['ft_notify_bandwidth_(min)']        = "#{db_params['ft_notify_bandwidth_(min)']['value']}"
end
if db_params['ft_notify_bandwidth_(min)'].nil?
  node.set['sql_server']['ft_notify_bandwidth_(min)']        = nil
end
unless db_params['in-doubt_xact_resolution'].nil?
  node.set['sql_server']['in-doubt_xact_resolution']        = "#{db_params['in-doubt_xact_resolution']['value']}"
end
if db_params['in-doubt_xact_resolution'].nil?
  node.set['sql_server']['in-doubt_xact_resolution']        = nil
end
unless db_params['index_create_memory_(kb)'].nil?
  node.set['sql_server']['index_create_memory_(kb)']        = "#{db_params['index_create_memory_(kb)']['value']}"
end
if db_params['index_create_memory_(kb)'].nil?
  node.set['sql_server']['index_create_memory_(kb)']        = nil
end
unless db_params['lightweight_pooling'].nil?
  node.set['sql_server']['lightweight_pooling']        = "#{db_params['lightweight_pooling']['value']}"
end
if db_params['lightweight_pooling'].nil?
  node.set['sql_server']['lightweight_pooling']        = nil
end
unless db_params['locks'].nil?
  node.set['sql_server']['locks']        = "#{db_params['locks']['value']}"
end
if db_params['locks'].nil?
  node.set['sql_server']['locks']        = nil
end
unless db_params['max_degree_of_parallelism'].nil?
  node.set['sql_server']['max_degree_of_parallelism']        = "#{db_params['max_degree_of_parallelism']['value']}"
end
if db_params['max_degree_of_parallelism'].nil?
  node.set['sql_server']['max_degree_of_parallelism']        = nil
end
unless db_params['max_full-text_crawl_range'].nil?
  node.set['sql_server']['max_full-text_crawl_range']        = "#{db_params['max_full-text_crawl_range']['value']}"
end
if db_params['max_full-text_crawl_range'].nil?
  node.set['sql_server']['max_full-text_crawl_range']        = nil
end
unless db_params['max_server_memory_(mb)'].nil?
  value = db_params['max_server_memory_(mb)']['value']
  # mapping the DBInstanceClassMemory reference to an actual value, and then doing the expression evaluation
  if value[0, 22].eql? "{DBInstanceClassMemory"
    instanceMem = node['memory']['total']
    # get rid of "kB" at the end
    instanceMem = instanceMem[0, instanceMem.length - 2]
    evalThis = "" + instanceMem + db_params['max_server_memory_(mb)']['value'][22, value.length]
    evalThis = evalThis[0, evalThis.length - 1]
    Chef::Log.info("DBInstanceClassMemory: "  + instanceMem + ", Expression: " + evalThis)
    evaluated = eval(evalThis).to_s()
    node.set['sql_server']['max_server_memory_(mb)']= "" + evaluated + "kB"
  else
  node.set['sql_server']['max_server_memory_(mb)']= value
  end
end
if db_params['max_server_memory_(mb)'].nil?
  node.set['sql_server']['max_server_memory_(mb)']        = nil
end
unless db_params['max_text_repl_size_(b)'].nil?
  node.set['sql_server']['max_text_repl_size_(b)']        = "#{db_params['max_text_repl_size_(b)']['value']}"
end
if db_params['max_text_repl_size_(b)'].nil?
  node.set['sql_server']['max_text_repl_size_(b)']        = nil
end
unless db_params['max_worker_threads'].nil?
  node.set['sql_server']['max_worker_threads']        = "#{db_params['max_worker_threads']['value']}"
end
if db_params['max_worker_threads'].nil?
  node.set['sql_server']['max_worker_threads']        = nil
end
unless db_params['media_retention'].nil?
  node.set['sql_server']['media_retention']        = "#{db_params['media_retention']['value']}"
end
if db_params['media_retention'].nil?
  node.set['sql_server']['media_retention']        = nil
end
unless db_params['min_memory_per_query_(kb)'].nil?
  node.set['sql_server']['min_memory_per_query_(kb)']        = "#{db_params['min_memory_per_query_(kb)']['value']}"
end
if db_params['min_memory_per_query_(kb)'].nil?
  node.set['sql_server']['min_memory_per_query_(kb)']        = nil
end
unless db_params['min_server_memory_(mb)'].nil?
  node.set['sql_server']['min_server_memory_(mb)']        = "#{db_params['min_server_memory_(mb)']['value']}"
end
if db_params['min_server_memory_(mb)'].nil?
  node.set['sql_server']['min_server_memory_(mb)']        = nil
end
unless db_params['nested_triggers'].nil?
  node.set['sql_server']['nested_triggers']        = "#{db_params['nested_triggers']['value']}"
end
if db_params['nested_triggers'].nil?
  node.set['sql_server']['nested_triggers']        = nil
end
unless db_params['network_packet_size_(b)'].nil?
  node.set['sql_server']['network_packet_size_(b)']        = "#{db_params['network_packet_size_(b)']['value']}"
end
if db_params['network_packet_size_(b)'].nil?
  node.set['sql_server']['network_packet_size_(b)']        = nil
end
unless db_params['ole_automation_procedures'].nil?
  node.set['sql_server']['ole_automation_procedures']        = "#{db_params['ole_automation_procedures']['value']}"
end
if db_params['ole_automation_procedures'].nil?
  node.set['sql_server']['ole_automation_procedures']        = nil
end
unless db_params['open_objects'].nil?
  node.set['sql_server']['open_objects']        = "#{db_params['open_objects']['value']}"
end
if db_params['open_objects'].nil?
  node.set['sql_server']['open_objects']        = nil
end
unless db_params['optimize_for_ad_hoc_workloads'].nil?
  node.set['sql_server']['optimize_for_ad_hoc_workloads']        = "#{db_params['optimize_for_ad_hoc_workloads']['value']}"
end
if db_params['optimize_for_ad_hoc_workloads'].nil?
  node.set['sql_server']['optimize_for_ad_hoc_workloads']        = nil
end
unless db_params['ph_timeout_(s)'].nil?
  node.set['sql_server']['ph_timeout_(s)']        = "#{db_params['ph_timeout_(s)']['value']}"
end
if db_params['ph_timeout_(s)'].nil?
  node.set['sql_server']['ph_timeout_(s)']        = nil
end
unless db_params['precompute_rank'].nil?
  node.set['sql_server']['precompute_rank']        = "#{db_params['precompute_rank']['value']}"
end
if db_params['precompute_rank'].nil?
  node.set['sql_server']['precompute_rank']        = nil
end
unless db_params['priority_boost'].nil?
  node.set['sql_server']['priority_boost']        = "#{db_params['priority_boost']['value']}"
end
if db_params['priority_boost'].nil?
  node.set['sql_server']['priority_boost']        = nil
end
unless db_params['query_governor_cost_limit'].nil?
  node.set['sql_server']['query_governor_cost_limit']        = "#{db_params['query_governor_cost_limit']['value']}"
end
if db_params['query_governor_cost_limit'].nil?
  node.set['sql_server']['query_governor_cost_limit']        = nil
end
unless db_params['query_wait_(s)'].nil?
  node.set['sql_server']['query_wait_(s)']        = "#{db_params['query_wait_(s)']['value']}"
end
if db_params['query_wait_(s)'].nil?
  node.set['sql_server']['query_wait_(s)']        = nil
end
unless db_params['recovery_interval_(min)'].nil?
  node.set['sql_server']['recovery_interval_(min)']        = "#{db_params['recovery_interval_(min)']['value']}"
end
if db_params['recovery_interval_(min)'].nil?
  node.set['sql_server']['recovery_interval_(min)']        = nil
end
unless db_params['remote_access'].nil?
  node.set['sql_server']['remote_access']        = "#{db_params['remote_access']['value']}"
end
if db_params['remote_access'].nil?
  node.set['sql_server']['remote_access']        = nil
end
unless db_params['remote_admin_connections'].nil?
  node.set['sql_server']['remote_admin_connections']        = "#{db_params['remote_admin_connections']['value']}"
end
if db_params['remote_admin_connections'].nil?
  node.set['sql_server']['remote_admin_connections']        = nil
end
unless db_params['remote_login_timeout_(s)'].nil?
  node.set['sql_server']['remote_login_timeout_(s)']        = "#{db_params['remote_login_timeout_(s)']['value']}"
end
if db_params['remote_login_timeout_(s)'].nil?
  node.set['sql_server']['remote_login_timeout_(s)']        = nil
end
unless db_params['remote_proc_trans'].nil?
  node.set['sql_server']['remote_proc_trans']        = "#{db_params['remote_proc_trans']['value']}"
end
if db_params['remote_proc_trans'].nil?
  node.set['sql_server']['remote_proc_trans']        = nil
end
unless db_params['remote_query_timeout_(s)'].nil?
  node.set['sql_server']['remote_query_timeout_(s)']        = "#{db_params['remote_query_timeout_(s)']['value']}"
end
if db_params['remote_query_timeout_(s)'].nil?
  node.set['sql_server']['remote_query_timeout_(s)']        = nil
end
unless db_params['replication_xps'].nil?
  node.set['sql_server']['replication_xps']        = "#{db_params['replication_xps']['value']}"
end
if db_params['replication_xps'].nil?
  node.set['sql_server']['replication_xps']        = nil
end
unless db_params['scan_for_startup_procs'].nil?
  node.set['sql_server']['scan_for_startup_procs']        = "#{db_params['scan_for_startup_procs']['value']}"
end
if db_params['scan_for_startup_procs'].nil?
  node.set['sql_server']['scan_for_startup_procs']        = nil
end
unless db_params['server_trigger_recursion'].nil?
  node.set['sql_server']['server_trigger_recursion']        = "#{db_params['server_trigger_recursion']['value']}"
end
if db_params['server_trigger_recursion'].nil?
  node.set['sql_server']['server_trigger_recursion']        = nil
end
unless db_params['set_working_set_size'].nil?
  node.set['sql_server']['set_working_set_size']        = "#{db_params['set_working_set_size']['value']}"
end
if db_params['set_working_set_size'].nil?
  node.set['sql_server']['set_working_set_size']        = nil
end
unless db_params['show_advanced_options'].nil?
  node.set['sql_server']['show_advanced_options']        = "#{db_params['show_advanced_options']['value']}"
end
if db_params['show_advanced_options'].nil?
  node.set['sql_server']['show_advanced_options']        = nil
end
unless db_params['smo_and_dmo_xps'].nil?
  node.set['sql_server']['smo_and_dmo_xps']        = "#{db_params['smo_and_dmo_xps']['value']}"
end
if db_params['smo_and_dmo_xps'].nil?
  node.set['sql_server']['smo_and_dmo_xps']        = nil
end
unless db_params['sql_mail_xps'].nil?
  node.set['sql_server']['sql_mail_xps']        = "#{db_params['sql_mail_xps']['value']}"
end
if db_params['sql_mail_xps'].nil?
  node.set['sql_server']['sql_mail_xps']        = nil
end
unless db_params['transform_noise_words'].nil?
  node.set['sql_server']['transform_noise_words']        = "#{db_params['transform_noise_words']['value']}"
end
if db_params['transform_noise_words'].nil?
  node.set['sql_server']['transform_noise_words']        = nil
end
unless db_params['two_digit_year_cutoff'].nil?
  node.set['sql_server']['two_digit_year_cutoff']        = "#{db_params['two_digit_year_cutoff']['value']}"
end
if db_params['two_digit_year_cutoff'].nil?
  node.set['sql_server']['two_digit_year_cutoff']        = nil
end
unless db_params['user_connections'].nil?
  node.set['sql_server']['user_connections']        = "#{db_params['user_connections']['value']}"
end
if db_params['user_connections'].nil?
  node.set['sql_server']['user_connections']        = nil
end
unless db_params['user_options'].nil?
  node.set['sql_server']['user_options']        = "#{db_params['user_options']['value']}"
end
if db_params['user_options'].nil?
  node.set['sql_server']['user_options']        = nil
end
unless db_params['xp_cmdshell'].nil?
  node.set['sql_server']['xp_cmdshell']        = "#{db_params['xp_cmdshell']['value']}"
end
if db_params['xp_cmdshell'].nil?
  node.set['sql_server']['xp_cmdshell']        = nil
end
unless db_params[''].nil?
  node.set['sql_server']['']        = "#{db_params['']['value']}"
end
if db_params[''].nil?
  node.set['sql_server']['']        = nil
end

