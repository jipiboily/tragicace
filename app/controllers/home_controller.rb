require 'net/http'
require 'uri'

class HomeController < ApplicationController
  def index
    
  end

  def randomLatLon
    url = URI.parse('http://mapcoop.org')
    res = Net::HTTP.start(url.host, url.port) {|http|
        http.get('/tragicace/randomLatLon.php?nb=300')
    }

    render :json => res.body
  end
end
