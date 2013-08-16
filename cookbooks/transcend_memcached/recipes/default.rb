#
#
# Cookbook Name:: memcached
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
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


package "memcached" do
  action :install
end

#package "libmemcache-dev" do  
#	case node[:platform]  
#	when "redhat","centos","fedora"    
#		package_name "libmemcache-devel"  
#	else    
#		package_name "libmemcache-dev"  
#	end  
#	action :upgradeend
#end

service "memcached" do
  action :enable
  supports :status => true, :start => true, :stop => true, :restart => true
end


Chef::Log.info("Variables for Memcached config platform: #{node[:platform]}")
data_bag_name = node[:__TRANSCEND__DATABAG__]
Chef::Log.info("Found configuration: #{data_bag_name}" )
config = data_bag_item(data_bag_name, "config")
revision = "0"
if config.nil? 
    Chef::Log.info("failed to get databag item: config")
else
    Chef::Log.info(config.to_s)
    if !config['revision'].nil?
		revision = config['revision']
	end
end
if (revision=="")
	revision="0"
end

# The actual template output is specified below in the case
template "memcached" do

  options = ""
	
  Chef::Log.info("listen: #{config['listen']}" )
  Chef::Log.info("user: #{config['user']}" )
  Chef::Log.info("port: #{config['port']}" )
  Chef::Log.info("memory: #{config['memory']}" ) 
  Chef::Log.info("maxconn: #{config['maxconn']}" )

  parameters = data_bag_item(data_bag_name, "parameters")
  if parameters.nil?
   Chef::Log.info("failed to get databag item: parameters")
  else
   Chef::Log.info(parameters.to_s)
  end
  parameterSet = parameters["Parameters"]

  max_simultaneous_connections = parameterSet["max_simultaneous_connections"]["value"]
  Chef::Log.info("max_simultaneous_connections: #{max_simultaneous_connections}")

  num_threads = parameterSet["num_threads"]["value"]
  options = options + "-t #{num_threads}"

  cas_disabled = parameterSet["cas_disabled"]["value"]
  Chef::Log.info("cas_disabled: #{cas_disabled}")
  if cas_disabled
   options = options + " -C" 
  end   

  lock_down_paged_memory = parameterSet["lock_down_paged_memory"]["value"]
  Chef::Log.info("lock_down_paged_memory: #{lock_down_paged_memory}")
  if lock_down_paged_memory
   options = options + " -k"
  end

  if parameterSet["chunk_size_growth_factor"]
    chunk_size_growth_factor = parameterSet["chunk_size_growth_factor"]["value"]
  else 
    chunk_size_growth_factor = "1.25"
  end
    options = options + " -f #{chunk_size_growth_factor}"

  if parameterSet["binding_protocol"]
    binding_protocol = parameterSet["binding_protocol"]["value"]
    options = options + " -B #{binding_protocol}"
  end

  error_on_memory_exhausted = parameterSet["error_on_memory_exhausted"]["value"]
  Chef::Log.info("error_on_memory_exhausted: #{error_on_memory_exhausted}")
  if error_on_memory_exhausted
   options = options + " -M"
  end

  maximize_core_file_limit = parameterSet["maximize_core_file_limit"]["value"]
  Chef::Log.info("maximize_core_file_limit: #{maximize_core_file_limit}")
  if maximize_core_file_limit
   options = options + " -r"
  end

  large_memory_pages = parameterSet["large_memory_pages"]["value"]
  Chef::Log.info("large_memory_pages: #{large_memory_pages}")
  if large_memory_pages
   options = options + " -L"
  end

  requests_per_event = parameterSet["requests_per_event"]["value"]
  options = options + " -R #{requests_per_event}"

  backlog_queue_limit = parameterSet["backlog_queue_limit"]["value"]
  options = options + " -b #{backlog_queue_limit}"

  max_item_size = parameterSet["max_item_size"]["value"]
  options = options + " -I #{max_item_size}"

  chunk_size = parameterSet["chunk_size"]["value"]
  options = options + " -n #{chunk_size}"

  Chef::Log.info( "Options #{options}" )

  case node[:platform]
  when "redhat", "centos","scientific", "fedora", "arch"
	path "/etc/sysconfig/memcached"
	source "memcached.etc.sysconfig.erb"
  when "debian", "ubuntu"
	path "/etc/memcached.conf"
	source "memcached.conf.erb"
  end
  
  port = config['port']
  if port.nil? || port==0
  	port=11211
  end

#  source "memcached.etc.sysconfig.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
  	:revision => revision,
    :max_simultaneous_connections => max_simultaneous_connections,
    :user => config['user'],
    :port => port,
    :memory => config['memory'],
    :listen => config['listen'],
    :options => options,
    :num_threads => num_threads,
    :cas_disabled => cas_disabled,
    :lock_down_paged_memory => lock_down_paged_memory,
    :chunk_size_growth_factor => chunk_size_growth_factor,
    :binding_protocol => binding_protocol,
    :error_on_memory_exhausted => error_on_memory_exhausted,
    :maximize_core_file_limit => maximize_core_file_limit,
    :large_memory_pages => large_memory_pages,
    :requests_per_event => requests_per_event,
    :backlog_queue_limit => backlog_queue_limit,
    :max_item_size => max_item_size,
    :chunk_size => chunk_size
  )
  notifies :restart, resources(:service => "memcached"), :immediately
end

case node[:platform]
when "karmic" # , "centos"
  template "/etc/default/memcached" do
    source "memcached.default.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "memcached"), :immediately
  end
end

if config['serviceurl'].nil?
	Chef::Log.info("No PostWait call required")
else
	oldRevision=""
	if (File.exist?('/var/lock/PostWaitCalled') and File.file?('/var/lock/PostWaitCalled') )
		File.open('/var/lock/PostWaitCalled', 'r') do |f1|  
		  line = f1.gets  
		  oldRevision=line.chomp
		end
	end
	Chef::Log.info("OldRevision #{oldRevision} revision #{revision}")
	if("#{oldRevision}" != "#{revision}" )
	 	hostname=""
		File.open('/etc/hostname', 'r') do |f1|  
		  while line = f1.gets  
			if(hostname=="")
				hostname=line.chomp
			end
		  end  
		end
		File.open("/var/lock/PostWaitCalled", 'w') {|f| f.write("#{revision}") }
		Chef::Log.info("PostWait #{config['serviceurl']}?Action=PostWait&PhysicalId=#{hostname}&Status=success")
        http_request "postwait" do
          action :post
          url "#{config['serviceurl']}?Action=PostWait&Hostname=#{hostname}&StackId=#{config['StackId']}&AcId=#{config['AcId']}&Status=success"
        end
   end
end

