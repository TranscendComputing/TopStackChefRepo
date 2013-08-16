Chef::Log.info("Percona-xtrabackup installation recipe is called..")

# get the gpg key from percona and add it to gpg encryption set
#execute "dpkg config" do
#  command "dpkg --configure -a"
#  action :run
#end
execute "get gpg key" do
  command "gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A"
  action :run
end

execute "add gpg key" do
  command "gpg -a --export CD2EFD2A | sudo apt-key add -"
  action :run
end

# Modify /etc/apt/sources.list
execute "modify sources.list" do
  command "echo \"deb http://repo.percona.com/apt squeeze main\" >> /etc/apt/sources.list; echo \"deb-src http://repo.percona.com/apt squeeze main\" >> /etc/apt/sources.list"
  action :run
end

# update apt-get for the new apt repo
apt_get_update = execute "apt-get-update" do
  ignore_failure true
  epic_fail true
  command "apt-get update"
  action :run
end
#apt_get_update.run_action(:run)

# install percona-xtrabackup
package "percona-xtrabackup" do
  action :install
end

# configure percona-xtrabackup service resource
#service "percona-xtrabackup" do
#  service_name value_for_platform("default" => "innobackupex")
#  supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
#  action :nothing
#end
