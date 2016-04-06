class AddSummaryToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :summary, :text
  end
end
