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

pkgs = value_for_platform(
	["debian","ubuntu",] => {
		"default" => ["libmysqlclient-dev"]
	},
	["centos","redhat","fedora" ] => {
		"default" => ["libmysqlclient-dev"]
	},
	"default" => ["libmysqlclient-dev"]
)

pkgs.each do |pkg|
	package pkg do
		action :install
	end
end

extra_gems = %w{mysql}
extra_gems.each do |pkg|
    gem_package pkg do
        action :install
    end
end

data_bag_name = node["users_databag"]
Chef::Log.info("Found configuration bag: #{data_bag_name}")
config = data_bag_item(data_bag_name,"config")
Chef::Log.info(config)
users=config['config']
Chef::Log.info(users)

cloud_bag = node["clouds_databag"]
Chef::Log.info("Found configuration: #{cloud_bag}")
cloud_config = data_bag_item(cloud_bag,"config")
Chef::Log.info(cloud_config)
clouds=cloud_config['config']
Chef::Log.info("clouds: #{clouds}")

users.each do |user|
	Chef::Log.info("user: #{user}")
	Chef::Log.info("config: #{user['username']}")
	Chef::Log.info("config: #{user['access_key']}")
	Chef::Log.info("config: #{user['secret_key']}")
	Chef::Log.info("config: #{user['front_azone']}")
	Chef::Log.info("config: #{user['email']}")
	favz = user['front_azone']
	clouds.each do |cloud|
		if cloud['cloud']==favz
			user['ec2_url'] = cloud['ec2_url']
			user['back_azone'] = cloud['azone']
			user['defzone'] = favz
			user['defkeyname'] = user['username']
			user['defsecgrp'] = 'default'
		end
	end
	Chef::Log.info("config: #{user['defsecgrp']}")
	Chef::Log.info("config: #{user['defkeyname']}")
	Chef::Log.info("config: #{user['back_azone']}")
	Chef::Log.info("config: #{user['defzone']}")
	Chef::Log.info("config: #{user['ec2_url']}")
	execute "create-keypair" do
  		command "/var/lib/topstack/bin/create-keypair.sh #{user['access_key']} #{user['secret_key']} #{user['ec2_url']} #{user['username']}"
  		creates "/var/lib/topstack/keys/#{user['username']}.pem"
  		action :run
	end	
end

ruby_block "modify_topstack_users" do
	block do
		require 'rubygems'
		Gem.clear_paths
		require 'mysql'
		
		#puts node.inspect
		begin
		m = Mysql.new(node[:topstackdb][:host], node[:topstackdb][:user], node[:topstackdb][:password], node[:topstackdb][:name])
		users.each do |user|
			sql = "select * from account where access_key = '#{user['access_key']}'"
			Chef::Log.info(sql)
			rs = m.query(sql)
			cnt=0
			rs.each do |row|
				cnt = 1
				sql = "update account set access_key='#{user['access_key']}', secret_key='#{user['secret_key']}', def_security_groups='#{user['defsecgrp']}', def_key_name='#{user['defkeyname']}', emails='#{user['email']}', def_zone='#{user['defzone']}' where access_key='#{user['access_key']}'"
				Chef::Log.info(sql)
				m.query(sql)
   			end
			if cnt == 0
				sql = "insert into account (name, access_key, secret_key, def_security_groups, def_key_name, emails,def_zone) values ('#{user['username']}','#{user['access_key']}', '#{user['secret_key']}', '#{user['defsecgrp']}', '#{user['defkeyname']}', '#{user['email']}', '#{user['defzone']}')"
				Chef::Log.info(sql)
				m.query(sql)
			end
		end
		rescue Mysql::Error => error
			Chef::Log.error(error.to_s)
		end	
	end
end

