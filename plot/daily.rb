#!/usr/bin/env ruby

require "csv"
require "date"

# ensure file exists
if ARGV.length != 1 then
    STDERR.puts "usage: #{$0} <consolidated.csv>"
    exit 1
elsif not File.file?(ARGV[0]) then
    STDERR.puts "error: '#{ARGV[0]}' does not exist"
    exit 1
end

file = {
    :hour => {
        "washers" => File.new("washers_hour_.count", "w"),
         "dryers" => File.new( "dryers_hour_.count", "w"),

         :byday => {
             "washers" => [
                 File.new("washers_hour_0.count", "w"),
                 File.new("washers_hour_1.count", "w"),
                 File.new("washers_hour_2.count", "w"),
                 File.new("washers_hour_3.count", "w"),
                 File.new("washers_hour_4.count", "w"),
                 File.new("washers_hour_5.count", "w"),
                 File.new("washers_hour_6.count", "w")
             ],
             "dryers" => [
                 File.new("dryers_hour_0.count", "w"),
                 File.new("dryers_hour_1.count", "w"),
                 File.new("dryers_hour_2.count", "w"),
                 File.new("dryers_hour_3.count", "w"),
                 File.new("dryers_hour_4.count", "w"),
                 File.new("dryers_hour_5.count", "w"),
                 File.new("dryers_hour_6.count", "w")
             ]
         }
    },
    :weekday => {
        "washers" => File.new("washers_weekday.count", "w"),
         "dryers" => File.new( "dryers_weekday.count", "w")
    }
}

weekdays = {"washers" => Array.new(7,0), "dryers" => Array.new(7,0)}
CSV.foreach(ARGV[0], :headers => true) do |row|
    dt = DateTime.strptime(row["timestamp"], "%m/%d/%Y %r")

    # hourly count
    hour = dt.hour.to_f +
           (dt.minute.to_f/15).round*0.25

    # weekday count
    weekday = dt.strftime("%w").to_i

    # output to corresponding files
    ["washers", "dryers"].each do |type|
        row[type].to_i.times do
            # machines currently in use per hour
            file[:hour][type] << hour << "\n"
            file[:hour][:byday][type][weekday] << hour << "\n"

            # cumulative machine usage per weekday
            weekdays[type][weekday] += 1
        end
    end
end

# output weekday sums
["washers", "dryers"].each do |type|
    file[:weekday][type] << "day,count" << "\n"
    weekdays[type].each_with_index do |count,day|
        file[:weekday][type] << "#{day},#{count}" << "\n"
    end
end
