#
# Cookbook Name:: transcend_loadbalancer
# Recipe:: default
#
# Copyright 2012, Transcend Computing
#
#

data_bag_name = node[:__TRANSCEND__DATABAG__]
Chef::Log.info("Found configuration: #{data_bag_name}" )

data_bag = data_bag(data_bag_name)
Chef::Log.info("databag #{data_bag}")
if data_bag.count('config')==0 
        Chef::Log.info("failed to get databag item")
 else
        config = data_bag_item(data_bag_name, "config")
        Chef::Log.info(config.to_s)
end
        
if data_bag.count('command')!=0
        cmd_item = data_bag_item(data_bag_name, "command")
          Chef::Log.info("Command found #{cmd_item}")
          cmd = cmd_item['Command']
          if cmd == 'MonitorData'
                  period = cmd_item['Period'].to_i
                  Chef::Log.info("Command MonitorData")
                  if File.file? "/var/log/haproxy.log"
                        tq=tw=tc=tr=tt=num=x2=x3=x4=x5=e4=0
                          open("/var/log/haproxy.log").each do |ln| 
                                  if ln.length < 150
                                          next
                                  end
                                  wc=0
                                  dt=cnts=status=""
                                ln.scan(/[-':\/\.\[\]\w]+/) do |word|
                                        wc=wc+1
                                        dt = word if wc==7
                                        cnts = word        if wc==10
                                        status = word if wc==11
                                end
                                if cnts=="" || status ==""
                                        next
                                end
                                dt = dt[1..dt.length-2]
                                dt = DateTime.strptime(dt, '%d/%b/%Y:%H:%M:%S.%L')
                                usec = (dt.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
                            dt = Time.send(:local, dt.year, dt.month, dt.day, dt.hour, dt.min,dt.sec, usec)
                                nw = Time.new - period
                                if dt >= nw
                                        num = num + 1
                                        i = 0
                                        cd = status[0,1]
                                        x2 = x2+1 if cd=="2"
                                        x3 = x3+1 if cd=="3"
                                        x4 = x4+1 if cd=="4"
                                        x5 = x5+1 if cd=="5"
                                        # HTTPCode_ELB_4XX
                                        cnts.scan(/[\-0-9]+/) do |s|
                                                i = i +1
                                                v = s.to_i
                                                if v > 0
                                                        tq = tq + v if i==1
                                                        tw = tw + v if i==2
                                                        tc = tc + v if i==3
                                                        tr = tr + v if i==4
                                                        tt = tt + v if i==5
                                                end
                                        end
                                end
                          end
                          latency = 0;
                          if num > 0 
                                  latency = tt.to_f/num/1000
                        end
                        # UnHealthyHostCount
                        # HealthyHostCount

                        response = {
                                  "id" => "response",
                                  "Status" => "Success",
                                  "Latency" => "#{latency}",
                                  "RequestCount" => "#{num}",
                                 "HTTPCode_Backend_2XX" => "#{x2}",
                                "HTTPCode_Backend_3XX" => "#{x3}",
                                "HTTPCode_Backend_4XX" => "#{x4}",
                                "HTTPCode_Backend_5XX" => "#{x5}"
                        }
                        response_item = Chef::DataBagItem.new
                        response_item.data_bag(data_bag_name)
                        response_item.raw_data = response 
                        response_item.save
                end
        end
else

        id = config['Id']
        Chef::Log.info("DatabagItem id #{id}")

        listeners=config['Listeners']
        if listeners.nil?
          Chef::Log.error("Listeners not found")
        end

        instances=config['InstanceData']
        if instances.nil?
          Chef::Log.error("Instances not found")
        end

        package "sysklogd" do
          action :install
        end

        service "sysklogd" do
          supports :restart => true, :status => true, :reload => true
          action [:enable, :start]
        end

        template "/etc/default/syslogd" do
                  source "syslogd.erb"
                  mode 0644
                  notifies :restart, "service[sysklogd]" 
        end

        template "/etc/syslog.conf" do
                  source "syslog-conf.erb"
                  mode 0644
                  notifies :restart, "service[sysklogd]" 
        end

        execute "haproxy-log" do
          command "touch /var/log/haproxy.log"
          creates "/var/log/haproxy.log"
          not_if {File.exists?("/var/log/haproxy.log")}
          action :run
        end
         
        package "haproxy" do
          action :install
        end
         
        package "pound" do
          action :install
        end

        service "haproxy" do
          supports :restart => true, :status => true, :reload => true
          action [:enable, :start]
        end

        service "pound" do
          supports :restart => true, :status => true, :reload => true
          action [:enable]
        end

        template "/etc/haproxy/haproxy.cfg" do
                  source "haproxy-cfg.erb"
                  mode 0644
                  variables(:config => config)
                  notifies :restart, "service[haproxy]" 
        end
 
        template "/etc/default/haproxy" do
                  source "haproxy-default.erb"
                  mode 0644
                  notifies :restart, "service[haproxy]" 
        end

        template "/etc/pound/pound.cfg" do
                  source "pound-cfg.erb"
                  mode 0644
                  variables(:config => config)
                  notifies :restart, "service[pound]" 
        end

        template "/etc/default/pound" do
                  source "pound-default.erb"
                  mode 0644
                  notifies :restart, "service[pound]" 
        end
        
#        template "/etc/ssl/local.server.pem" do
#                  source "local.server.pem.erb"
#                  mode 0644
#                  variables(:config => config)
#                  notifies :restart, "service[pound]" 
#        end

        if config['PostWaitUrl'].nil?
                Chef::Log.info("No PostWait call required")
        else
                http_request "postwait" do
                  action :post
                  url "#{config['PostWaitUrl']}?Action=PostWait&PhysicalId=#{config['PhysicalId']}&StackId=#{config['StackId']}&AcId=#{config['AcId']}&Status=success"
                end
        end
end

