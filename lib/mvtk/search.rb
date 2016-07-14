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
      msaga = nil
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

  def self.mpdb(moviename)
    result = []
    searchresult = Nokogiri::HTML(open("http://mpdb.tv/site/search?q=#{URI.escape(moviename.tr(' ', '+'))}"), nil , 'UTF-8')
    searchresult.css('div.item a').take(10).each do |link|
      msaga = nil
      mtitle = link.css('h4.list-group-item-heading').text.strip
      detailpage = Nokogiri::HTML(open("http://mpdb.tv#{link['href']}"))
      begin
        havehref = detailpage.css('p a').first['href']
        havesaga = true
        havesaga = nil unless havehref.start_with?('/saga/')
      rescue
        havesaga = nil
      end
      msaga = detailpage.css('p').first.text.strip if havesaga
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
    elsif $conf['scraper'] == "mpdb" then
      result = self.mpdb(moviename)
    else
      puts "Sorry #{$conf['scraper']} is not a valid scraper"
      exit 1
    end
    return result
  end

end
