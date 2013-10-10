require 'logger'

$logger = Logger.new('log/resque.log', 'monthly')
$logger.datetime_format = "%Y-%m-%d %H:%M:%S"

$cron = Logger.new('log/cron.log', 'monthly')
$cron.datetime_format = "%Y-%m-%d %H:%M:%S"
