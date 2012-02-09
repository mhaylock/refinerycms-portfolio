require 'globalize3'

class PortfolioEntry < ActiveRecord::Base
  belongs_to :title_image, :class_name => 'Image'

  translates :title, :body if self.respond_to?(:translates)
  attr_accessor :locale # to hold temporarily
  
  validates :title, :presence => true

  # call to gems included in refinery.
  has_friendly_id :title, :use_slug => true
  acts_as_nested_set
  default_scope :order => 'lft ASC'
  acts_as_indexed :fields => [:title, :image_titles, :image_names]

  has_many :images_portfolio_entries, :order => 'images_portfolio_entries.position ASC'
  has_many :images, :through => :images_portfolio_entries, :order => 'images_portfolio_entries.position ASC'
  accepts_nested_attributes_for :images, :allow_destroy => false

  def images_attributes=(data)
    ids_to_delete = data.map{|i, d| d['image_portfolio_id']}.compact
    self.images_portfolio_entries.each do |image_portfolio_entry|
      if ids_to_delete.index(image_portfolio_entry.id.to_s).nil?
        # Image has been removed, we must delete it
        self.images_portfolio_entries.delete(image_portfolio_entry)
        image_portfolio_entry.destroy
      end
    end
              
    (0..(data.length-1)).each do |i|
      unless (image_data = data[i.to_s]).nil? or image_data['id'].blank?
        image_portfolio = if image_data['image_portfolio_id'].present?
          self.images_portfolio_entries.find(image_data['image_portfolio_id'])
        else
          self.images_portfolio_entries.new(:image_id => image_data['id'].to_i)
        end
        image_portfolio.position = i
        # Add caption if supported
        if RefinerySetting.find_or_set(:portfolio_images_captions, false)
          image_portfolio.caption = image_data['caption']
        end
                  
        self.images_portfolio_entries << image_portfolio if image_data['image_portfolio_id'].blank?
        image_portfolio.save
      end
    end
  end
  
  def image_titles
    self.images.collect{|i| i.title}
  end
  
  def image_names
    self.images.collect{|i| i.image_name}
  end
  
  def caption_for_image_index(index)
    self.images_portfolio_entries[index].try(:caption).presence || ""
  end
        
  def image_portfolio_id_for_image_index(index)
    self.images_portfolio_entries[index].try(:id)
  end
  

  alias_attribute :content, :body

end
