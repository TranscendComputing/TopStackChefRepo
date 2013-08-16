maintainer       "MomentumSI, Inc."
maintainer_email "dkim@momentumsi.com"
license          "Apache 2.0"
description      "Installs/Configures hedwig"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

%w{ debian ubuntu centos }.each do |os|
  supports os
end

depends "java"
depends "runit"
