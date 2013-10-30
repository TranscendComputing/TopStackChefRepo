maintainer        "Transcend Computing"
maintainer_email  "jgardner@transcendcomputing.com"
license           "Apache 2.0"
description       "Installs memcached and provides a define to set up an instance of memcache via runit"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version           "0.10.5"

depends "runit"
depends "transcend_topstack_host"

recipe "memcached", "Installs and configures memcached"

%w{ ubuntu debian }.each do |os|
  supports os
end

attribute "memcached/memory",
  :display_name => "Memcached Memory",
  :description => "Memory allocated for memcached instance",
  :default => "64"

attribute "memcached/port",
  :display_name => "Memcached Port",
  :description => "Port to use for memcached instance",
  :default => "11211"

attribute "memcached/user",
  :display_name => "Memcached User",
  :description => "User to run memcached instance as",
  :default => "nobody"

attribute "memcached/listen",
  :display_name => "Memcached IP Address",
  :description => "IP address to use for memcached instance",
  :default => "0.0.0.0"

attribute "memcached/maxconn",
  :display_name => "Memcached Max Connections",
  :description => "MAXCONN memcached param",
  :default => "1024"
