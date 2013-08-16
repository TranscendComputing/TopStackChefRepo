maintainer        "Transcend Computing, Inc."
maintainer_email  "info@transcendcomputing.com"
license           "Apache 2.0"
description       "Handles Simple Load Balancer Configurations"
version           "0.1.1"

%w{ redhat centos fedora ubuntu debian }.each do |os|
  supports os
end

#depends "apache2"

recipe "default.rb", "Includes the config recipe."
recipe "transcend_slb::config", "Handles reconfiguration of the SLB user and cloud information."
