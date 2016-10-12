class RenameArticlesToCases < ActiveRecord::Migration
  def change
    rename_table :articles, :cases
  end
end
