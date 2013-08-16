#
# Cookbook Name:: uiserver
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

#include_recipe "passenger_apache2"

web_app "ToughUI" do
  docroot "/home/ToughUI/public"
  directory "/home/ToughUI/public/bin"
  server_name "#{node[:cloud][:public_hostname]}"
  server_aliases [ "ToughUI", "#{node[:cloud][:public_hostname]}" ]
  rails_env "development"
end
