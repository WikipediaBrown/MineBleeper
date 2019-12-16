#!/bin/bash
# 
# Initial values needed to build Jekyll site
APP_NAME=${PWD##*/}
JEKYLL_DIRECTORY=docs


# Function List
# If file does not exists, create it and add its content
add_file () { echo "Checking $4 file."; test -f "$1/$2" || { mkdir -p "$1"; touch "$1/$2"; printf -- "$3" > "$1/$2"; echo "Added $2..."; }; }

# Beginning Site Setup
echo "Setting up site for $APP_NAME"
# gem install jekyll bundler

# Create and move into directory
mkdir $JEKYLL_DIRECTORY
cd $JEKYLL_DIRECTORY

# Making sure a gemfile exists
echo 'Checking Gemfile...'
test -f ./Gemfile || { bundle init; echo 'Added Gemfile...'; }

# Making sure the correct dependencies are set
echo 'Installing Dependencies...'

# Adding Jekyll
JEKYLL="gem \"jekyll\""
grep -Fxq "$JEKYLL" Gemfile || { printf -- "$JEKYLL\n\n" >> Gemfile; echo 'Added Jekyll...'; }

#Adding Jekyll Plugins
JEKYLL_PLUGINS="group :jekyll_plugins do\n    gem \'jekyll-sitemap\'\n    gem \'jekyll-feed\'\n    gem \'jekyll-seo-tag\'\nend"
grep -Fxq $"group :jekyll_plugins do" Gemfile || { printf "$JEKYLL_PLUGINS\n\n" >> Gemfile; echo 'Added Jekyll Dependencies...';}

# Installing Dependencies
bundle --quiet


# Adding Support Files
# Adding Configuration File
CONFIG_YAML="baseurl: /$APP_NAME\r\n\r\ncollections:\r\n  contributors:\r\n    output: true\r\n\r\ndefaults:\r\n  - scope:\r\n      path: \"\"\r\n      type: \"contributors\"\r\n    values:\r\n      layout: \"contributor\"\r\n  - scope:\r\n      path: \"\"\r\n      type: \"posts\"\r\n    values:\r\n      layout: \"post\"\r\n  - scope:\r\n      path: \"\"\r\n    values:\r\n      layout: \"default\"\r\n\r\nplugins:\r\n  - jekyll-feed\r\n  - jekyll-sitemap\r\n  - jekyll-seo-tag\r\n"
add_file . _config.yml "$CONFIG_YAML" 'Configuration'

# Adding Navigation Data
NAVIGATION_DATA="- name: Home\r\n  link: /\r\n- name: About\r\n  link: /about.html\r\n- name: Privacy Policy\r\n  link: /privacy_policy.html\r\n- name: Blog\r\n  link: /blog.html\r\n- name: Contributors\r\n  link: /contributors.html\r\n- name: Support\r\n  link: /support.html\r\n- name: Beta\r\n  link: /beta.html"
add_file ./_data navigation.yml "$NAVIGATION_DATA" 'Navigation Data'

# Adding Navigation HTML
NAVIGATION_HTML="<nav>\r\n    {%% for item in site.data.navigation %%}\r\n        <a href=\"{{ site.baseurl }}{{ item.link }}\" {%% if page.url == item.link %%}class=\"current\"{%% endif %%}>{{ item.name }}</a>\r\n    {%% endfor %%}\r\n</nav>\r\n"
add_file ./_includes navigation.html "$NAVIGATION_HTML" 'Navigation HTML'


#Adding Content Files
# Adding Initial Contributor
ADMIN_HTML="---\r\nname: Admin\r\nposition: Administrator\r\n---\r\n{{ page.name }} the {{ page.position }} is the creator and administrator of $APP_NAME.\r\n"
add_file ./_contributors admin.md "$ADMIN_HTML" 'Contributors'

# Adding Secondary Contributor
ASSISTANT_HTML="---\r\nname: Assistant\r\nposition: Assistant\r\n---\r\n{{ page.name }} the {{ page.position }} is the Assistant to the administrator of $APP_NAME.\r\n"
add_file ./_contributors assistant.md "$ASSISTANT_HTML" 'Contributors'

# Adding First Post
POST_CONTENT="---\r\nlayout: post\r\ncontributor: Admin\r\n---\r\n\r\n$APP_NAME\'s blog is coming soon to an RSS reader near you.\r\n"
add_file ./_posts "$(date +%F)-ComingSoon.md" "$POST_CONTENT" 'Post Content'


# Adding Page Files
# Adding About File
ABOUT_MD="---\r\ntitle: About\r\n---\r\n# About page\r\n\r\nThis page tells you a little bit about $APP_NAME."
add_file . about.md "$ABOUT_MD" 'About'

# Adding Support File
BETA_MD="---\r\ntitle: Beta\r\n---\r\n# Beta page\r\n\r\nThis page is where you can sign up for access to the $APP_NAME Beta."
add_file . beta.md "$BETA_MD" 'Beta'

# Adding Blog File
BLOG_HTML="---\r\ntitle: Blog\r\n---\r\n<h1>Latest Posts</h1>\r\n\r\n<ul>\r\n  {%% for post in site.posts %%}\r\n    <li>\r\n      <h2><a href=\"{{ site.baseurl }}{{ post.url }}\">{{ post.title }}</a></h2>\r\n      <p>{{ post.excerpt }}</p>\r\n    </li>\r\n  {%% endfor %%}\r\n</ul>"
add_file . blog.html "$BLOG_HTML" 'Blog'

# Adding Contributors File
CONTRIBUTORS_HTML="---\r\ntitle: Contributors\r\n---\r\n<h1>Contributors</h1>\r\n\r\n<ul>\r\n  {%% for contributor in site.contributors %%}\r\n    <li>\r\n      <h2><a href=\"{{ site.baseurl }}{{ contributor.url }}\">{{ contributor.name }}</a></h2>\r\n      <h3>{{ contributor.position }}</h3>\r\n      <p>{{ contributor.content | markdownify }}</p>\r\n    </li>\r\n  {%% endfor %%}\r\n</ul>"
add_file . contributors.html "$CONTRIBUTORS_HTML" 'Contributors'

# Adding 404 File
ERROR_MD="---\r\nlayout: default\r\n---\r\n\r\n# 404\r\n\r\nPage not found! :("
add_file . 404.md "$ERROR_MD" '404'

# Adding Index File
INDEX_HTML="---\r\ntitle: Home\r\n---\r\n<h1>$APP_NAME</h1>\r\n\r\n<p>It's the app for that!</p>"
add_file . index.html "$INDEX_HTML" 'Index'

# Adding Support File
SUPPORT_MD="---\r\ntitle: Support\r\n---\r\n# Support page\r\n\r\nThis page is where you should come for help with $APP_NAME."
add_file . support.md "$SUPPORT_MD" 'Support'


# Adding Layouts
# Adding Contributor Layout
CONTRIBUTOR_LAYOUT="---\r\nlayout: default\r\n---\r\n<h1>{{ page.name }}</h1>\r\n<h2>{{ page.position }}</h2>\r\n\r\n{{ content }}\r\n\r\n<h2>Posts</h2>\r\n<ul>\r\n  {%% assign filtered_posts = site.posts | where: \'contributor\', page.name %%}\r\n  {%% for post in filtered_posts %%}\r\n    <li><a href=\"{{ site.baseurl }}{{ post.url }}\">{{ post.title }}</a></li>\r\n  {%% endfor %%}\r\n</ul>"
add_file ./_layouts contributor.html "$CONTRIBUTOR_LAYOUT" 'Contributor Layout'

# Adding Default Layout
DEFAULT_LAYOUT="<!doctype html>\r\n<html>\r\n  <head>\r\n    <meta charset=\"utf-8\">\r\n    <title>{{ page.title }}</title>\r\n    <link rel=\"stylesheet\" href=\"{{ site.baseurl }}/assets/css/styles.css\">\r\n    {%% feed_meta %%}\r\n    {%% seo %%}\r\n  </head>\r\n  <body>\r\n    {%% include navigation.html %%}\r\n    {{ content }}\r\n  </body>\r\n</html>\r\n"
add_file ./_layouts default.html "$DEFAULT_LAYOUT" 'Default Layout'

# Adding Post Layout
POST_LAYOUT="---\r\nlayout: default\r\n---\r\n<h1>{{ page.title }}</h1>\r\n<p>\r\n    {%% assign contributor = site.contributors | where: \'name\', page.contributor | first %%}\r\n    {%% if contributor %%}\r\n       Written by <a href=\"{{ site.baseurl }}{{ contributor.url }}\">{{ contributor.name }}</a> on {{ page.date | date_to_long_string: \"ordinal\" }}\r\n    {%% endif %%}\r\n</p>\r\n\r\n{{ content }}\r\n"
add_file ./_layouts post.html "$POST_LAYOUT" 'Post Layout'


# Adding SASS Import File
# Adding CSS
SASS_IMPORT="---\r\n---\r\n@import \"main\";"
add_file ./assets/css styles.scss "$SASS_IMPORT" 'SASS Import'

# Adding SASS
SASS=".current {\r\n    color: green;\r\n}\r\n\r\n.nav {\r\n    color: white;\r\n}\r\n\r\n.body {\r\n    background-color: black;\r\n}"
add_file ./_sass main.scss "$SASS" 'SASS'

#Downloading Privacy Policy
USER_EMAIL="$(git config user.email)"
PRIVACY_MD="---\r\ntitle: Privacy Policy\r\n---\r\n"
add_file . privacy_policy.md "$PRIVACY_MD" 'Privacy Policy'
curl -s https://raw.githubusercontent.com/WikipediaBrown/PrivacyPolicy-And-TermsAndConditions/master/Privacy%20Policy >> privacy_policy.md
sed -i '' "s/XXXXXXXXXX/$APP_NAME/g" privacy_policy.md
sed -i '' "s/YYYYYYYYYY/$USER_EMAIL/g" privacy_policy.md
sed -i '' "s/ZZZZZZZZZZ/$USER/g" privacy_policy.md

# Build Site
bundle exec jekyll build 

printf "{ \"marketingPath\": \"/$APP_NAME\",\r\n" > lemonade.json
printf "  \"privacyPolicyPath\": \"/$APP_NAME/privacy_policy.html\",\r\n" >> lemonade.json
printf "  \"supportPath\": \"/$APP_NAME/support.html\"}" >> lemonade.json

exit 0
