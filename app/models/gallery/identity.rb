module Gallery
  class Identity < ActiveRecord::Base
    has_many :albums

    def fetch_albums(force_fetch = false)
      case provider
      when 'eyeem'

        album = albums.find_by_provider_and_uid( :eyeem, 'eyeem_identifier')
        album = albums.create :provider => :eyeem, :uid => 'eyeem_identifier', :name => "My Eyeem Photos" unless album

        album.fetch_photos
      
      when 'google'
        client = OAuth2::Client.new('1040704984149.apps.googleusercontent.com', 'RHObwIrckTzGtwLA6aRY-vLB', :site => 'https://picasaweb.google.com/data/')
        access_token = OAuth2::AccessToken.new(client, self.token, :site => 'https://picasaweb.google.com/')
        album_response = JSON.parse(access_token.get('/data/feed/api/user/default?alt=json').body)
        # albums
        raw_albums = album_response['feed']['entry']

        raw_albums.each do |album|
          processed_album = albums.where({ :uid => album['gphoto$id']['$t'], :provider => 'google', :name => album['title']['$t'], :description => album['summary']['$t'], :url => album['link'][1]['href']}).first_or_create

          # only fetch if we are forced, or if updated_at is old enough
          processed_album.fetch_photos if force_fetch or processed_album.updated_at < album['updated']['$t']
        end
      end
    end

  end
end
