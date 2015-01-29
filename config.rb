# Bower specific setup
after_configuration do
  @bower_config = JSON.parse(IO.read("#{root}/.bowerrc"))
  @bower_assets_path = File.join "#{root}", @bower_config["directory"]
  sprockets.append_path @bower_assets_path
end

# dev mode addons
activate :livereload

activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  blog.prefix = "blog"
  blog.layout = "blog_post"

  blog.permalink = "/{year}/{month}/{title}"
  # Matcher for blog source files
  # blog.sources = "{year}-{month}-{day}-{title}.html"
  # blog.taglink = "tags/{tag}.html"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  blog.per_page = 10
  # blog.page_link = "page/{num}"
end

page "/blog/feed.xml", layout: false

# for build
activate :syntax
set :markdown_engine, :kramdown
activate :directory_indexes

page "documentation/**/*.html", directory_index: false

set :css_dir,    'stylesheets'
set :js_dir,     'javascripts'
set :images_dir, 'images'
set :frontmatter_extensions, %w(.html .slim)

# necessary whilst testing
set :relative_links, true

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :favicon_maker, icons: { "_favicon_template.png" =>
      [
        { icon: "apple-touch-icon-152x152-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPad with iOS7.
        { icon: "apple-touch-icon-144x144-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPad with iOS6 or prior.
        { icon: "apple-touch-icon-120x120-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPhone with iOS7.
        { icon: "apple-touch-icon-114x114-precomposed.png" },             # Same as apple-touch-icon-57x57.png, for retina iPhone with iOS6 or prior.
        { icon: "apple-touch-icon-76x76-precomposed.png" },               # Same as apple-touch-icon-57x57.png, for non-retina iPad with iOS7.
        { icon: "apple-touch-icon-72x72-precomposed.png" },               # Same as apple-touch-icon-57x57.png, for non-retina iPad with iOS6 or prior.
        { icon: "apple-touch-icon-60x60-precomposed.png" },               # Same as apple-touch-icon-57x57.png, for non-retina iPhone with iOS7.
        { icon: "apple-touch-icon-57x57-precomposed.png" },               # iPhone and iPad users can turn web pages into icons on their home screen. Such link appears as a regular iOS native application. When this happens, the device looks for a specific picture. The 57x57 resolution is convenient for non-retina iPhone with iOS6 or prior. Learn more in Apple docs.
        { icon: "apple-touch-icon-precomposed.png", size: "57x57" },      # Same as apple-touch-icon.png, expect that is already have rounded corners (but neither drop shadow nor gloss effect).
        { icon: "apple-touch-icon.png", size: "57x57" },                  # Same as apple-touch-icon-57x57.png, for "default" requests, as some devices may look for this specific file. This picture may save some 404 errors in your HTTP logs. See Apple docs
        { icon: "favicon-196x196.png" },                                  # For Android Chrome M31+.
        { icon: "favicon-160x160.png" },                                  # For Opera Speed Dial (up to Opera 12; this icon is deprecated starting from Opera 15), although the optimal icon is not square but rather 256x160. If Opera is a major platform for you, you should create this icon yourself.
        { icon: "favicon-96x96.png" },                                    # For Google TV.
        { icon: "favicon-32x32.png" },                                    # For Safari on Mac OS.
        { icon: "favicon-16x16.png" },                                    # The classic favicon, displayed in the tabs.
        { icon: "favicon.png", size: "16x16" },                           # The classic favicon, displayed in the tabs.
        { icon: "favicon.ico", size: "64x64,32x32,24x24,16x16" },         # Used by IE, and also by some other browsers if we are not careful.
        { icon: "mstile-70x70.png", size: "70x70" },                      # For Windows 8 / IE11.
        { icon: "mstile-144x144.png", size: "144x144" },
        { icon: "mstile-150x150.png", size: "150x150" },
        { icon: "mstile-310x310.png", size: "310x310" },
      ]
    }
end

activate :deploy do |deploy|
  deploy.method = :git
  deploy.build_before = true
  deploy.branch = 'master'

  case ENV['TARGET'].to_s
  when /prod/i
    deploy.remote = 'git@github.com:rspec/rspec.github.io.git'
  else
    deploy.remote = 'git@github.com:RSpec-Staging/rspec-staging.github.io.git'
  end
end

helpers do
  def primary_page_class
    page_classes.split(" ").first
  end

  def asciinema_video(id, speed: 1)
    <<-HTML.gsub(/^ +\|/, '')
      |<div class="asciinema-video">
      |  <script type="text/javascript" src="https://asciinema.org/a/#{id}.js" id="asciicast-#{id}" data-size="small" data-speed="#{speed}", async></script>
      |</div>
    HTML
  end

  def rspec_documentation
    hash = Hash.new { |h,k| h[k] = [] }
    Dir["#{root}/source/documentation/*/*"].each do |dir|
      version, gem = dir.scan(%r{/source/documentation/([^/]+)/([^/]+)}).first.flatten
      hash[gem] << version
    end
    hash
  end

  def documentation_links_for(gem_name)
    versions = rspec_documentation.fetch(gem_name) { [] }.sort.reverse
    unless versions.empty?
      content_tag :div, 'class' => 'version-dropdown' do
        list = content_tag :ul do
          versions.map do |version|
            content_tag :li do
              link_to version, "/documentation/#{version}/#{gem_name}/"
            end
          end.join('')
        end

        link_to(versions.first, '#') + list
      end
    end
  end
end