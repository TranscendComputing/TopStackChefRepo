#
# Cookbook Name:: transcend_topstack_host
# Recipe:: available
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
data_bag_name = "versions"
Chef::Log.info("data bag configuration: #{data_bag_name}" )

# check if the bag exists so the recipe doesn't puke
if (!Chef::DataBag.list.key?(data_bag_name))
    Chef::Log.info("#{data_bag_name} data bag is empty, recreating")
    # make it since it's not there
    db = Chef::DataBag.new
    db.name(data_bag_name)
    db.save
else
    Chef::Log.info("Opening #{data_bag_name} data bag")
end

execute "update apt repo cache data" do
    command "apt-get update"
end

%w{ mysql-server memcached }.each do |pkg|

    aptitude = "aptitude show #{pkg} -v | grep '^Version: ' | sed -e 's/^Version: //' -e 's/-.*$//' | sort -u | xargs"
    Chef::Log.debug aptitude
    cmd = Mixlib::ShellOut.new(aptitude)
    output = cmd.run_command
    svr_avail = output.stdout.chomp
    Chef::Log.debug svr_avail

    Chef::Log.info("Checking #{data_bag_name} item #{pkg}")
    svr = begin
	data_bag_item(data_bag_name, pkg)
	Chef::Log.debug "Storing svr[#{pkg}] = #{svr_avail}"
	svr["#{pkg}"] = "#{svr_avail}"
	svr.save
    rescue Exception
	Chef::Log.debug("Exception while checking #{data_bag_name} item #{pkg}, assuming it is nil")
	svr_json = {
	    "id" => "#{pkg}",
	    "versions" => "#{svr_avail}"
	}
	Chef::Log.debug "Storing svr_json #{svr_json.inspect}"
	databag_item = Chef::DataBagItem.new
	databag_item.data_bag(data_bag_name)
	databag_item.raw_data = svr_json
	databag_item.save
    end

end
