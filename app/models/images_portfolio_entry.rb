class ImagesPortfolioEntry < ActiveRecord::Base

  belongs_to :image
  belongs_to :portfolio_entry

  translates :caption if self.respond_to?(:translates)

  attr_accessible :image_id, :position, :locale
  self.translation_class.send :attr_accessible, :locale

  before_save do |image_portfolio_entry|
    image_portfolio_entry.position = (ImagesPortfolioEntry.maximum(:position) || -1) + 1
  end
end
