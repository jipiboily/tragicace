tragicace = {}
tragicace.map = {}
(tragicace = ->
)()
(tragicace.map = ->
  tragicace.map.init = ->
    $.ajax
      url: "geo_svc/all_travaux"
      dataType: "json"
      success: (points) ->
        tragicace.map.show_points points

  tragicace.map.show_points = (points) ->
    center = new google.maps.LatLng(46.815876, -71.28156)
    map = new google.maps.Map(document.getElementById("map"),
      zoom: 10
      center: center
      mapTypeId: google.maps.MapTypeId.ROADMAP
    )
    markers = []
    i = 0

    while i < points.length
      point = points[i]
      latLng = new google.maps.LatLng(point.lat, point.lon)
      marker = new google.maps.Marker(
        position: latLng
        map: map
      )
      tragicace.map.bind_marker_event marker, latLng, map, point.id
      markers.push marker
      i++
    markerCluster = new MarkerClusterer(map, markers)

  tragicace.map.bind_marker_event = (marker, position, map, id) ->
    infowindow = tragicace.map.get_info_window_instance(position)
    google.maps.event.addListener map, "close_all_info_window", ->
      infowindow.close()

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

google.maps.event.addDomListener window, "load", tragicace.map.init()