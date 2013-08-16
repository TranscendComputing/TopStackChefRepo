begin
  require 'transcend_mysql'
rescue LoadError
  Chef::Log.info("Missing gem 'transcend_mysql'")
end

module Opscode
  module Mysql
    module Database
      def db
        @db ||= ::Mysql.new new_resource.host, new_resource.username, new_resource.password
      end
      def close
        @db.close rescue nil
        @db = nil
      end
    end
  end
end
