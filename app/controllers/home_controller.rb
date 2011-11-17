require 'net/http'
require 'uri'

class HomeController < ApplicationController
  def index
    
  end

  def randomLatLon
    geo_svc_render('/services/tragicace/randomLatLon.php?nb=300')
  end
  
  def all_travaux
    geo_svc_render('/services/tragicace/get_all_travaux.php')
  end
  
  def get_travail_detail
    geo_svc_render('/services/tragicace/get_travail.php?id=' + params[:id].to_i.to_s)
  end
  
  def travaux_between
    geo_svc_render("/services/tragicace/get_travaux_between_two_places_v2.php?start=#{params[:from]}&end=#{params[:to]}")
  end

  def is_travaux_on_polyline
    geo_svc_render("/services/tragicace/is_travaux_on_polyline.php?encodedpoly=#{params[:encode_polyline]}")
  end
  
  def get_travaux_roads_on_polyline
    geo_svc_render("/services/tragicace/get_travaux_roads_on_polyline.php?encodedpoly=#{params[:encode_polyline]}")
  end
  
  private
    def geo_svc_url
      URI.parse('http://50.57.44.203')
    end
    
    def geo_svc_res get_url
      url = geo_svc_url
      res = Net::HTTP.start(url.host, url.port) {|http|
          http.get(get_url)
      }  
    end
    
    def geo_svc_render get_url
      render :json => geo_svc_res(get_url).body
    end
end
