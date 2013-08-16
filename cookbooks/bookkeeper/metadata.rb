maintainer       "MomentumSI, Inc."
maintainer_email "dkim@momentumsi.com"
license          "Apache 2.0"
description      "Installs/Configures Apache Bookkeeper"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{ ubuntu debian centos redhat fedora }.each do |os|
    supports os
end

%w{ zookeeper }.each do |cb|
    depends cb
end
