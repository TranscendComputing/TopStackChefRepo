#
# Cookbook Name:: transcend_topstack_host
# Recipe:: install
#
# Copyright 2008-2013, Momentum Software, Inc.
#
# All rights reserved.

# Mixlib::ShellOut stuff inspired by
# https://github.com/opscode-cookbooks/pxe_dust/blob/master/recipes/bootstrap_template.rb#L33
# Thanks to Matt Ray <matt@opscode.com>, in Message-ID:
# <e85b33cc5b72421ab3ba9c0f325fe84f@CO1PR06MB078.namprd06.prod.outlook.com>
# Also thanks to Daniel DeLeo <dan@kallistec.com>, in Message-ID:
# <1B6978F6C8E4445B940B89690BA45A57@kallistec.com>

require 'mixlib/shellout'
require 'chef/data_bag'

# ---------------------------- Get the data bag item(s) needed ------------------------------------
Chef::Log.info("Variables for RDS config platform: #{node[:platform]}")
data_bag_name = node[:__TRANSCEND__DATABAG__]

if data_bag_name =~ /ecache/
    pkg="memcached"
elsif data_bag_name =~ /rds/
    pkg="mysql-server"
else
    Chef::Log.fatal("data bag name '#{data_bag_name}' is not a known type" )
end

Chef::Log.info("Found configuration: #{data_bag_name}" )

config = data_bag_item(data_bag_name, "config")
if config.nil?
    Chef::Log.fatal("failed to get databag item: config")
else
    Chef::Log.debug(config.to_s)
end

if data_bag_name =~ /rds/
    req_params = config['request_parameters']
    if req_params.nil?
	Chef::Log.fatal("failed to get req_params")
    else
	Chef::Log.debug(req_params.to_s)
    end
end

# -------------------------------------------------------------------------------------------------

version_data_bag_name = "versions"

if (!Chef::DataBag.list.key?(version_data_bag_name))
    Chef::Log.fatal("data bag #{version_data_bag_name} is empty or non-existant" )
else
    Chef::Log.info("Opening data bag configuration: #{version_data_bag_name}" )
end

execute "update apt repo cache data" do
    command "apt-get update"
end

execute "#{pkg} print" do
    command "echo '\n\npackage #{pkg}\n\n'"
end

svr = data_bag_item(version_data_bag_name, pkg)

case pkg
when "memcached"
    engVers = begin
	config['ecacheVrs']
    rescue Exception
	Chef::Log.debug("Exception while checking ecacheVrs, assuming it is nil")
	awk = "echo #{svr['versions']} | awk '{ print $NF }'"
	Chef::Log.debug awk
	cmd = Mixlib::ShellOut.new(awk)
	output = cmd.run_command
	engVers = output.stdout.chomp
	Chef::Log.debug engVers
    end
when "mysql-server"
    engVers = req_params['engVrs']
end

Chef::Log.debug("Desired '#{pkg}' version = '#{engVers}'")

aptitude = "aptitude show #{pkg}=#{engVers} | grep '^Version: ' | sed 's/^Version: //' | grep \"^#{engVers}\""
Chef::Log.debug aptitude
cmd = Mixlib::ShellOut.new(aptitude)
output = cmd.run_command
engAvail = output.stdout.chomp
Chef::Log.debug("engAvail = '#{engAvail}'")

package "#{pkg}" do
    if(!engAvail.nil?)
	version engAvail
    else
	version engVers
    end
    action :install
    not_if { File.exists? "/rdsdbdata/first_run" }
end
