# read the target directory name
ruby_block "read target archive directory name" do
  block do
	Dir.foreach("/snapshot/#{dbSnapshotId}") do |f| 
      unless(f.to_s.eql? ".")
        unless (f.to_s.eql? "..")
          Chef::Log.info("Timestamp: " + f.to_s)
          subdir = f.to_s
		  node[:RestoreSubdir] = subdir
  		  node.save
        end
      end
    end
  end
  action :create
end
