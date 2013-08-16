#
# Cookbook Name:: myapache
# Recipe:: default
#
# Copyright 2011, momentumsi com
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
include_recipe "passenger_apache2"

file "#{node[:apache][:dir]}/conf/http.conf" do
  action :delete
  backup false
end
 
template "httpd.conf" do
  case node[:platform]
  when "centos"
    path "#{node[:apache][:dir]}/conf/httpd.conf"
  end
  source "httpd.conf.erb"
  owner node[:apache][:user]
  group node[:apache][:group]
  mode 0644
  notifies :restart, resources(:service => "apache2")
end


=begin
template "#{node[:apache][:dir]}/sites-available/default" do
  source "default-site.erb"
  owner node[:apache][:user]
  group node[:apache][:group]
  mode 0644
  notifies :restart, resources(:service => "apache2")
end
=end
