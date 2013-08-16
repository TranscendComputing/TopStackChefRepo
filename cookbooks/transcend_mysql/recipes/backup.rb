Chef::Log.info("Backup process will start for CreateDBSnapshot...")

# get the parameters from the data bag
Chef::Log.info("Variables for RDS config platform: #{node[:platform]}")
data_bag_name = node[:__TRANSCEND__DATABAG__]
Chef::Log.info("Found configuration: #{data_bag_name}" )
dbSnapshot = data_bag_item(data_bag_name, "DBSnapshot")
if dbSnapshot.nil? 
 Chef::Log.info("failed to get databag item: dbSnapshot")
else
 Chef::Log.info(dbSnapshot.to_s)
end

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

dbSnapshotId = dbSnapshot['DBSnapshotIdentifier']

config = data_bag_item(data_bag_name, "config")
if config.nil? 
 Chef::Log.info("failed to get databag item: config")
else
 Chef::Log.info(config.to_s)
end

disk0 = nil
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

disk = "/dev/" + disk0
diskEnc = "%2Fdev%2F" + disk0

Chef::Log.info("Disk devide = " + disk)
if !disk.eql? "/dev/"

# Call RDSQuery server to attach the volume to the next device available
http_request "Signal server to attach the volume" do
  action :post
  url "#{req_params['ServletUrl']}?Action=MountDBVolume&AcId=#{req_params['AcId']}&StackId=#{req_params['StackId']}&Device=#{diskEnc}&Snapshot=#{dbSnapshotId}"
end

# wait for the next available virtual device
ruby_block "wait for volume attachment" do
  block do
	lim = 0
	while (!File.exists?(disk) && lim < 50) do
	  sleep(10)
	  lim += 1
	end
	if (!File.exists?(disk) && lim == 50)
	  Chef::Log.info(disk + " was never attached!")
	  http_request "FailHook0" do
	    url "#{req_params['PostWaitUrl']}?Action=RemoteFailSignal&StackId=#{dbSnapshotId}&AcId=#{req_params['AcId']}"
		action :post
	  end
    end
  end
end

logbin = "#{node['mysql']['log-bin']}"
logbinDir = logbin[0, logbin.rindex('/')]
# create a directory to put the snapshot files
directory "/root/#{dbSnapshotId}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

# run innobackupex from percona-xtrabackup utilities
execute "run innobackupex" do
  cwd "/root/#{dbSnapshotId}"
  command "innobackupex --defaults-file=/etc/mysql/my.cnf --user=root --password=#{node[:mysql][:server_root_password]} ./"
  action :run
end

# tar up the directory, this will be used for restoration preparation
execute "tar snapshot" do
  cwd "/root"
  command "tar cvf #{dbSnapshotId}.tar #{dbSnapshotId}"
  action :run
end

# tar up the entire data that will be copied into the new DB
execute "tar data" do 
  cwd "#{node['mysql']['data_dir']}"
  command "tar cvf data-#{dbSnapshotId}.tar *"
  action :run
end

execute "tar innodb log" do 
  cwd "#{node['mysql']['innodb_log_group_home_dir']}"
  command "tar cvf innodb-log-#{dbSnapshotId}.tar *"
  action :run
end

execute "tar binlog" do
  cwd "#{logbinDir}"
  command "tar cvf binlog-#{dbSnapshotId}.tar *"
  action :run
end


# create a mount directory
directory "/snapshot" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if do File.exists?('/snapshot') end
end

# format the volume
execute "volume format" do
  command "mkfs.ext3 -F #{disk}"
  action :run
end

# mount the volume into the DBInstance
execute "mount volume" do
  command "mount #{disk} /snapshot"
  action :run
end

# copy the snapshot files
execute "copy snapshot files" do
  command "cp /root/#{dbSnapshotId}.tar /snapshot"
  action :run
end

execute "copy data" do 
  cwd "#{node['mysql']['data_dir']}"
  command "cp data-#{dbSnapshotId}.tar /snapshot"
  action :run
end

execute "copy innodb log" do 
  cwd "#{node['mysql']['innodb_log_group_home_dir']}"
  command "cp innodb-log-#{dbSnapshotId}.tar /snapshot"
  action :run
end

execute "copy binlog" do
  cwd "#{logbinDir}"
  command "cp binlog-#{dbSnapshotId}.tar /snapshot"
  action :run
end

# unmount the volume
execute "unmount the volume" do
  command "umount /snapshot"
  action :run
end

# delete the obsolete files
file "/root/#{dbSnapshotId}.tar" do
  action :delete
end

execute "delete data" do 
  cwd "#{node['mysql']['data_dir']}"
  command "rm data-#{dbSnapshotId}.tar"
  action :run
end

execute "delete innodb log" do 
  cwd "#{node['mysql']['innodb_log_group_home_dir']}"
  command "rm innodb-log-#{dbSnapshotId}.tar"
  action :run
end

execute "delete binlog" do
  cwd "#{logbinDir}"
  command "rm binlog-#{dbSnapshotId}.tar"
  action :run
end

execute "delete snapshot folder" do
  command "rm -r /root/#{dbSnapshotId}"
  action :run
end

#send a signal to RDSQuery servlet to let it know that chef-client finished running
dbInstId = config["request_parameters"]["PhysicalId"]
accountId = config["request_parameters"]["AcId"]
servletUrl = config["request_parameters"]["ServletUrl"]

http_request "signal CreateDBSnapshot" do
  Chef::Log.info("Calling SignalCreateDBSnapshot: " + "#{servletUrl}?Action=SignalCreateDBSnapshot&DBInstanceIdentifier=#{dbInstId}&DBSnapshotIdentifier=#{dbSnapshotId}&AccountIdentifier=#{accountId}")
  action :post
  url "#{servletUrl}?Action=SignalCreateDBSnapshot&DBInstanceIdentifier=#{dbInstId}&DBSnapshotIdentifier=#{dbSnapshotId}&AccountIdentifier=#{accountId}"
end

#deflag DBSnapshotting
dbSnapshot['DBSnapshotIdentifier'] = nil
dbSnapshot.save

end

