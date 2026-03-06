class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string  :first_name, null: false
      t.string  :last_name,  null: false
      t.string  :ssn,        null: false
      t.date    :date_of_birth, null: false
      t.string  :phone,      null: false
      t.integer :role,       default: 1
      t.boolean :active,     default: true

      t.timestamps
    end

    add_index :employees, :ssn, unique: true
  end
end
