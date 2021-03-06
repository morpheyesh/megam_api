# Copyright:: Copyright (c) 2012, 2014 Megam Systems
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Megam
  class DeleteNode < Megam::ServerAPI
    def initialize(email=nil, api_key=nil)
      super(email, api_key)
    end

    def self.create(data, group, action, tmp_email=nil, tmp_api_key=nil)
      delete_command = self.new(tmp_email, tmp_api_key)
      begin
        node_collection = delete_command.megam_rest.get_node(data[:node_name])
        ct_collection = delete_command.megam_rest.get_cloudtools
        cts_collection = delete_command.megam_rest.get_cloudtoolsettings
      rescue ArgumentError => ae
        hash = {"msg" => ae.message, "msg_type" => "error"}
        re = Megam::Error.from_hash(hash)
        return re
      rescue Megam::API::Errors::ErrorWithResponse => ewr
        hash = {"msg" => ewr.message, "msg_type" => "error"}
        re = Megam::Error.from_hash(hash)
        return re
      rescue StandardError => se
        hash = {"msg" => se.message, "msg_type" => "error"}
        re = Megam::Error.from_hash(hash)
      return re
      end    
      node = node_collection.data[:body].lookup(data[:node_name])     
      tool = ct_collection.data[:body].lookup(node.request[:command]['systemprovider']['provider']['prov'])
      template = tool.cloudtemplates.lookup(node.request[:command]['compute']['cctype'])
      cloud_instruction = template.lookup_by_instruction(group, action)
      cts = cts_collection.data[:body].lookup(data[:repo])     
      ci_command = "#{cloud_instruction.command}"
      if ci_command["<node_name>"].present?
        ci_command["<node_name>"] = "#{data[:node_name]}"
      end
      u = URI.parse(node.request[:command]['compute']['access']['vault_location'])
      u.path[0]=""
      if ci_command["-f"].present?
        ci_command["-f"] = "-f " + u.path + "/#{node.request[:command]['compute']['cctype']}.json"
      end

      if ci_command["-c"].present?
        ci_command["-c"] = "-c #{cts.conf_location}"
      end
      command_hash = {
        "systemprovider" => {
          "provider" => {
            "prov" => "#{node.request[:command]['systemprovider']['provider']['prov']}"
          }
        },
        "compute" => {
          "cctype" => "#{node.request[:command]['compute']['cctype']}",
          "cc" => {
            "groups" => "",
            "image" => "",
            "flavor" => "",
            "tenant_id" =>  "#{node.request[:command]['compute']['cc']['tenant_id']}"
          },
          "access" => {
            "ssh_key" => "",
            "identity_file" => "",
            "ssh_user" => "",
            "vault_location" => "#{node.request[:command]['compute']['access']['vault_location']}",
            "sshpub_location" => "#{node.request[:command]['compute']['access']['sshpub_location']}",
            "zone" => "#{node.request[:command]['compute']['access']['zone']}",
            "region" => "#{node.request[:command]['compute']['access']['region']}"
          }
        },
        "cloudtool" => {
          "chef" => {
            "command" => "#{node.request[:command]['cloudtool']['chef']['command']}",
            "plugin" => "#{node.request[:command]['compute']['cctype']} #{ci_command}", #ec2 server delete or create
            "run_list" => "",
            "name" => "-N #{data[:node_name]}"
          }
        }
      }
      node_hash = {
        "node_name" => "#{data[:node_name]}",
        "node_type" => "#{node.node_type}",
        "req_type" => "#{action}",
        "noofinstances" => "",
        "command" => command_hash,
        "predefs" => {},
        "appdefns" => {},
        "boltdefns" => {},
        "appreq" => {},
        "boltreq" => {}
      }
      node_hash
    end
  end
end
