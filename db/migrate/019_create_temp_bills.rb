class CreateTempBills < ActiveRecord::Migration
  def self.up
    create_table :temp_bills do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :temp_bills
  end
end
