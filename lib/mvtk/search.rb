require 'nokogiri'
require 'open-uri'
require 'uri'
require 'themoviedb-api'

module Mvtk

  def self.themoviedb(moviename)
    result = []

    unless $conf['tmdb_key'] then
      puts "You need tu specify your api key to use this scraper"
      exit 1
    end
    unless $conf['tmdb_lang'] then
      $conf['tmdb_lang'] = 'en'
    end

    Tmdb::Api.key($conf['tmdb_key'])
    Tmdb::Api.language($conf['tmdb_lang'])

    Tmdb::Search.movie(moviename).results.first(10).each do |movie|
      msaga = nil
      myear = movie.release_date.split('-').first
      mtitle = "#{movie.title} (#{myear})"
      msaga = Tmdb::Movie.detail(movie.id).belongs_to_collection.name.gsub(" - Saga", "") if Tmdb::Movie.detail(movie.id).belongs_to_collection
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
    if $conf['scraper'] == "themoviedb" then
      result = self.themoviedb(moviename)
    elsif $conf['scraper'] == "tmdb" then
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
