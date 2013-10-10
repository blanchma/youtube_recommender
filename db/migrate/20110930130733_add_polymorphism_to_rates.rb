class AddPolymorphismToRates < ActiveRecord::Migration
  def self.up
       add_column :user_rates, :scoreable_type, :string
       rename_column :user_rates, :user_id, :scoreable_id
  end

  def self.down
        remove_column :user_rates, :scoreable_type
        rename_column :user_rates, :scoreable_id, :user_id
  end
end
