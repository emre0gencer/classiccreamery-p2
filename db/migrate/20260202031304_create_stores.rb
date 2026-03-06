class CreateStores < ActiveRecord::Migration[8.1]
  def change
    create_table :stores do |t|
      t.string  :name,   null: false
      t.string  :street, null: false
      t.string  :city,   null: false
      t.string  :state,  default: 'PA'
      t.string  :zip,    null: false
      t.string  :phone,  null: false
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
