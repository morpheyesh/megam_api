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
  class BoltRequest < Megam::ServerAPI
    def initialize(email=nil, api_key=nil)
      @id = nil
      @req_type = nil
      @boltdefns_id = nil
      @node_name = nil
      @lc_apply = nil
      @lc_additional = nil
      @lc_when = nil
      @created_at = nil
      @some_msg = {}
      super(email, api_key)
    end

    def boltreqs
      self
    end

    
    def id(arg=nil)
      if arg != nil
        @id = arg
      else
      @id
      end
    end

    def req_type(arg=nil)
      if arg != nil
        @req_type = arg
      else
      @req_type
      end
    end

    def boltdefns_id(arg=nil)
      if arg != nil
        @boltdefns_id = arg
      else
      @boltdefns_id
      end
    end

    def node_name(arg=nil)
      if arg != nil
        @node_name = arg
      else
      @node_name
      end
    end

    def lc_apply(arg=nil)
      if arg != nil
        @lc_apply = arg
      else
      @lc_apply
      end
    end

    def lc_additional(arg=nil)
      if arg != nil
        @lc_additional = arg
      else
      @lc_additional
      end
    end

    def lc_when(arg=nil)
      if arg != nil
        @lc_when = arg
      else
      @lc_when
      end
    end

    def created_at(arg=nil)
      if arg != nil
        @created_at = arg
      else
      @created_at
      end
    end

    def some_msg(arg=nil)
      if arg != nil
        @some_msg = arg
      else
      @some_msg
      end
    end

    def error?
      crocked  = true if (some_msg.has_key?(:msg_type) && some_msg[:msg_type] == "error")
    end

    # Transform the ruby obj ->  to a Hash
    def to_hash
      index_hash = Hash.new
      index_hash["json_claz"] = self.class.name
      index_hash["id"] = id
      index_hash["req_type"] = req_type
      index_hash["boltdefns_id"] = boltdefns_id
      index_hash["node_name"] = node_name
      index_hash["lc_apply"] = lc_apply
      index_hash["lc_additional"] = lc_additional
      index_hash["lc_when"] = lc_when
      index_hash["created_at"] = created_at
      index_hash["some_msg"] = some_msg
      index_hash
    end

    # Serialize this object as a hash: called from JsonCompat.
    # Verify if this called from JsonCompat during testing.
    def to_json(*a)
      for_json.to_json(*a)
    end

    def for_json
      result = {
        "id" => id,
        "req_type" => req_type,
        "boltdefns_id" => boltdefns_id,
        "node_name" => node_name,
        "lc_apply" => lc_apply,
        "lc_additional" => lc_additional,
        "lc_when" => lc_when,
        "created_at" => created_at
      }
      result
    end

    # Create a Megam::Node from NodeResult-JSON
    #
    #[{
    #"id":"NOD362212018897289216",
    #"accounts_id":"ACT362211962353876992",
    #"json_claz":"Megam::Node",
    #"request":{
    #"req_id":"NOD362212018897289216",
    #"command":"commands"
    #},
    #"predefs":{
    #"name":"",
    #"scm":"",
    #"war":"",
    #"db":"",
    #"queue":""
    #}
    #}]
    #
    def self.json_create(o)
      boltreqs = new
      boltreqs.id(o["id"]) if o.has_key?("id")
      boltreqs.req_type(o["req_type"]) if o.has_key?("req_type")
      boltreqs.boltdefns_id(o["boltdefns_id"]) if o.has_key?("boltdefns_id")
      boltreqs.node_name(o["node_name"]) if o.has_key?("node_name")
      boltreqs.lc_apply(o["lc_apply"]) if o.has_key?("lc_apply")
      boltreqs.lc_additional(o["lc_additional"]) if o.has_key?("lc_additional")
      boltreqs.lc_when(o["lc_when"]) if o.has_key?("lc_when")
      boltreqs.created_at(o["created_at"]) if o.has_key?("created_at")

      boltreqs.some_msg[:code] = o["code"] if o.has_key?("code")
      boltreqs.some_msg[:msg_type] = o["msg_type"] if o.has_key?("msg_type")
      boltreqs.some_msg[:msg]= o["msg"] if o.has_key?("msg")
      boltreqs.some_msg[:links] = o["links"] if o.has_key?("links")

      boltreqs
    end

    def self.from_hash(o,tmp_email=nil, tmp_api_key=nil)
      boltreqs = self.new(tmp_email, tmp_api_key)
      boltreqs.from_hash(o)
      boltreqs
    end

    def from_hash(o)
      @id        = o["id"] if o.has_key?("id")
      @req_type        = o["req_type"] if o.has_key?("req_type")
      @boltdefns_id    = o["boltdefns_id"] if o.has_key?("boltdefns_id")
      @node_name = o["node_name"] if o.has_key?("node_name")
      @lc_apply   = o["lc_apply"] if o.has_key?("lc_apply")
      @lc_additional   = o["lc_additional"] if o.has_key?("lc_additional")
      @lc_when   = o["lc_when"] if o.has_key?("lc_when")
      @created_at        = o["created_at"] if o.has_key?("created_at")
      self
    end

    def self.create(o,tmp_email=nil, tmp_api_key=nil)
      acct = from_hash(o,tmp_email, tmp_api_key)
      acct.create
    end

    # Create the node via the REST API
    def create
      megam_rest.post_boltreq(to_hash)
    end

    # Load a account by email_p
    def self.list(node_name,tmp_email=nil, tmp_api_key=nil)
      boltreq = self.new(tmp_email, tmp_api_key)
      boltreq.megam_rest.get_boltreq(node_name)
    end

    def to_s
      Megam::Stuff.styled_hash(to_hash)
    end

  end
end
