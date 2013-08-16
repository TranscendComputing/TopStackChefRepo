set_unless[:zookeeper][:cluster_name] = "default"

# ZK defaults
set_unless[:zookeeper][:tick_time] = 2000
set_unless[:zookeeper][:init_limit] = 10
set_unless[:zookeeper][:sync_limit] = 5
set_unless[:zookeeper][:client_port] = 2181
set_unless[:zookeeper][:peer_port] = 2888
set_unless[:zookeeper][:leader_port] = 3888

set_unless[:zookeeper][:data_dir] = "/var/lib/zookeeper/data"
set_unless[:zookeeper][:version] = "3.5.0"

set_unless[:zookeeper][:ebs_vol_dev] = "/dev/sdp"
set_unless[:zookeeper][:ebs_vol_size] = 10

# Subversion tags for versions less than 3.5.0 are at something of the form:
#   http://svn.apache.org/repos/asf/zookeeper/tags/release-#{node[:zookeeper][:version]}"
set_unless[:zookeeper][:svnurl] = "http://svn.apache.org/repos/asf/zookeeper/trunk"
set_unless[:zookeeper][:srcdir] = "/usr/src"
