source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use mysql as the database for Active Record
gem 'pg', '~> 0.18'
gem 'rgeo'
gem 'rgeo-activerecord'
gem 'activerecord-postgis-adapter'
gem 'rgeo-shapefile'
gem 'rgeo-geojson'
gem 'geocoder'
gem 'pry'
gem 'devise'
gem 'simple_token_authentication'
gem 'apartment'
gem 'oj'
gem 'pager_api'
gem 'kaminari'
gem 'pagy'
gem 'will_paginate'
gem 'api-pagination'
# Job scheduler for Rails
gem 'crono'
gem 'capistrano-crono', group: :development
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
gem 'active_model_serializers'
gem 'paper_trail'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

  gem 'oj'
  gem 'faraday'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'letter_opener'


  gem 'capistrano', '~> 3.6'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano3-unicorn'

end
gem 'unicorn', '~> 5.4.0'
group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
