  # coding: UTF-8

class String
  def self.random(length=10)
  ('a'..'z').sort_by {rand}[0,length].join
  end

  def normalize
    str = self.downcase
    return '' if str.blank?
    n = str.force_encoding("UTF-8")
    n.gsub!(/[àáâãäåāă]/,   'a')
    n.gsub!(/æ/,            'ae')
    n.gsub!(/[ďđ]/,          'd')
    n.gsub!(/[çćčĉċ]/,       'c')
    n.gsub!(/[èéêëēęěĕė]/,   'e')
    n.gsub!(/ƒ/,             'f')
    n.gsub!(/[ĝğġģ]/,        'g')
    n.gsub!(/[ĥħ]/,          'h')
    n.gsub!(/[ììíîïīĩĭ]/,    'i')
    n.gsub!(/[įıĳĵ]/,        'j')
    n.gsub!(/[ķĸ]/,          'k')
    n.gsub!(/[łľĺļŀ]/,       'l')
    n.gsub!(/[ñńňņŉŋ]/,      'n')
    n.gsub!(/[òóôõöøōőŏŏ]/,  'o')
    n.gsub!(/œ/,            'oe')
    n.gsub!(/ą/,             'q')
    n.gsub!(/[ŕřŗ]/,         'r')
    n.gsub!(/[śšşŝș]/,       's')
    n.gsub!(/[ťţŧț]/,        't')
    n.gsub!(/[ùúûüūůűŭũų]/,  'u')
    n.gsub!(/ŵ/,             'w')
    n.gsub!(/[ýÿŷ]/,         'y')
    n.gsub!(/[žżź]/,         'z')
    n.gsub!(/[ÀÁÂÃÄÅĀĂ]/i,    'A')
    n.gsub!(/Æ/i,            'AE')
    n.gsub!(/[ĎĐ]/i,          'D')
    n.gsub!(/[ÇĆČĈĊ]/i,       'C')
    n.gsub!(/[ÈÉÊËĒĘĚĔĖ]/i,   'E')
    n.gsub!(/Ƒ/i,             'F')
    n.gsub!(/[ĜĞĠĢ]/i,        'G')
    n.gsub!(/[ĤĦ]/i,          'H')
    n.gsub!(/[ÌÌÍÎÏĪĨĬ]/i,    'I')
    n.gsub!(/[ĲĴ]/i,          'J')
    n.gsub!(/[Ķĸ]/i,          'J')
    n.gsub!(/[ŁĽĹĻĿ]/i,       'L')
    n.gsub!(/[ÑŃŇŅŉŊ]/i,      'M')
    n.gsub!(/[ÒÓÔÕÖØŌŐŎŎ]/i,  'N')
    n.gsub!(/Œ/i,            'OE')
    n.gsub!(/Ą/i,             'Q')
    n.gsub!(/[ŔŘŖ]/i,         'R')
    n.gsub!(/[ŚŠŞŜȘ]/i,       'S')
    n.gsub!(/[ŤŢŦȚ]/i,        'T')
    n.gsub!(/[ÙÚÛÜŪŮŰŬŨŲ]/i,  'U')
    n.gsub!(/Ŵ/i,             'W')
    n.gsub!(/[ÝŸŶ]/i,         'Y')
    n.gsub!(/[ŽŻŹ]/i,         'Z')
    n
  end

  def sanitize
   return if self.blank?
   self.gsub(/<[^>]+>/m,'').normalize.downcase.gsub(/&.+?;/,'-').
        gsub(/[^a-z0-9 _-]/,'-').strip.gsub(/\s+/,'-').gsub(/-+/,'-').
        gsub(/-/,' ').strip.gsub(/ /,'-').gsub(/-/,'_')
  end

  def strip_tags
    self.gsub(/<[^>]+>/m,'').strip
  end

  def convert_to_db_type
    if CartoDB::TYPES.keys.include?(self.downcase)
      if self.downcase == "number"
        "double precision"
      else
        CartoDB::TYPES[self.downcase].first
      end
    else
      self.downcase
    end
  end

  # {"integer"=>:number, "real"=>:number, "varchar"=>:string, "text"=>:string, "timestamp"=>:date, "boolean"=>:boolean}
  def convert_to_cartodb_type
    inverse_types = CartoDB::TYPES.invert.inject({}){ |h, e| e.first.each{ |k| h[k] = e.last }; h}
    if inverse_types.keys.include?(self.downcase)
      inverse_types[self.downcase]
    else
      inverse_types.keys.select{ |t| !t.is_a?(String) }.each do |re|
        if self.downcase.match(re)
          return inverse_types[re]
        end
      end
      self.downcase
    end
  end

  def sanitize_sql
    self.gsub(/\\/, '\&\&').gsub(/'/, "''")
  end

  def host
    self.split('/')[2]
  end

  def sanitize_column_name
    temporal_name = self.sanitize
    if temporal_name !~ /^[a-zA-Z_]/ || CartoDB::POSTGRESQL_RESERVED_WORDS.include?(self.upcase)
      return '_' + temporal_name
    else
      temporal_name
    end
  end

end