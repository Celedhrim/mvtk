require 'nokogiri'
require 'open-uri'
require 'uri'

module Mvtk

  def self.mediapassion(moviename)
    result = []
    searchresult = Nokogiri::HTML(open("http://passion-xbmc.org/scraper/ajax.php?Ajax=Search&Title=#{URI.escape(moviename.tr(' ', '+'))}"), nil , 'UTF-8')
    searchresult.css('a').take(10).each do |link|
      mtitle = link.content.tr('[', '(').tr(']', ')')
      detailpage = Nokogiri::HTML(open("http://passion-xbmc.org/scraper/#{link['href']}"))
      msaga = detailpage.css("#sagaWrapper").css('p').text[5..-1]
      unless msaga.nil? then
        result.push("#{mtitle}/#{msaga.rstrip.lstrip}")
      else
        result.push("#{mtitle}/")
      end
    end
    return result
  end

  def self.themoviedb(moviename)
    result = []
    searchresult = Nokogiri::HTML(open("https://www.themoviedb.org/search?query=#{URI.escape(moviename.tr(' ', '+'))}"), nil , 'UTF-8')
    searchresult.css("div.info").take(10).each do |link|
      msage = nil
      myear = link.css('span.release_date').text.split("-")[0].strip
      mtitle = "#{link.css('a').first.content} (#{myear})"
      detailpage = Nokogiri::HTML(open("https://www.themoviedb.org#{link.css('a').first['href']}"))
      msaga = detailpage.at('p:contains("Part of the")').css('a').text if detailpage.at('p:contains("Part of the")')
      unless msaga.nil? then
        result.push("#{mtitle}/#{msaga}")
      else
        result.push("#{mtitle}/")
      end
    end
    return result
  end

  def self.search (moviename)
    if $conf['scraper'] == "mediapassion" then
      result = self.mediapassion(moviename)
    elsif $conf['scraper'] == "themoviedb" then
      result = self.themoviedb(moviename)
    else
      puts "Sorry #{$conf['scraper']} is not a valid scraper"
      exit 1
    end
    return result
  end

end
