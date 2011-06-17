class Shrinker
  require "open-uri"
  require "net/http"
  require "erb"
  include ERB::Util
  
  IS_GD_URL = "http://is.gd/api.php?longurl="

  def self.shrink(url)
    unless url.match(/^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix)
      raise ShrinkError.new("Supplied URL was not formatted as a URL.  Please format it as http://www.domain.com/")
    end

    encoded_url = IS_GD_URL + url_encode(url)

    begin
      shrunken_url = OpenURI.open_uri(encoded_url, 'r') { |file| file.read }
    rescue OpenURI::HTTPError => e
      shrunken_url = nil
      raise ShrinkError.new("No URL was returned from is.gd.  There was an error accessing the service.")
    rescue Exception => e
      raise ShrinkError.new("No URL was returned from is.gd.  #{e.message} #{e.backtrace}")
    end

    # We might not get an exception, but the service doesn't return a URL.
    unless shrunken_url == nil || shrunken_url == ""
      return shrunken_url
    else
      raise ShrinkError.new("No URL was returned from is.gd")
    end
  end

  def self.expand(url)
    url_obj = URI.parse(url)
    unless url.match(/^(http|https):\/\/is.gd\/[a-z0-9]*/)
      raise ShrinkError.new("Supplied URL was not an is.gd URL.  Please use a valid is.gd URL.")
    end

    expanded_url = nil

    Net::HTTP.start(url_obj.host, url_obj.port) do |http|
      response = http.request_head(url_obj.request_uri)

      if response.kind_of?(Net::HTTPMovedPermanently)
        expanded_url = response["location"]
      else
        raise ShrinkError.new("Supplied URL was not in the is.gd system.  Please us a valid is.gd URL.")
      end
    end

    return expanded_url
  end
end

class ShrinkError < StandardError
end