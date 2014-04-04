$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'pry'
require 'rspec/autorun'
require 'enum_group_count'


RSpec.configure do |config|
  config.filter_run_excluding skip: true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true
  config.order = "random"
  # Use color in STDOUT
  config.color_enabled = true
  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

end



