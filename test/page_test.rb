require 'test_helper'

class Pamphlet::PageTest < Test::Unit::TestCase
  
  should_validate_presence_of :name
  should_belong_to :template
  should_validate_presence_of :template
  
  context " when a page exists" do 
    setup { Pamphlet::Page.create(:name => "index", :template => Pamphlet::Template.find(:first)) }

    should_validate_uniqueness_of :name, :case_sensitive => false
  end

  
end