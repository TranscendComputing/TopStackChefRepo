#
# Cookbook Name:: ruby192
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

execute "remove_ruby" do
  command "yum erase -y ruby ruby-libs ruby-mode ruby-rdoc ruby-irb ruby-ri ruby-docs"
  action :run
end

execute "install_dev_tools" do
  command "yum groupinstall -y 'Development Tools'"
  action :run
end

execute "install_tools" do
  command "yum install -y git curl-devel openssl-devel httpd-devel apr-devel apr-util-devel libzlib-ruby zlib-devel"
  action :run
end

execute "curl_rvm" do
  execute "curl -sk -L https://rvm.beginrescueend.com/install/rvm | bash"
  action :run
end

execute "edit_bash_profile" do
    string1 "/usr/local/rvm/scripts/rvm"
    command "echo '[[ -s string1 ]] && . string1 # Load RVM function' >> /etc/skel/.bash_profile"
    action :run
end

execute "source_bash" do
   command ". /etc/skel/.bash_profile"
   action :run
end

execute "install_ruby" do
   command "rvm install ruby-1.9.2-p290"
   action :run
end
