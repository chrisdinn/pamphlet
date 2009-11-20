require 'active_record'

module Pamphlet
  class Template < ActiveRecord::Base
    validates_presence_of :name
  end
end