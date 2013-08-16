#
# Cookbook Name:: transcend_slb
# Recipe:: config
#
# Copyright 2012, Transcend Computing, Inc.
#
# Licence Info: TBD
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

data_bag_name = node["clouds_databag"]
Chef::Log.info("Found configuration: #{data_bag_name}")

config = data_bag_item(data_bag_name,"config")
Chef::Log.info(config)

service "tomcat7" do
          supports :restart => true
          action [:enable, :start]
end

clouds=config['config']
publicip=""
elbdomain=""
hostname=""
clouds.each do |cloud|
        publicip=cloud['publicip']
        elbdomain=cloud['elbdomain']
        hostname=cloud['hostname']
end

template "/var/lib/topstack/bin/setenv.sh" do
	source "setenv.sh.erb"
	mode 0664
	variables({:bagname => data_bag_name, :config => config, :elbdomain=>elbdomain, :publicip=>publicip,:hostname=>hostname})
	notifies :restart, "service[tomcat7]" 
end

template "/var/lib/topstack/config/cloud-config.xml" do
	source "commonParameters-config.xml.erb"
	mode 0664
	variables({:bagname => data_bag_name, :config => config})
	notifies :restart, "service[tomcat7]" 
end

