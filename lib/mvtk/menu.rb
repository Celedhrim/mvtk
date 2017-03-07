require 'tty-prompt'
require 'streamio-ffmpeg'

module Mvtk

  def self.mediamenu
    prompt = TTY::Prompt.new
    choices = self.listfiles
    choice = prompt.select("Movie to copy ?", choices, per_page: 25)
  end

  def self.listfiles
    result = Hash.new
    Dir.glob("#{$conf['source']}/**/*.{mkv,mp4,avi}", File::FNM_CASEFOLD).sort.each do |mfile|
      begin
        movie = FFMPEG::Movie.new(mfile)
        next if movie.duration.round/60.to_i < $conf['min_movie_time']
      rescue
      end
      result[File::basename(mfile)] = mfile
    end
    result["[Proceed]"] = "proceed"
    result["[Quit]"] = "quit"
    return result
  end

  def self.manualscrap
    prompt = TTY::Prompt.new
    answer = prompt.ask("Enter your search terms : ")
    return self.choosescrap(answer)
  end

  def self.choosescrap(mfile)
    mysearch = File::basename(self::NameCleaner.new(mfile).clean)
    search = []
    while search.empty? and mysearch != nil
      search = self.search(mysearch)
      if search.empty? then
        mysearch = mysearch[/(.*)\s/,1]
      end
    end

    if search.empty? then
      return self.manualscrap
    end

    foutput = search.collect { |x| x.split('/')[0]}
    foutput.push("[Manual] (Do a manual search)")
    foutput.push("[Return] (Back to file menu)")
    prompt2 = TTY::Prompt.new
    choice = prompt2.select("Your choice ?", foutput, per_page: 25)
    if choice == "[Manual] (Do a manual search)" then
      return self.manualscrap
    end
    result = search.keep_if { |v| v.start_with?(choice) }
    return result.first
  end
end
