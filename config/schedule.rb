job_type :rake,    "cd :path && RAILS_ENV=:environment bundle exec usr/local/bin/rake :task --silent :output"

job_type :runner,  "cd :path && /usr/local/bin/ruby script/rails runner -e :environment ':task' :output"
env :PATH, '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin'


set :output, {:error => 'log/cron_error.log', :standard => 'log/cron_log.log'}
env :MAILTO, 'tute@mynew.tv'
 

every 15.minutes do
  runner "Resque.enqueue(PublishPostJob)" 
end

every 1.hours do
  runner "QueryCleanupJob.perform"
  runner "SearchCleanupJob.perform"  
end

every 4.hours do
  runner "SearchRecommendationsJob.perform"
  runner "Resque.enqueue(CheckVideosStatusJob)" #TEMPORAL
end

every 6.hours do
  runner "Resque.enqueue(ToplistJob)"
  rake "thinking_sphinx:reindex"  
end

every 8.hours do
  runner "CrawlMostLikedPhrasesJob.perform"
end

every 12.hours do
  runner "Resque.enqueue(CrawlDailyJob)"
  rake "thinking_sphinx:restart"
end


every 1.day, :at => '4:30am' do
    rake "thinking_sphinx:rebuild"
    runner "Resque.enqueue(CompressPhraseScoresJob)"
end

