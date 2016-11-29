require 'scraped'

class MemberSection < Scraped::HTML
  field :id do
    noko.css('h2.name a/@href').text.split("/").last
  end

  field :name do
    member_name
  end

  field :party do
    noko.css('a.link span').first.text
  end

  field :faction do
    noko.css('a.link span').last.text
  end

  field :source do
    URI.join(url, noko.css('h2.name a/@href').text).to_s
  end

  field :image do
    noko.css('a.figure img/@src').text
  end

  field :term do
    9
  end

  private

  def member_name
    return 'Kamal Abdel Fattah' if id == 'akamal' # No name in English version
    noko.css('h2.name').text.tidy
  end
end
