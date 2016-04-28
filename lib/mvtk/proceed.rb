require 'ruby-progressbar'
require 'filesize'

module Mvtk

  def self.winname(fullpath)
    charfilter = /[\<\>\:\"\|\?\*]/
    return fullpath.gsub(charfilter,'_')
  end

  def self.fulldest(source, destination)
    movie_file = "#{destination.split('/')[0][0..-8]}#{File.extname(source)}"
    movie_file = "#{destination.split('/')[0]}#{File.extname(source)}" if $conf["year_in_filename"]
    movie_file = self.winname(movie_file) if $conf["windows_name"]
    movie_dir = destination.split('/')[0]
    movie_dir = self.winname(movie_dir) if $conf["windows_name"]

    if $conf["saga_enable"] and destination.split('/')[1] then
      saga = "#{$conf["saga_prefix"]} #{destination.split('/')[1]}"
      saga = self.winname(saga) if $conf["windows_name"]
      fullpath = "#{$conf["target"]}/#{saga}/#{movie_dir}/#{movie_file}"
    else
      fullpath = "#{$conf["target"]}/#{movie_dir}/#{movie_file}"
    end

    return fullpath
  end

  def self.copy_progressbar(in_name, out_name)
    in_file = File.new(in_name, "r")
    out_file = File.new(out_name, "w")

    in_size = File.size(in_name)
    batch_bytes = ( in_size / 100 ).ceil
    total = 0
    p_bar = ProgressBar.create(:length => 80, :format => '%e |%b>%i| %p%% %t')

    buffer = in_file.sysread(batch_bytes)
    while total < in_size do
      out_file.syswrite(buffer)
      p_bar.progress += 1 unless p_bar.progress >= 100
      total += batch_bytes
      if (in_size - total) < batch_bytes
        batch_bytes = (in_size - total)
      end
      buffer = in_file.sysread(batch_bytes)
    end
    p_bar.finish
  end

  def self.copy(source, destination)
    finalpath = self.fulldest(source, destination)
    puts "Source => #{File::basename(source)}"
    puts "Target => #{finalpath.sub($conf["target"]+"/","")}"
    puts "Size   => #{Filesize.from(File.size(source).to_s + "B").pretty}"
    puts ""

    FileUtils.mkdir_p File.dirname(finalpath) unless File.directory?(File.dirname(finalpath))
    self.copy_progressbar(source, finalpath)
  end
end
