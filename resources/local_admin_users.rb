#
# Cookbook Name:: gecos-ws-mgmt
# Resource:: local_admin_users
#
# Copyright 2013, Junta de Andalucia
# http://www.juntadeandalucia.es/
#
# All rights reserved - EUPL License V 1.1
# http://www.osor.eu/eupl
#

actions :setup

attribute :local_admin_list, :kind_of => Array
attribute :local_admin_remove_list, :kind_of => Array
attribute :job_ids, :kind_of => Array
attribute :support_os, :kind_of => Array
