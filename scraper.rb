#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

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
  page.members.reject { |m| m.name == 'Vaccant Poste' }.each do |member|
    arabic_member_page = MemberPage.new(
      response: Scraped::Request.new(
        url: member.source.sub('/en/', '/ar/')
      ).response
    )
    data = member.to_h.merge(name__ar: arabic_member_page.name)
    ScraperWiki.save_sqlite(%i(id term), data)
  end

  scrape_list_page page.next_page if page.next_page
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list_page('http://www.chambredesrepresentants.ma/en/members-house-representatives')
