class CreateForewords < ActiveRecord::Migration
  def change
    create_table :forewords do |t|
      t.belongs_to :book
      t.text :dedication

      t.timestamps
    end
  end
end
