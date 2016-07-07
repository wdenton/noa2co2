#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'json'
require 'nokogiri'
require 'open-uri'

csv_file = "mauna-loa-co₂.csv"
mauna_loa_uri = "http://www.esrl.noaa.gov/gmd/ccgg/trends/monthly.html"

csv_data = CSV.read(csv_file)

doc = Nokogiri::HTML(open(mauna_loa_uri))

# TODO: Fail better in case the URI can't be opened.

doc.css('//.colored_box/table/tr').each do |t|
  raw_date = t.css('td')[0].text.gsub(" ", '').strip.gsub(":", '') # There's an &nbsp; in the HTML
  current_year = Time.now().strftime("%Y")
  date = Date.parse(raw_date + " " + current_year).to_s
  next if csv_data.flatten.include?(date)

  raw_ppm = t.css('td')[1].text.strip.gsub(" ppm", '')
  ppm = case
        when /unavailable/i.match(raw_ppm) then "NA"
        else
          raw_ppm
        end
  csv_data << [date, ppm]
end

# CSV of all data
csv_data.sort{ |a, b| a[0] <=> b[0] }.each do |date, ppm|
  puts [date, ppm].to_csv
end

# JSON of the latest date
latest_data = csv_data.sort.last
latest_data_hash = { "date" => latest_data[0], "co2" => latest_data[1] }
f = File.new("mauna-loa-co₂-latest.json", "w")
f.write latest_data_hash.to_json
f.close
