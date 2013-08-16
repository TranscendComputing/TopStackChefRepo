maintainer       "GoTime Inc."
maintainer_email "ops@gotime.com"
license          "Apache 2.0"
description      "Installs/Configures zookeeper"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

recipe "zookeeper::ebs_volume", "Attaches or creates an EBS volume for zookeeper."
recipe "zookeeper::source", "Installs zookeeper from source and sets up configuration."

%w{ ubuntu debian centos redhat fedora }.each do |os|
    supports os
end

%w{ build-essential runit subversion maven java ant }.each do |cb|
    depends cb
end
