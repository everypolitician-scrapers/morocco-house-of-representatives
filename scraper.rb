#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'colorize'

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

  noko.css('ul.lisitng_resultat li').each do |li|
    data = { 
      id: li.css('h2.name a/@href').text.split("/").last,
      name: li.css('h2.name').text.tidy,
      party: li.css('a.link span').first.text,
      faction: li.css('a.link span').last.text,
      image: li.css('a.figure img/@src').text,
      term: 9,
    }
    member_url = li.css('h2.name a/@href').text
    unless member_url.to_s.empty?
      data[:source] = URI.decode(URI.join(url, URI.escape(member_url)).to_s)
      data[:name__ar] = noko_for(data[:source].sub('/en/','/ar/').to_s).at_css('.top_sz_title').text.tidy
    end
    data[:name] = 'Kamal Abdel Fattah' if data[:id] == 'akamal' # No name in English version
    ScraperWiki.save_sqlite([:id, :term], data)
  end

  nexturl = noko.css('li.next a/@href').first.text rescue nil
  scrape_list URI.join(url, nexturl) if nexturl
end

scrape_list('http://www.chambredesrepresentants.ma/en/members-house-representatives')
