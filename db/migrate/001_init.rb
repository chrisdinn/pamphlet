class Init < ActiveRecord::Migration
  def self.up
    create_table "templates" do |t|
      t.string   "name"
      t.text     "description"
      t.text     "code"
    end
  end

  def self.down
    drop_table "templates"
  end
end