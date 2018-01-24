require 'protobuf'
require 'google/transit/gtfs-realtime.pb'
require 'net/http'
require 'uri'
require 'dotenv/load'

class TrainSchedule
  API_KEY = ENV['MTA_API_KEY']
  FEED_URL_PROTO = "http://datamine.mta.info/mta_esi.php?key=#{API_KEY}&feed_id=2"
  FEED_URL_JSON =  "https://mnorth.prod.acquia-sites.com/wse/LIRR/gtfsrt/realtime/#{API_KEY}/json"

  attr_reader :feed

  def initialize
    @feed = Transit_realtime::FeedMessage.decode(
      Net::HTTP.get(URI.parse(FEED_URL_PROTO))
    )
  end

  def stops
    feed.entity.each do |ent|
      object_to_yield = []

      data = ent.to_hash
      trip_data = data[:trip_update]

      unless trip_data.nil?
        stop_times = trip_data[:stop_time_update]

        object_to_yield = stop_times.map do |stop|
          arrival = stop.dig(:arrival, :time) rescue nil
          departure = stop.dig(:departure, :time) rescue nil
          stop_id = stop[:stop_id]

          arrival = Time.at(arrival).strftime("%I:%M %p") if arrival
          departure = Time.at(departure).strftime("%I:%M %p") if departure

          [arrival, departure, stop_id]
        end
      end

      object_to_yield.each {|o| yield TrainStop.new(*o) }
    end
  end
end

TrainStop = Struct.new(:arrival, :departure, :id) do
  def direction
    # based on N or S in the stop_id
    # convert N/S to East/West for L
  end
end
