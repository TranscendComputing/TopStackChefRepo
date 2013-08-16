set_unless[:bookkeeper][:zookeeper] = "localhost:2181"

set_unless[:bookkeeper][:port] = "3181"

set_unless[:bookkeeper][:log_dir] = "/var/lib/bookkeeper-4.0.0/bookkeeper-server/data/bk-txn/"
set_unless[:bookkeeper][:data_dir] = "/var/lib/bookkeeper-4.0.0/bookkeeper-server/data/bk-data/"

set_unless[:bookkeeper][:version] = "4.0.0"

# Subversion tags for versions 4.0.0 or less are at something of the form:
#   http://svn.apache.org/repos/asf/zookeeper/bookkeeper/tags//release-#{node[:bookkeeper][:version]}"
set_unless[:bookkeeper][:svnurl] = "http://svn.apache.org/repos/asf/zookeeper/bookkeeper/trunk"
