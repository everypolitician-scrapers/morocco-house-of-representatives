#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'
require 'require_all'

require_rel 'lib'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
  # Nokogiri::HTML(open(url).read, nil, 'utf-8')
end

def scrape_list(url)
  noko = noko_for(url)
  puts url.to_s.yellow

  MembersPage.new(response: Scraped::Request.new(url: url).response(decorators: [AbsoluteLinks]), noko: noko)
             .members
             .each do |member|
                ScraperWiki.save_sqlite([:id, :term], member.to_h) unless member.name == 'Vaccant Poste'
              end

  nexturl = noko.css('li.next a/@href').first.text rescue nil
  scrape_list URI.join(url, nexturl) if nexturl
end

scrape_list('http://www.chambredesrepresentants.ma/en/members-house-representatives')
