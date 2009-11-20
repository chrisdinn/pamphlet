class CreatePages < ActiveRecord::Migration
  def self.up
    create_table "pages" do |t|
      t.string   "name"
      t.integer  "template_id"
      t.text     "content"
    end
  end

  def self.down
    drop_table "pages"
  end
end