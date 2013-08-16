#
# Cookbook Name:: zookeeper
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

include_recipe "java"
include_recipe "build-essential"
include_recipe "subversion::client"
include_recipe "maven"
include_recipe "ant"

unless platform?("centos","redhat","fedora")
  include_recipe "runit"
end

packages = value_for_platform(
    ["centos","redhat","fedora"] => {'default' => ['autoconf', 'libtool', 'cppunit-devel']},
    "default" => ['autoconf', 'libtool', 'libcppunit-dev']
)

packages.each do |devpkg|
    package devpkg
end

execute "checkout_zookeeper" do
    cwd "#{node[:zookeeper][:srcdir]}"
    command "svn checkout #{node[:zookeeper][:svnurl]} Zookeeper"
    action :run
end

bash "compile_zookeeper" do
    #cwd Chef::Config[:file_cache_path]
    cwd "#{node[:zookeeper][:srcdir]}"
    code <<-EOH
        cd Zookeeper
        ant
        ant package
    EOH
    creates node[:zookeeper][:src_binary]
end
