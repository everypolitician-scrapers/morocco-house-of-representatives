#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'open-uri'
require 'require_all'

require_rel 'lib'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def scrape_list_page(url)
  page = MembersPage.new(response: Scraped::Request.new(url: url).response)
  page.members.each do |member|
    ScraperWiki.save_sqlite([:id, :term], member.to_h) unless member.name == 'Vaccant Poste'
  end

  scrape_list_page page.next_page if page.next_page
end

scrape_list_page('http://www.chambredesrepresentants.ma/en/members-house-representatives')
