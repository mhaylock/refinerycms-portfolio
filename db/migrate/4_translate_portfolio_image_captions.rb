class TranslatePortfolioImageCaptions < ActiveRecord::Migration
  def self.up
    add_column ::ImagesPortfolioEntry.table_name, :id, :primary_key
    
    ::ImagesPortfolioEntry.reset_column_information
    unless defined?(::ImagesPortfolioEntry::Translation) && ::ImagesPortfolioEntry::Translation.table_exists?
      ::ImagesPortfolioEntry.create_translation_table!({
        :caption => :string
      }, {
        :migrate_data => true
      })
    end
  end

  def self.down
    ::ImagesPortfolioEntry.reset_column_information

    ::ImagesPortfolioEntry.drop_translation_table! :migrate_data => true
    
    remove_column ::ImagesPortfolioEntry.table_name, :id
  end

end
