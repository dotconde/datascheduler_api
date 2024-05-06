class CreateEvent < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :title
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
