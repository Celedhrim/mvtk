module Mvtk

  class NameCleaner
    attr_accessor :raw_name, :clean_name

    def initialize(raw_name)
      @raw_name = raw_name
      @clean_name = raw_name
    end

    def clean_punctuation
      punctuation_to_remove = /[\.\[\]\(\)-]/
      @clean_name = @clean_name.gsub(punctuation_to_remove, " ")
    end

    def remove_release_year
      @clean_name = @clean_name.gsub(release_year.to_s, "")
    end

    ["filetype"].each do |method|
      define_method "remove_#{method}" do
        extractions = Array(self.send(method))
        extractions.each do |extraction|
          @clean_name = @clean_name.gsub(extraction, "")
        end
      end
    end

    ["video_types"].each do |method|
      remove_method_name = :"remove_#{method}"
      terms_method_name = :"#{method}_terms"

      define_method remove_method_name do
        extraction_indices = Array(self.send(method))
        extraction_indices.each do |extraction_index|
          term = NameCleaner.send(terms_method_name).at(extraction_index)
          @clean_name = @clean_name.gsub(Regexp.new(term[:name], term[:modifier]), "")
        end
      end
    end

    def remove_whitespace
      @clean_name = @clean_name.gsub(/\s+/, " ")
      @clean_name = @clean_name.strip
    end

    def clean
      remove_release_year
      remove_video_types
      remove_filetype
      clean_punctuation
      remove_whitespace
    end

    def release_year
      year_matches = @raw_name.scan(/(\d{4})/).flatten
      two_years_from_now= Time.now.strftime("%Y").to_i + 2

      year_matches = year_matches.map { |year_match|
        year = year_match.to_i
      }.select { |year_match|
        (1895..two_years_from_now).include? year_match
      }

      year_matches.first if year_matches.size == 1
    end

    def self.video_types_terms
      [
        { :name => "dvdrip", :modifier => Regexp::IGNORECASE },
        { :name => "xvid", :modifier => Regexp::IGNORECASE },
        { :name => "720p", :modifier => Regexp::IGNORECASE },
        { :name => "1080p", :modifier => Regexp::IGNORECASE },
        { :name => "x264", :modifier => Regexp::IGNORECASE },
        { :name => "bluray", :modifier => Regexp::IGNORECASE },
        { :name => "bdrip", :modifier => Regexp::IGNORECASE },
        { :name => "multi", :modifier => Regexp::IGNORECASE },
        { :name => "repack", :modifier => Regexp::IGNORECASE },
        { :name => "aac", :modifier => Regexp::IGNORECASE },
        { :name => "5.1", :modifier => Regexp::IGNORECASE },
        { :name => "ac3", :modifier => Regexp::IGNORECASE },
        { :name => "DTS", :modifier => Regexp::IGNORECASE },
        { :name => "truefrench", :modifier => Regexp::IGNORECASE },
        { :name => "french", :modifier => Regexp::IGNORECASE },
        { :name => "www.cpasbien.cm", :modifier => Regexp::IGNORECASE },
        { :name => "Torrent9.info", :modifier => Regexp::IGNORECASE }
      ]
    end

    def video_types
      video_type = []

      NameCleaner.video_types_terms.each_with_index do |term, index|
        regexp = term[:name]
        modifier = term[:modifier]
        video_type << index if @raw_name.match Regexp.new regexp, modifier # case insensitive
      end

      video_type
    end

    def filetype
      filetypes = ["avi", "mp4", "mkv"]
      filetypes.find do |filetype|
        regexp = Regexp.new "\.#{filetype}"
        @raw_name.match regexp
      end
    end
  end

end
