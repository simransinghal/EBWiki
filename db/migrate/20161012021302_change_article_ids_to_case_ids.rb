class ChangeArticleIdsToCaseIds < ActiveRecord::Migration
  def change
    rename_table :article_agencies, :case_agencies
    rename_column :case_agencies, :article_id, :case_id
    rename_table :article_officers, :case_officers
    rename_column :case_officers, :article_id, :case_id
    remove_index :links, :article_id
    rename_column :links, :article_id, :case_id
    add_index :links, :case_id
    rename_column :subjects, :article_id, :case_id
    #add_foreign_key "links", "cases", column: "case_id"
  end
end
