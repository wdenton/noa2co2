#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "http"
require "json"
require "nokogiri"

csv_file = "mauna-loa.csv"
json_file = "mauna-loa-latest.json"

# mauna_loa_uri = "https://www.esrl.noaa.gov/gmd/ccgg/trends/monthly.html"
mauna_loa_uri = "https://gml.noaa.gov/ccgg/trends/monthly.html"

csv_data = CSV.read(csv_file)

mauna_loa_html = HTTP.get(mauna_loa_uri)
doc = Nokogiri::HTML(mauna_loa_html.to_s)

# TODO: Fail better in case the URI can't be opened.

doc.css("//.colored_box/table/tr").each do |t|
  raw_date = t.css("td")[0].text.delete(" ").strip.delete(":")
  # That's an &nbsp; ... it's in the HTML but we don't want it.
  year = Time.now.strftime("%Y")
  date = Date.parse("#{raw_date} #{year}")
  if date > Date.today
    # If we see just "December 30" in early January of 2017,
    # we need to subtract a year so December 30 is in 2016.
    # Need to convert year to an integer to subtract 1, then
    # back to a string.
    date = Date.parse("#{raw_date} #{year.to_i - 1}")
  end
  date = date.to_s
  # next if csv_data.flatten.include?(date)

  raw_ppm = t.css("td")[1].text.strip.gsub(" ppm", "")

  ppm = if /unavailable/i =~ raw_ppm
        then "NA"
        else
          raw_ppm
        end

  # It happens that data for a day is corrected later.
  # Sometimes a number is changed, and sometimes an NA
  # is corrected to a number.
  # The easiest way to handle this is that if the data exists
  # in the data then throw it out and use what is in the table.
  date_index = csv_data.index { |x| x[0] == date }
  csv_data.delete_at(date_index) if date_index
  # This was to delete a date's data only if it used to say NA
  # but now does not say NA.
  # && csv_data.at(date_index)[1] == "NA" && raw_ppm != "NA"

  csv_data << [date, ppm]
end

# If updates are done daily, this is unncessary. In fact, since it's
# dates and they can be handled as dates in any analysis, it's really
# unnecessary, but just to keep things tidy and human-readable in all
# cases, let's sort. No special sorting needed, it just works.
csv_data = csv_data.sort

File.open(csv_file, "w") do |file|
  csv_data.each do |row|
    file.write row.to_csv
  end
end

# JSON is just the last numerical reading
index = -1
index -= 1 while csv_data[index][1] == "NA"

latest_data = { "date" => csv_data[index][0], "co2" => csv_data[index][1] }

File.write(json_file, latest_data.to_json)
