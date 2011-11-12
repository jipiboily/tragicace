window.tragicace = {}
window.tragicace.list = {}
window.tragicace.map = {}


window.map;
(window.tragicace = ->
	tragicace.get_travaux_between = (from, to) ->
		post_data = {from: from, to: to}
		$.ajax
			data: post_data
			url: "geo_svc/travaux_between"
			dataType: "json"
			error: (data) ->
				alert data.responseText
			success: (data) ->
				if(data.status != undefined)
					alert "Erreur Google Map: " + data.status
				else
					if data[0] != undefined
						tragicace.map.set_icon_on_path data
						map = tragicace.map.show_points data
						path =  google.maps.geometry.encoding.decodePath data.encodedPolyline
						tragicace.map.draw_path map, path
						bounds = tragicace.map.get_bounds path
						map.fitBounds(bounds)
						tragicace.list.populate data
)()

(window.tragicace.list = ->
	tragicace.list.populate = (points) ->
    i = 0
    content = ""
    point = points[i]
    while point != undefined && point.id != undefined
      endroit = if point.endroit == null then "???" else point.endroit
      content += "<div>"
      content += "<h1>" + endroit + "</h1>"
      content += "<h3>Du " + point.date_debut + " au " + point.date_fin + "</h3>"
      content += "<p>"
      content += "<br/><strong>Arrondissement: </strong>" + point.arrondissement
      content += "<br/><strong>Emplacement: </strong>" + point.emplacement
      content += "<br/><strong>Restriction: </strong>" + point.restriction
      content += "<br/><strong>Nature des travaux: </strong>" + point.nature_travaux
      content += "</p>"
      content += "</div>"
      i++
      point = points[i]
    $("#liste").html content
)()
(tragicace.map = ->
  tragicace.map.init = ->
    center = new google.maps.LatLng(46.815876, -71.28156)
    window.map = new google.maps.Map(document.getElementById("map"),
      zoom: 11
      center: center
      mapTypeId: google.maps.MapTypeId.ROADMAP
    )
    $.ajax
      url: "geo_svc/all_travaux"
      dataType: "json"
      success: (points) ->
        tragicace.map.show_points points
        tragicace.list.populate points

  tragicace.map.set_icon_on_path = (points) ->
    i = 0
    point = points[i]
    while point != undefined && point.id != undefined
      google.maps.event.trigger map, "bidon_set_icon", point.id, 'images/closedroad.png'
      i++
      point = points[i]

  tragicace.map.get_bounds = (path) ->
    minLatitude = null
    maxLatitude = null
    minLongitude = null
    maxLongitude = null
    i=0

    while i < path.length
      point = path[i]
      i++
      if (point.Oa isnt 180.0) or (point.Pa isnt 180.0)
        minLatitude = point.Oa  if (not (minLatitude?)) or (point.Oa < minLatitude)
        maxLatitude = point.Oa  if (not (maxLatitude?)) or (point.Oa > maxLatitude)
        minLongitude = point.Pa  if (not (minLongitude?)) or (point.Pa < minLongitude)
        maxLongitude = point.Pa  if (not (maxLongitude?)) or (point.Pa > maxLongitude)

    sw = new google.maps.LatLng(minLatitude, minLongitude)
    ne = new google.maps.LatLng(maxLatitude, maxLongitude)
    new google.maps.LatLngBounds(sw, ne)

  tragicace.map.draw_path = (map, path) ->
    polyline = new google.maps.Polyline(
      path: path
      strokeColor: "#FF0000"
      strokeOpacity: 1.0
      strokeWeight: 2
    )

    polyline.setMap map

  tragicace.map.show_points = (points) ->
    markers = []
    i = 0
    point = points[i]
    while point != undefined && point.id != undefined
      latLng = new google.maps.LatLng(point.lat, point.lon)
      marker = new google.maps.Marker(
        position: latLng
        map: map
        point_id: point.id
      )
      tragicace.map.bind_marker_event marker, latLng, map, point.id
      marker.setIcon('images/closedroad_default.png')
      markers.push marker
      i++
      point = points[i]
    markerCluster = new MarkerClusterer(map, markers)
    map

  tragicace.map.bind_marker_event = (marker, position, map, id) ->
    infowindow = tragicace.map.get_info_window_instance(position)
    google.maps.event.addListener map, "close_all_info_window", ->
      infowindow.close()

    google.maps.event.addListener map, "reset_icon", ->
      marker.setIcon('images/closedroad_default.png')

    google.maps.event.addListener map, "bidon_set_icon", (id, icon) ->
      if id == marker.point_id
        marker.setIcon(icon)

    google.maps.event.addListener marker, "click", ->
      google.maps.event.trigger map, "close_all_info_window"
      tragicace.map.afficher_details_du_travail id, infowindow, map, marker

  tragicace.map.get_info_window_instance = (position) ->
    infowindow = new google.maps.InfoWindow(
      content: "..."
      position: position
      size: new google.maps.Size(50, 50)
    )
    infowindow

  tragicace.map.afficher_details_du_travail = (id, infowindow, map, marker) ->
    $.ajax
      url: "geo_svc/travail_detail/" + id
      dataType: "json"
      success: (data) ->
        data = data[0]
        content = "<h1>" + data.endroit + "</h1>"
        content += "<h3>Du " + data.date_debut + " au " + data.date_fin + "</h3>"
        content += "<p>"
        content += "<br/><strong>Arrondissement: </strong>" + data.arrondissement
        content += "<br/><strong>Emplacement: </strong>" + data.emplacement
        content += "<br/><strong>Restriction: </strong>" + data.restriction
        content += "<br/><strong>Nature des travaux: </strong>" + data.nature_travaux
        content += "</p>"
        infowindow.content = content
        infowindow.open map, marker
)()

$(document).ready ->
	google.maps.event.addDomListener window, "load", tragicace.map.init()
