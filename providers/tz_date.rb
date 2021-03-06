#
# Cookbook Name:: gecos-ws-mgmt
# Provider:: tz_date
#
# Copyright 2013, Junta de Andalucia
# http://www.juntadeandalucia.es/
#
# All rights reserved - EUPL License V 1.1
# http://www.osor.eu/eupl
#

action :setup do
  begin
    if new_resource.support_os.include?($gecos_os)
      $required_pkgs['tz_date'].each do |pkg|
        Chef::Log.debug("tz_date.rb - REQUIRED PACKAGE = #{pkg}")
        package pkg do
          action :nothing
        end.run_action(:install)
      end

      ntp_server = new_resource.server
      unless ntp_server.nil? || ntp_server.empty?
        execute 'ntpdate' do
          command "ntpdate-debian -u #{ntp_server}"
          action :nothing
        end.run_action(:run)

        var_hash = {
          ntp_server: new_resource.server
        }
        template '/etc/default/ntpdate' do
          action :nothing
          source 'ntpdate.erb'
          owner 'root'
          group 'root'
          mode '0644'
          variables var_hash
        end.run_action(:create)
      end
    else
      Chef::Log.info('This resource is not supported in your OS')
    end

    # save current job ids (new_resource.job_ids) as "ok"
    job_ids = new_resource.job_ids
    job_ids.each do |jid|
      node.normal['job_status'][jid]['status'] = 0
    end
  rescue StandardError => e
    Chef::Log.error(e.message)
    Chef::Log.error(e.backtrace.join("\n"))

    # just save current job ids as "failed"
    # save_failed_job_ids
    job_ids = new_resource.job_ids
    job_ids.each do |jid|
      node.normal['job_status'][jid]['status'] = 1
      if !e.message.frozen?
        node.normal['job_status'][jid]['message'] =
          e.message.force_encoding('utf-8')
      else
        node.normal['job_status'][jid]['message'] = e.message
      end
    end
  ensure
    gecos_ws_mgmt_jobids 'tz_date_res' do
      recipe 'misc_mgmt'
    end.run_action(:reset)
  end
end
