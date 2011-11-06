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
  
  def all_travaux
    url = URI.parse('http://mapcoop.org')
    res = Net::HTTP.start(url.host, url.port) {|http|
        http.get('/tragicace/get_all_travaux.php')
    }

    render :json => res.body    
  end
  
  def get_travail_detail
    url = URI.parse('http://mapcoop.org')
    res = Net::HTTP.start(url.host, url.port) {|http|
        http.get('/tragicace/get_travail.php?id=' + params[:id].to_i.to_s)
    }
    
    render :json => res.body    
  end
end
