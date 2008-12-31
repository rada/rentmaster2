class CreateAdditionals < ActiveRecord::Migration
  def self.up
    create_table :additionals do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :additionals
  end
end
