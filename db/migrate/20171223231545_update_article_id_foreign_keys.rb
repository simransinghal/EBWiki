class UpdateArticleIdForeignKeys < ActiveRecord::Migration
  def change
    [
      :case_agencies,
      :case_documents,
      :case_officers,
      :links,
      :subjects
    ].each do |table|
      rename_column table, :article_id, :case_id
    end
  end
end
