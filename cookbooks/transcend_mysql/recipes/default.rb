#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2008-2009, MomentumSoftware, Inc.
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

data_bag_name = node[:__TRANSCEND__DATABAG__]
Chef::Log.info("Data bag name: " + data_bag_name)
data_bag = data_bag(data_bag_name)
Chef::Log.info("Data bag content: " + data_bag.to_s)

Chef::Log.info("Retrieving DBSnapshot data bag item...")
begin
  flagSnapshot = data_bag_item(data_bag_name, "DBSnapshot").to_hash['DBSnapshotIdentifier']
rescue Exception=>e
  Chef::Log.info("DBSnapshot item does not exist... Proceeding with next operation.")
end

Chef::Log.info("Retrieving Reboot data bag item...")
begin
  flagReboot = data_bag_item(data_bag_name, "Reboot").to_hash['Reboot']
rescue Exception=>e
  Chef::Log.info("Reboot item does not exist... Proceeding with next operation.")
end

Chef::Log.info("Retrieving RestoreDBInstance data bag item...")
begin
  flagRestore = data_bag_item(data_bag_name, "RestoreDBInstance").to_hash['DBSnapshotIdentifier']
rescue Exception=>e
  Chef::Log.info("RestoreDBInstance item does not exist... Proceeding with next operation.")
end

Chef::Log.info("Retrieving Replication data bag item...")
begin
  flagReplication = data_bag_item(data_bag_name, "Replication").to_hash['Task']
rescue Exception=>e
  Chef::Log.info("Replication item does not exist... Proceeding with next operation.")
end


if(!(flagReboot.nil?))
	Chef::Log.info("Reboot recipe is chosen!")
    include_recipe "transcend_mysql::reboot"
elsif(flagSnapshot.nil?)
  if(flagRestore.nil?)
    if(flagReplication.nil?)
	  Chef::Log.info("MySQL installation recipe is chosen!")
      include_recipe "transcend_mysql::server"
    else
	  Chef::Log.info("MySQL replication recipe is chosen!")
      include_recipe "transcend_mysql::replication"
	end    
  else
    Chef::Log.info("Restoration recipe is chosen!")
    include_recipe "transcend_mysql::restore"
  end
else
  Chef::Log.info("Backup/snapshot recipe is chosen!")
  include_recipe "transcend_mysql::backup"
end

