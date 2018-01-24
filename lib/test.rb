require 'protobuf'
require 'google/transit/gtfs-realtime.pb'
require 'net/http'
require 'uri'
require 'pry'
require_relative "train_schedule"

TrainSchedule.new.stops do |stop|
  puts "---- Train #{stop.id} ----"
  puts stop.arrival
  puts stop.departure

  puts ""
end

