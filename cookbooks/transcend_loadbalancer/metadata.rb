maintainer       "Transcend Computing"
maintainer_email "rarora@momentumsi.com"
license          "Apache 2.0"
description      "Installs/Configures loadbalancer"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.2.0"

recipe "loadbalancer::default", "Install a Loadbalancer."

%w{ ubuntu debian }.each do |os|
    supports os
end

=begin
%w{ }.each do |cb|
    depends cb
end
=end
