class CreatePearlEnginePearlPlugins < ActiveRecord::Migration
  def change
    create_table :pearl_engine_pearl_plugins do |t|
      t.string   :type
      
      t.timestamps null: false
    end
  end
end
