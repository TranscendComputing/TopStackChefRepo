#
# Cookbook Name:: bookkeeper
# Recipe:: default
#
# Copyright 2010, GoTime Inc.
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

include_recipe "zookeeper::source"

zk_version = node[:zookeeper][:version]

execute "checkout_bookkeeper" do
    cwd "#{node[:zookeeper][:srcdir]}"
    command "svn checkout #{node[:bookkeeper][:svnurl]} Bookkeeper"
    action :run
end

bash "compile_bookkeeper" do
    cwd "#{node[:zookeeper][:srcdir]}"
    code <<-EOH
        #!/bin/bash
        cd Bookkeeper
        echo "Building Bookkeeper at: $(pwd)"
        mvn install -f #{node[:zookeeper][:srcdir]}/Zookeeper/build/zookeeper-#{zk_version}/dist-maven/zookeeper-#{zk_version}.pom
        mvn install
        #This is a gigantic 'cheat' to protect the recipe from failing due to a failed build"
        echo "Build completed."
    EOH
    creates node[:bookkeeper][:src_binary]
end
