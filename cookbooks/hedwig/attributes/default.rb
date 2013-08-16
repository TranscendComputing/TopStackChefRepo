#
# Author:: Daniel Kim (<dkim@momentumsi.com>)
# Cookbook Name:: Hedwig
# Attributes:: default
#
# Copyright 2010, MomentumSI, Inc.
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

set_unless[:hedwig][:zk_host] = "localhost:2181"
set_unless[:hedwig][:zk_timeout] = 2000
set_unless[:hedwig][:server_port] = 4080
set_unless[:hedwig][:ssl_server_port] = 9876
set_unless[:hedwig][:ssl_enabled] = "false"
