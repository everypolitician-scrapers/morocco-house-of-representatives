require 'scraped'

class MembersPage < Scraped::HTML
  field :members do
    noko.css('ul.lisitng_resultat li').map do |li|
      MemberSection.new(response: response, noko: li)
    end
  end
end
