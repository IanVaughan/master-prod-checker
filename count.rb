#!/usr/bin/ruby

require 'curb'
require 'json'
require 'pry'

@stage = "production"
path_to_repo = "org/repo"
base_url = "https://github.com/#{path_to_repo}/compare/"

def last_stage_tag(path)
  full_path = File.join(Dir.home, path)
  Dir.chdir(full_path) do
    `git tag -l #{@stage}* | tail -1`.chomp
  end
end

def count_commits(path)
  full_path = File.join(Dir.home, path)
  Dir.chdir(full_path) do
    `git log #{last_stage_tag(path)}..master --pretty=oneline | wc -l`
  end
end

def get_authors(path)
  full_path = File.join(Dir.home, path)
  Dir.chdir(full_path) do
    `git log #{last_stage_tag(path)}..master --format='%aN' | sort -u`
  end
end

number_commits = count_commits(path_to_repo).chomp.strip.to_i
authors = get_authors(path_to_repo).split("\n").join(", ")
link = base_url + last_stage_tag(path_to_repo) + "...master"

if number_commits != 0
  payload = {
    channel: "#dev-talk",
    # channel: "@ian",
    username: "Production",
    text: "Master is ahead of Production by #{number_commits} commits! <#{link}|View diff>\nAuthors: #{authors}",
    icon_emoji: ":disappointed:"
  }.to_json

  url = "https://hooks.slack.com/services/#{token}"

  http = Curl.post(url, payload)
  puts http.body_str
end

#curl -X POST \
# --data-urlencode 'payload={"channel": "@ian", "username": "webhookbot", "text": "Master is ahead of Production by $count commits!", "icon_emoji": ":disappointed:"}' \
#  https://hooks.slack.com/services/$TOKEN
