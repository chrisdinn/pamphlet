class Init < ActiveRecord::Migration
  def self.up
    create_table "templates" do |t|
      t.string   "name"
      t.text     "description"
      t.string   "role"
      t.text     "code"
      t.binary   "parsed_code"
      t.integer  "layout_id"
    end
  end

  def self.down
    drop_table "templates"
  end
end