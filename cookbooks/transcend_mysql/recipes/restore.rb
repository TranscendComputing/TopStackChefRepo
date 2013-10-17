Chef::Log.info("Restoration process will start for RestoreDBInstanceFromDBSnapshot...")
# if this is the first run, include MySQL installation recipe; normally this wouldn't be called since CreateDBInstance is called first to prepare the DBInstance
if(node[:mysql][:root_user].nil?)
  include_recipe "transcend_mysql::server"
end

# Assumption: Volume is already attached by the servlet before calling chef-client

# get the parameters from the data bag and from the node
Chef::Log.info("Variables for RDS config platform: #{node[:platform]}")
data_bag_name = node[:__TRANSCEND__DATABAG__]
Chef::Log.info("Found configuration: #{data_bag_name}" )
restore = data_bag_item(data_bag_name, "RestoreDBInstance")

config = data_bag_item(data_bag_name, "config")
if config.nil?
 Chef::Log.info("failed to get databag item: config")
else
 Chef::Log.info(config.to_s)
end
req_params = config['request_parameters']
if req_params.nil?
 Chef::Log.info("failed to get req_params")
else
 Chef::Log.info(req_params.to_s)
end

dbSnapshotId = restore['DBSnapshotIdentifier']
datadir = node[:mysql][:data_dir]

# find the next available device
disk = "/dev/"
disk0 = ""

if node[:virtualization][:system]? nil
  devid = Dir.glob('/dev/vd?').sort.last[-1,1].succ
  disk0 = "vd" + devid
end

if node[:virtualization][:system].eql? "kvm"
  devid = Dir.glob('/dev/vd?').sort.last[-1,1].succ
  disk0 = "vd" + devid
end

# now look for the device in XEN model if nothing if found previously
if node[:virtualization][:system].eql? "xen"
  devid = Dir.glob('/dev/xvd?').sort.last[-1,1].succ
  disk0 = "xvd" + devid
end
if node[:virtualization][:system].eql? "lxc"
  # TODO
end

disk = disk + disk0
diskEnc = "%2Fdev%2F" + disk0
Chef::Log.info("Virtual disk name is " + disk)

# Call RDSQuery server to attach the volume to the next device available
http_request "Signal #{req_params['ServletUrl']} to attach the volume" do
  action :post
  url "#{req_params['ServletUrl']}?Action=AttachDBSnapshot&AcId=#{req_params['AcId']}&StackId=#{req_params['StackId']}&Device=#{diskEnc}&Snapshot=#{dbSnapshotId}"
end


pid_file = ""
Dir.foreach("#{datadir}") do |f2| 
  if(f2.to_s[-4, 4].eql? ".pid")
    Chef::Log.info("Found pid file " + f2.to_s + " to save.")
    pid_file = f2.to_s
  end
end

# wait for the next available virtual device
lim = 0
while (!File.exists?(disk) && lim < 50) do
  sleep(10)
  lim += 1
end
if (!File.exists?(disk) && lim == 50)
  Chef::Log.info(disk + " was never attached!")
  http_request "FailHook0" do
	url "#{req_params['PostWaitUrl']}?Action=RemoteFailSignal&StackId=#{req_params['StackId']}&AcId=#{req_params['AcId']}"
	action :post
  end
end

# define mysql service
service "mysql" do
  service_name value_for_platform([ "centos", "redhat", "suse", "fedora", "scientific", "amazon" ] => {"default" => "mysqld"}, "default" => "mysql")
  if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
    restart_command "restart mysql"
    stop_command "stop mysql"
    start_command "start mysql"
  end
  supports :status => true, :restart => true, :reload => true
  action :nothing
end

# create a mount directory
#directory "/snapshot" do
#  owner "root"
#  group "root"
#  mode "0755"
#  action :create
#end
execute "create /snapshot directory" do
  command "mkdir /snapshot"
  action :nothing
  not_if do File.exists?('/snapshot') end
end.run_action(:run)

# mount the volume into the DBInstance
execute "mount volume" do
  command "mount #{disk} /snapshot"
  action :nothing
end.run_action(:run)

# untar the snapshot archive that was created by invoking CreateDBSnapshot
execute "untar snapshot archive" do
  cwd "/snapshot"
  command "tar xvf #{dbSnapshotId}.tar"
  action :nothing
end.run_action(:run)

execute "move data over" do
  cwd "/snapshot"
  command "cp data-#{dbSnapshotId}.tar #{datadir}"
  action :nothing
end.run_action(:run)

execute "move innodb-log over" do
  cwd "/snapshot"
  command "cp innodb-log-#{dbSnapshotId}.tar #{node['mysql']['innodb_log_group_home_dir']}"
  action :nothing
end.run_action(:run)

logbin = "#{node['mysql']['log-bin']}"
logbinDir = logbin[0, logbin.rindex('/')]

execute "move binlog over" do
  cwd "/snapshot"
  command "cp binlog-#{dbSnapshotId}.tar #{logbinDir}"
  action :nothing
end.run_action(:run)

# read the target directory name
subdir = ""
Dir.foreach("/snapshot/#{dbSnapshotId}") do |f| 
  unless(f.to_s.eql? ".")
	unless (f.to_s.eql? "..")
      Chef::Log.info("Timestamp: " + f.to_s)
	  subdir = f.to_s
	end
  end
end

# prepare the backup to be applied
execute "prepare the backup" do
  command "innobackupex --user=root --password=#{node[:mysql][:server_root_password]} --apply-log /snapshot/#{dbSnapshotId}/#{subdir}"
  action :nothing
  only_if do !File.exists?("/snapshot/#{dbSnapshotId}") end
end.run_action(:run)

execute "save the pid file" do
  unless("#{datadir}"[-1, 1].eql? "/")
    datadir = "#{datadir}" + "/"
  end
  command "mv #{datadir}#{pid_file} /"
  action :nothing
  only_if do !pid_file.eql? "" end
end.run_action(:run)

# restore from the backup; disabled due to innobackupex not being able to restore; see the execute resource below instead
#execute "restore the backup" do
#  Chef::Log.info("Subdir: " + subdir)
#  command "innobackupex --user=#{node[:mysql][:root_user]} --password=#{node[:mysql][:server_root_password]} --copy-back /snapshot/#{dbSnapshotId}/#{subdir}/"
#  action :run
#end

# restore from the backup archive
execute "restore the database" do
  cwd "#{datadir}"
  command "tar xvf data-#{dbSnapshotId}.tar"
  notifies :stop, resources(:service => "mysql"), :immediately
  action :nothing
end.run_action(:run)

# replace the pid file
execute "delete wrong pid file" do
  cwd "#{datadir}"
  command "rm *.pid"
  action :nothing
  only_if do !pid_file.eql? "" end 
end.run_action(:run)

execute "move pid file" do
  command "mv /#{pid_file} #{datadir}"
  action :nothing
  only_if do !pid_file.eql? "" end
end.run_action(:run)

# restore the innodb log and binlog
execute "restore the innodb log" do
  cwd "#{node['mysql']['innodb_log_group_home_dir']}"
  command "tar xvf innodb-log-#{dbSnapshotId}.tar"
  action :nothing
end.run_action(:run)

execute "restore the binlog" do
  cwd "#{logbinDir}"
  command "tar xvf binlog-#{dbSnapshotId}.tar"
  notifies :stop, resources(:service => "mysql"), :immediately
  action :nothing
end.run_action(:run)

# delete the extracted folders
execute "delete snapshot folder" do
  command "rm -r /snapshot/#{dbSnapshotId}"
  action :nothing
end.run_action(:run)

# delete the tar files
execute "delete data tar" do
  cwd "#{datadir}"
  command "rm data-#{dbSnapshotId}.tar"
  action :nothing
end.run_action(:run)

execute "delete innodb-log tar" do
  cwd "#{node['mysql']['innodb_log_group_home_dir']}"
  command "rm innodb-log-#{dbSnapshotId}.tar"
  action :nothing
end.run_action(:run)

execute "delete binlog tar" do
  cwd "#{logbinDir}"
  command "rm binlog-#{dbSnapshotId}.tar"
  action :nothing
end.run_action(:run)

# unmount the volume
execute "unmount the volume" do
  command "umount /snapshot"
  action :nothing
end.run_action(:run)

# restart the mysql service manually
execute "restart mysql" do
  command "service mysql restart"
  action :nothing
end.run_action(:run)

#send a signal to RDSQuery servlet to let it know that chef-client finished running
#dbInstId = config["request_parameters"]["PhysicalId"]
odbInstId = restore["OriginalDBInstanceIdentifier"]
dbInstId = config["request_parameters"]["PhysicalId"]
accountId = config["request_parameters"]["AcId"]
servletUrl = config["request_parameters"]["ServletUrl"]
http_request "signal CreateDBSnapshot" do
  action :nothing
  url "#{servletUrl}?Action=SignalCreateDBSnapshot&OriginalDBInstanceIdentifier=#{odbInstId}&DBInstanceIdentifier=#{dbInstId}&DBSnapshotIdentifier=#{dbSnapshotId}&AccountIdentifier=#{accountId}"
end.run_action(:post)

#deflag DBSnapshotting
restore['DBSnapshotIdentifier'] = nil
restore.save

