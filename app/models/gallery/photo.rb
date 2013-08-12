module Gallery
  class Photo < ActiveRecord::Base

    validates :uid, :uniqueness => { :scope => :provider }
    validates :source, :presence => true
    validates :url, :presence => true
    validates :uid, :presence => true
    validates :provider, :presence => true
    validates :thumbnail, :presence => true
    validates :aspect_ratio, :presence => true

    belongs_to :album, :counter_cache => true, :touch => true
  end
end
