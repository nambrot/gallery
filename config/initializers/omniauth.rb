configpath = Rails.root.join('config', 'gallery_api_keys.yml')
providers = {}
if File.exists?(configpath)
  providers = YAML.load_file(configpath)
end


Rails.application.config.middleware.use OmniAuth::Builder do

  configure do |config|
      config.path_prefix = '/gallery/auth'
    end

  providers.each do |k,v|
    provider *(v.unshift(k))
  end
end