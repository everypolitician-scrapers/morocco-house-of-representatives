# frozen_string_literal: true
require 'scraped'

class MemberPage < Scraped::HTML
  field :name do
    noko.at_css('.top_sz_title').text.tidy
  end
end
