class CreateDrawings < ActiveRecord::Migration[8.0]
  def change
    create_table :drawings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false, default: 'Untitled'
      t.jsonb :canvas_data, null: false, default: {}
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :drawings, :created_at
  end
end
