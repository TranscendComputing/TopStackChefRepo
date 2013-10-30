name             "transcend_topstack_host"
maintainer       "Transcend Computing"
maintainer_email "jgardner@transcendcomputing.com"
license          "Copyright 2012, 2013 Transcend Computing, All rights reserved"
description      "Installs/Configures transcend_topstack_host"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.2.10"

recipe "transcend_topstack_host", "Installs/Configures transcend_topstack_host"
recipe "transcend_topstack_host::available", "Determines available versions of particular packages required for TopStack"
recipe "transcend_topstack_host::install", "Installs specific version of particular packages required for TopStack"

%w{ ubuntu }.each do |os|
    supports os
end
