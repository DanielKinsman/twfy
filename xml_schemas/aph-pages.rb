#!/usr/bin/env ruby
#
# Utility for downloading and extracting the main contents body of aph.gov.au Hansard pages
# Puts the contents into a custom xml file
#
# This is the first step to create a validating xml schema for the data. This is a really good way
# of defining what the structure of the web pages is so that we can write a parser to reformat the
# data into a form that we want.

$:.unshift "#{File.dirname(__FILE__)}/../lib"

require 'mechanize_proxy'
require 'date'
require 'builder'

def parse_date(x, date)
  # Required to workaround long viewstates generated by .NET (whatever that means)
  # See http://code.whytheluckystiff.net/hpricot/ticket/13
  Hpricot.buffer_size = 400000

  agent = MechanizeProxy.new
  agent.cache_subdirectory = date.to_s

  url = "http://parlinfoweb.aph.gov.au/piweb/browse.aspx?path=Chamber%20%3E%20House%20Hansard%20%3E%20#{date.year}%20%3E%20#{date.day}%20#{Date::MONTHNAMES[date.month]}%20#{date.year}"
  begin
    page = agent.get(url)
    # HACK: Don't know why if the page isn't found a return code isn't returned. So, hacking around this.
    if page.title == "ParlInfo Web - Error"
      throw "ParlInfo Web - Error"
    end
  rescue
    puts "Could not retrieve overview page for date #{date}"
    return
  end
  puts "Retrieving pages for #{date}"
  # Structure of the page is such that we are only interested in some of the links
  page.links[30..-4].each do |link|
    parse_sub_day_page(x, agent.click(link))
  end
end

def extract_metadata_tags(page)
  # Extract metadata tags
  i = 0
  metadata = {}
  while true
    label_tag = page.search("span#dlMetadata__ctl#{i}_Label2").first
    value_tag = page.search("span#dlMetadata__ctl#{i}_Label3").first
    break if label_tag.nil? && value_tag.nil?
    metadata[label_tag.inner_text] = value_tag.inner_text.strip
    i = i + 1
  end
  metadata
end

def parse_sub_day_page(x, page)
  x.page do
    x.meta do
      extract_metadata_tags(page).each_pair do |key, value|
        x.tag!(escape_for_tag_name(key), value)
      end
    end
    tag = page.search("div#contentstart").first
    if tag
      x.content { x << tag.children.each{|x| x.to_html}.join }
    else
      puts "WARNING: Couldn't find content!"
    end
  end
end

def escape_for_tag_name(text)
  text.tr(' ', '-').downcase
end

def parse_month(x, year, month)
  date = Date.new(year, month, 1)
  to = date>>(1)
  
  while date < to
    parse_date(x, date)
    date = date + 1
  end
end

from_year, from_month = 2006, 9
to_year, to_month = 2007, 1

year, month = from_year, from_month

until year == to_year && month == to_month
  filename = "aph-pages-%i-%02i.xml" % [year, month]
  xml = File.open(filename, 'w')
  x = Builder::XmlMarkup.new(:target => xml, :indent => 1)
  x.instruct!
  
  x.hansard do
    parse_month(x, year, month)
  end
  
  # Next month
  date = Date.new(year, month, 1)
  date = date>>(1)
  year = date.year
  month = date.month
end
