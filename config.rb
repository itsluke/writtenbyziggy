require 'pry'

activate :livereload
activate :directory_indexes
activate :asset_hash, exts: ['.css', '.js']

Time.zone = "GMT"

set :haml, format: :html5

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"
  blog.permalink = "{title}.html"
end

page "/feed.xml", layout: false
page "/sitemap.xml", layout: false

###
# Sitemap settings
###
activate :sitemap, hostname: "http://writtenbyziggy.com"

activate :livereload
activate :directory_indexes
activate :asset_hash, exts: ['.css', '.js']

set :css_dir, 'css'
set :js_dir, 'js'
set :images_dir, 'img'

set :protocol, 'http://'
set :host, 'writtenbyziggy.com'
set :port, '80'

helpers do

  def host_with_port
    [host, optional_port].compact.join(':')
  end

  def optional_port
    port unless port.to_i == 80
  end

  def image_url(source)
    protocol + host_with_port + image_path(source)
  end

end

compass_config do |config|
  config.add_import_path "./components"
end

after_configuration do
	@bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
	sprockets.append_path File.join "#{root}", @bower_config["directory"]
end

# add 'hire-us' ember app output to sprockets for JS includes
sprockets.append_path File.join "#{root}", 'hire-us-client/dist/assets'

activate :autoprefixer do |config|
  config.browsers = ['last 2 versions', 'Explorer >= 9']
end

configure :development do
  set :api_host, 'http://0.0.0.0:3000'
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Uglify the htmls with middleman-minify-html
  activate :minify_html

  # Reduce image sizes with middleman-imageoptim
  # activate :imageoptim

  # Serve compressed files
  activate :gzip

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"

  set :api_host, 'http://recordmyhing.herokuapp.com'

  data.case_studies.each do |id, case_study|
    if case_study.published == false
      ignore "/case-studies/#{id.dasherize}.html"
    end
  end
  ignore "/role.html"

end

page "/case-studies/*", layout: 'layouts/case-study'
page "/blog/*", layout: 'layouts/post'
page "/contact"

data.cv.roles.each do |role|
  page "/cv/#{role.slug}.html", proxy: "role.html", locals: { role: role }, directory_index: false
end


set :latest_role, "/cv/#{data.cv.roles.first.slug}"

ready do
  latest_article = blog.articles.first
  # latest_role = "/cv/#{data.cv.roles.first.slug}"
  redirect "blog.html", to: latest_article
  # redirect "cv.html", to: latest_role
end

page "/404.html", directory_index: false



