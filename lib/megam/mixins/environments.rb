require File.expand_path("#{File.dirname(__FILE__)}/megam_attributes")

module Megam
  class Environments
    include Nilavu::MegamAttributes

      attr_reader  :envs
    ATTRIBUTES = [
    ]
    def attributes
      ATTRIBUTES
    end
    
    def initialize(params)
     temp = {}
      params.each do |k,v|
       temp[k[:key]]=k[:value]
       ATTRIBUTES << k[:key]
      end
      set_attributes(temp)
    end

    def to_array 
    a= [to_hash]
    a
    end
  end
end
