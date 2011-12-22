class AddCaptionToImagesPortfolioEntries < ActiveRecord::Migration
  def self.up
    add_column :images_portfolio_entries, :caption, :text
  end

  def self.down
    remove_column :images_portfolio_entries, :caption
  end
end
