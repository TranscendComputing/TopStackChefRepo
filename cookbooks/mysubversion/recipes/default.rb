#
# Cookbook Name:: mysubversion
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
include_recipe "rvm::system"
include_recipe "mysql::server"

execute "checkout" do
   command "svn co http://172.16.5.16/svn/Tough/trunk/ToughUI/trunk/ /home/ToughUI --username cstewart --password stewie2006 --non-interactive"
   action :run
end

file "/home/ToughUI/public/bin/config/config.xml" do
   action :delete
   backup false
end

template "config.xml" do
   path "/home/ToughUI/public/bin/config/config.xml"
   source "config.xml.erb"
   owner "root"
   group "root"
   mode 0644
end

execute "install_gems" do
    command "bundle install --gemfile=#{node[:mysubversion][:uidir]}/Gemfile"
    action :run
end
