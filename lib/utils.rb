class Utils
  
  def self.fixed_length(str, length)
    if str.length > length
      str = str[0..length - 1].gsub(/\s\w+\s*$/, '…')
    end

    str.ljust(length, ' ')
  end
end