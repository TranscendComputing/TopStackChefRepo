#
# Cookbook Name:: bookkeeper
# Recipe:: default
#
# Copyright 2011, MomentumSI, Inc.
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
include_recipe "java"

#get the tar.gz file of built bookkeeper
remote_file "/tmp/bookkeeper-3.4.0.tgz" do
  source "http://msiiscsi.momentumsoftware.com/hedwig/Bookkeeper_ub.tgz"	#the source is local yum repos at this point; this should be changed
  mode "0644"
  not_if { File.exists? "/tmp/bookkeeper-3.4.0.tgz" }
end

#create a new user for bookkeeper
user "bookkeeper" do
  uid 61002
  gid "nogroup"
end

#a new directory to install the bookkie
directory "/var/lib/bookkeeper-3.4.0" do
  owner "bookkeeper"
  group "nogroup"
  mode 0755
end

#untar
bash "untar bookkeeper" do
  user "root"
  cwd "/tmp"
  code %(tar xf /tmp/bookkeeper-3.4.0.tgz)
  not_if { File.exists? "/tmp/Bookkeeper" }
end

#copy the files into the directory created earlier
bash "copy bk root" do
  user "root"
  cwd "/tmp"
  code %(cp -r /tmp/Bookkeeper/bookkeeper-server /var/lib/bookkeeper-3.4.0)
  not_if { File.exists? "/var/lib/bookkeeper-3.4.0/bookkeeper-server" }
end

#new directories to put data and log
directory "/var/lib/bookkeeper-3.4.0/bookkeeper-server/data" do		#<= this function to create data/ directory is required by the next two functions; fix needed
  owner "bookkeeper"
  group "nogroup"
  mode 0755
end

directory node[:bookkeeper][:data_dir] do
  owner "bookkeeper"
  group "nogroup"
  mode 0755
end

directory node[:bookkeeper][:log_dir] do
  owner "bookkeeper"
  group "nogroup"
  mode 0755
end

#bkenv.sh from template 
template "/var/lib/bookkeeper-3.4.0/bookkeeper-server/conf/bkenv.sh" do
  source "bkenv.sh.erb"
  mode 0644
end

#copy the minimal log4j.properties from the cookbook files into the configuration directory of the bookie
cookbook_file "/var/lib/bookkeeper-3.4.0/bookkeeper-server/conf/log4j.properties" do
  source "log4j.properties"
  mode 0644
  owner "bookkeeper"
  group "nogroup"
end


cookbook_file "/var/lib/bookkeeper-3.4.0/bookkeeper-server/bin/bookie" do
  source "bookie"
  mode 0755
  owner "bookkeeper"
  group "nogroup"
end

#run the service
bash "run bookie" do
  user "root"
  cwd "/var/lib/bookkeeper-3.4.0/bookkeeper-server/bin"
  code %(bash ./bookkeeper bookie > /var/lib/bookkeeper-3.4.0/bookkeeper-server/bookie.log 2>&1 &)
end
