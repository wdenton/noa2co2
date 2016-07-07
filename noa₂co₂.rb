#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'json'
require 'nokogiri'
require 'open-uri'

csv_file = "mauna-loa-co₂.csv"
json_file = "mauna-loa-co₂-latest.json"

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

csv_data = csv_data.sort # No special sorting needed, it seems, it just works.

# Update CSV with all the data
File.open(csv_file, "w") do |file|
  csv_data.each do |row|
    file.write row.to_csv
  end
end

# JSON of the last numerical reading
index = - 1
while csv_data[index][1] == "NA"
  index = index - 1
end
latest_data_hash = { "date" => csv_data[index][0], "co2" =>  csv_data[index][1] }
File.open(json_file, "w") do |file|
  file.write latest_data_hash.to_json
end
