#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'nokogiri'
require 'open-uri'

csv_file = "noaa-co₂.csv"

csv_data = CSV.read(csv_file)

doc = Nokogiri::HTML(open("http://www.esrl.noaa.gov/gmd/ccgg/trends/monthly.html"))
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

csv_data.each do |date, ppm|
  puts [date, ppm].to_csv
end
