#########################################################################################################
##### This recipe is used to signal RDSQuery server that this node has completed its reboot process #####
#########################################################################################################

# Get the data bag item(s) needed
Chef::Log.info("Variables for RDS config platform: #{node[:platform]}")
data_bag_name = node[:__TRANSCEND__DATABAG__]
Chef::Log.info("Found configuration: #{data_bag_name}" )

config = data_bag_item(data_bag_name, "config")
if config.nil? 
 Chef::Log.info("failed to get databag item: config")
else
 Chef::Log.info(config.to_s)
end

reboot = data_bag_item(data_bag_name, "Reboot")
if reboot.nil? 
 Chef::Log.info("failed to get databag item: reboot")
else
 Chef::Log.info(reboot.to_s)
end

req_params = config['request_parameters']
if req_params.nil? 
 Chef::Log.info("failed to get req_params")
else
 Chef::Log.info(req_params.to_s)
end

# Make the PostWait call to set the DBInstanceStatus
Chef::Log.info("PostWait Call to: " + "#{reboot['PostWaitUrl']}?Action=PostWait&PhysicalId=#{req_params['PhysicalId']}&StackId=#{req_params['StackId']}&AcId=#{req_params['AcId']}&Status=success")
 http_request "postwait" do
  action :post
  url "#{reboot['PostWaitUrl']}?Action=PostWait&PhysicalId=#{req_params['PhysicalId']}&StackId=#{req_params['StackId']}&AcId=#{req_params['AcId']}&Status=success"
end

#Turn the flag off, so the server.rb recipe can run as default
Chef::Log.info("Setting the flag off.")
reboot['Reboot'] = nil
reboot.save
