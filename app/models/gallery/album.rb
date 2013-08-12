module Gallery
  class Album < ActiveRecord::Base
    validates :uid, :uniqueness => { :scope => :provider }

    has_many :photos, :dependent => :destroy
    belongs_to :identity, :touch => true

    scope :published, -> { where(public: true) }
    scope :private, -> {where(public: false)}

    def fetch_photos
      case provider.to_s
      when 'eyeem'

        client = OAuth2::Client.new('5kkCFgioQ2UgtZwTnpMFPH4FYCYWpkkq', 'RfdwC60OGDQOCaPssQIqiAbG5Y5HWzwG', :site => 'https://www.eyeem.com', :parse_json => true)
        access_token = OAuth2::AccessToken.new(client, identity.token, :site => 'https://eyeem.com/')
        response = JSON.parse(access_token.get('/api/v2/users/me/photos?detailed=1').body)
        
        raw_photos = response['photos']['items']
        
        processed_photos = []

        Album.transaction do
          processed_photos = raw_photos.map { |photo| photos.create :uid => photo['id'], :provider => :eyeem, :thumbs => {}, :source => photo['photoUrl'], :name => photo['id'], :url => photo['webUrl'], :aspect_ratio => photo['width']/photo['height'].to_f, :lat => (photo['latitude'] == '' ? nil : photo['latitude']), :long => (photo['longitude'] == '' ? nil : photo['longitude']), :taken_at => DateTime.parse(photo['updated']), :like_count => photo['totalLikes'], :comment_count => photo['totalComments'], :filter_name => (photo.has_key?('filter') ? photo['filter'] : nil) }
        end

        # fetch more if we have created them all and not empty
        while !processed_photos.map(&:persisted?).any?(&:blank?) and processed_photos.length > 0 do
          limit = response['photos']['limit']
          offset = response['photos']['offset'] + limit
          response = JSON.parse(access_token.get("/api/v2/users/me/photos?detailed=1&limit=#{limit}&offset=#{offset}").body)
          raw_photos = response['photos']['items']

          Album.transaction do
            processed_photos = raw_photos.map { |photo| photos.create :uid => photo['id'], :provider => :eyeem, :thumbs => {}, :source => photo['photoUrl'], :name => photo['id'], :url => photo['webUrl'], :aspect_ratio => photo['width']/photo['height'].to_f, :lat => (photo['latitude'] == '' ? nil : photo['latitude']), :long => (photo['longitude'] == '' ? nil : photo['longitude']), :taken_at => DateTime.parse(photo['updated']), :like_count => photo['totalLikes'], :comment_count => photo['totalComments'], :filter_name => (photo.has_key?('filter') ? photo['filter'] : nil) }
          end
          
        end


      when 'google'
        client = OAuth2::Client.new('1040704984149.apps.googleusercontent.com', 'RHObwIrckTzGtwLA6aRY-vLB', :site => 'https://picasaweb.google.com/data/')
        access_token = OAuth2::AccessToken.new(client, self.identity.token, :site => 'https://picasaweb.google.com/')
        album_response = JSON.parse(access_token.get("/data/feed/api/user/default/albumid/#{uid}?alt=json").body)

        return unless album_response['feed'].has_key? 'entry'
        
        raw_photos = album_response['feed']['entry']
        
        Album.transaction do
          processed_photos = raw_photos.map { |photo| photos.create :uid => photo['gphoto$id']['$t'], :provider => :google, :thumbnail => photo['content']['src'].gsub(/\/[^\/]*\z/, '/w512-h512-no/photo'), :url => photo['link'][1]['href'], :name => photo['title']['$t'], :source => photo['content']['src'].gsub(/\/[^\/]*\z/, '/w2048-h2048-no/photo'), :aspect_ratio => photo['gphoto$width']['$t'].to_f/photo['gphoto$height']['$t'].to_f}
          
          # only fetch more if all photos were successfully created and we have equal total to per page
          # TODO: actually do this, google right now returns 1000, plenty
        end
        
      end
    end

    def cover_photo
      photos.first
    end

  end
end
