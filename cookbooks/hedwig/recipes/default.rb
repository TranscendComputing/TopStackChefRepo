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

#get the tar.gz file of built hub
remote_file "/tmp/bookkeeper-3.4.0.tgz" do
  source "http://msiiscsi.momentumsoftware.com/hedwig/Bookkeeper_ub.tgz"	#the source is local yum repos at this point; this should be changed
  mode "0644"
  not_if { File.exists? "/tmp/bookkeeper-3.4.0.tgz" }
end

#create a new user for hedwig
user "hedwig" do
  uid 61003
  gid "nogroup"
end

#a new directory to install the bookkie
directory "/var/lib/bookkeeper-3.4.0" do
  owner "hedwig"
  group "nogroup"
  mode 0755
end

#untar
bash "untar hedwig_components" do
  user "root"
  cwd "/tmp"
  code %(tar xf /tmp/bookkeeper-3.4.0.tgz)
  not_if { File.exists? "/tmp/Bookkeeper" }
end

#copy the files into the directory created earlier
bash "copy bk root" do
  user "root"
  cwd "/tmp"
  code %(cp -r /tmp/Bookkeeper/hedwig-server /var/lib/bookkeeper-3.4.0)
  not_if { File.exists? "/var/lib/bookkeeper-3.4.0/hedwig-server" }
end

#hw_server.conf from template 
template "/var/lib/bookkeeper-3.4.0/hedwig-server/conf/hw_server.conf" do
  source "hw_server.conf.erb"
  mode 0644
end

#copy the hwenv.sh from the cookbook files into the configuration directory of the hub
cookbook_file "/var/lib/bookkeeper-3.4.0/hedwig-server/conf/hwenv.sh" do
  source "hwenv.sh"
  mode 0644
 owner "hedwig"
  group "nogroup"
end

#copy the minimal log4j.properties from the cookbook files into the configuration directory of the hub
cookbook_file "/var/lib/bookkeeper-3.4.0/hedwig-server/conf/log4j.properties" do
  source "log4j.properties"
  mode 0644
 owner "hedwig"
  group "nogroup"
end

#run the service
bash "run hub" do
  user "root"
  cwd "/var/lib/bookkeeper-3.4.0/hedwig-server/bin"
  code %(bash ./hedwig server > /var/lib/bookkeeper-3.4.0/hediwg-server/hub.log 2>&1 &)
end
