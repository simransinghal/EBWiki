class ChangeArticleToCase < ActiveRecord::Migration
  def change
    #rename_table :articles, :cases
    rename_table :article_agencies, :case_agencies
    rename_table :article_documents, :case_documents
    rename_table :article_officers, :case_officers
  end
end
