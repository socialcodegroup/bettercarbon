class CreateQueryTags < ActiveRecord::Migration
  def self.up
    create_table :query_tags do |t|
      t.integer  :query_id
      t.integer  :tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :query_tags
  end
end
