class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.belongs_to :book
      t.string :title
      t.integer :number

      t.timestamps
    end
  end
end
