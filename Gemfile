source "https://rubygems.org"

gem "jekyll", "~> 4.1.0"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem 'jekyll-redirect-from'
end

install_if -> { RUBY_PLATFORM =~ %r!mingw|mswin|java! } do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end
