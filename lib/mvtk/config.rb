require "iniparse"

module Mvtk

  # create the config
  def self.confcreate (conffilepath)
    doc = IniParse.gen do |doc|
      doc.section("mvtk") do |mvtk|
        mvtk.option("scraper","mediapassion")
        mvtk.option("saga_enable","true")
        mvtk.option("saga_prefix","1-Saga")
        mvtk.option("source","/home/torrent/finish.seedbox")
        mvtk.option("target","/home/data/Videos/Films")
        mvtk.option("windows_name","true")
        mvtk.option("min_movie_time","60")
        mvtk.option("year_in_filename","false")
        mvtk.option("move_files","false")
      end
    end
    doc.save(conffilepath)
    puts "Conf file created : #{conffilepath}"
    puts "Edit to fit your need then run again"
    #Add exit
    exit
  end

  # Read the config
  def self.confread (conffilepath)
    confcreate(conffilepath) unless File.exists?(conffilepath)
    IniParse.parse( File.read(conffilepath) )['mvtk']
  end

end
