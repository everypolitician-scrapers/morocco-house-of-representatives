require 'scraped'

class MembersPage < Scraped::HTML
  field :members do
    noko.css('ul.lisitng_resultat li').map do |li|
      MemberSection.new(response: response, noko: li)
    end
  end

  field :next_page do
    nexturl = noko.at_css('li.next a/@href') or return
    URI.join(url, nexturl.text)
  end
end
