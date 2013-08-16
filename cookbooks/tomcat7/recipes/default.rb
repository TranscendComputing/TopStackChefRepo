#
# Cookbook Name:: tomcat7
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
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

#install and configure tomcat
Chef::Log.info("Variables for ElasticBeanStalk Tomcat 6 config platform: #{node[:platform]}")
data_bag_name = node[:__TRANSCEND__DATABAG__]
Chef::Log.info("Found configuration: #{data_bag_name}")

configs = data_bag_item(data_bag_name, "configs")
if configs.nil?
 Chef::Log.info("failed to get the attribute: configs")
else
 Chef::Log.info(configs.to_s)
end

optionSettings = configs['OptionSettings']
if optionSettings.nil?
 Chef::Log.info("failed to get databag item: OptionSettings")
else
 Chef::Log.info(optionSettings.to_s)
end

case node.platform
when "centos","redhat","fedora"
  include_recipe "jpackage"
end

tomcat_pkgs = value_for_platform(
  ["debian","ubuntu"] => {
    "default" => ["tomcat7","tomcat7-admin"]
  },
  ["centos","redhat","fedora"] => {
    "default" => ["tomcat7","tomcat7-admin-webapps"]
  },
  "default" => ["tomcat7"]
)
tomcat_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

service "tomcat" do
  service_name "tomcat7"
  case node["platform"]
  when "centos","redhat","fedora"
    supports :restart => true, :status => true
  when "debian","ubuntu"
    supports :restart => true, :reload => true, :status => true
  end
  action [:enable, :start]
end

case node["platform"]
when "centos","redhat","fedora"
  template "/etc/sysconfig/tomcat7" do
    source "sysconfig_tomcat7.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "tomcat"), :immediately
  end
else  
  template "/etc/default/tomcat7" do
	jvm_options = optionSettings['JVM Options']['Value']
	maxPermSize = optionSettings['XX:MaxPermSize']['Value']
	xmx = optionSettings['Xmx']['Value']
	xms = optionSettings['Xms']['Value']
	Chef::Log.info("JVM Options: #{jvm_options}")
	Chef::Log.info("MaxPermSize: #{maxPermSize}")
	Chef::Log.info("Xmx: #{xmx}")
	Chef::Log.info("Xms: #{xms}")
 	variables(
      :jvm_options => jvm_options,
	  :maxPermSize => maxPermSize,
	  :xmx => xmx,
	  :xms => xms
  	)
    source "default_tomcat7.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "tomcat"), :immediately
  end
end

template "/etc/tomcat7server.xml" do
  source "server.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "tomcat"), :immediately
end

#get s3-curl and use it to curl the application war file
remote_file "/tmp/s3-curl.zip" do
  source "http://s3.amazonaws.com/doc/s3-example-code/s3-curl.zip"
  mode "0644"
end

package "unzip" do
  :install
end

bash "unzip s3-curl" do
  user "root"
  cwd "/tmp"
  code %(unzip s3-curl.zip -d /tmp)
  not_if { File.exists? "/tmp/s3-curl" }
end

case node["platform"]
when "centos","redhat","fedora"
  package "perl-Digest-HMAC" do
	:install
  end
else
  package "libdigest-hmac-perl" do
	:install
  end
end

s3data = configs['SourceBundle']
if s3data.nil?
 Chef::Log.info("failed to get databag item and/or attribute: SourceBundle")
else
 Chef::Log.info(s3data.to_s)
end

template "/root/.s3curl" do
  variables(:userName => s3data["user"], :id => s3data["id"], :key => s3data["key"])
  source "s3curl.erb"
  owner "root"
  group "root"
  mode "0600"
end

bash "activate_s3curl" do
  user "root"
  cwd "/tmp/s3-curl"
  code %(chmod 744 s3curl.pl)
end

s3key = s3data["S3Key"]

bash "get_web_app" do
  s3bucket = s3data["S3Bucket"]
  s3user = s3data["user"]
  user "root"
  cwd "/tmp/s3-curl"
  code %(perl s3curl.pl --id #{s3user} -- --GET -- http://172.16.5.215:3333/#{s3bucket}/#{s3key} >> /tmp/#{s3key})
end

bash "deploy" do
  user "root"
  cwd "/tmp"
  code %(mv #{s3key} #{node["tomcat"]["webapp_dir"]})
  notifies :restart, resources(:service => "tomcat"), :immediately
end
