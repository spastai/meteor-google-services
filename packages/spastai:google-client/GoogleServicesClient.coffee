encodeSignedNumber = (num) ->
  sgn_num = num << 1
  sgn_num = ~(sgn_num)  if num < 0
  encodeNumber sgn_num
encodeNumber = (num) ->
  encodeString = ""
  while num >= 0x20
    encodeString += (String.fromCharCode((0x20 | (num & 0x1f)) + 63))
    num >>= 5
  encodeString += (String.fromCharCode(num + 63))
  encodeString
encodePoint = (plat, plng, lat, lng) ->
  late5 = Math.round(lat * 1e5)
  plate5 = Math.round(plat * 1e5)
  lnge5 = Math.round(lng * 1e5)
  plnge5 = Math.round(plng * 1e5)
  dlng = lnge5 - plnge5
  dlat = late5 - plate5
  encodeSignedNumber(dlat) + encodeSignedNumber(dlng)

###
Initializer class.
###
class GoogleServicesClient

  preInitQueue = new ParallelQueue(@);
  streetsMap = null;
  geocoder = new Geocoder();


  constructor: () ->
    #console.log("GoogleServicesClient constructor");

  init: ->
    #console.log("Begin loading google");
    @_loadGoogle (error,result)=>
      #console.log("End loading google:", error);
      preInitQueue.start();
      geocoder.init(new google.maps.Geocoder());

  _loadGoogle: (cb)->
    google.load "maps", "3",
      other_params: "libraries=geometry,places&sensor=false",
      callback: cb

  getGeocoder: ->
    geocoder

  afterInit: preInitQueue.wrap (cb) ->
    cb()

  ###
      Adds google address autocomomplete
  ###
  addAutocomplete: preInitQueue.wrap (input, map, cb) ->
    #di "Adding autocomplete to map", map
    autocomplete = new google.maps.places.Autocomplete(input)

    autocomplete.bindTo "bounds", map
    google.maps.event.addListener autocomplete, "place_changed", ->
      place = autocomplete.getPlace()
      cb $(input).val(), null, map unless place.geometry
      address = ""
      if place.address_components
        address = [
          place.address_components[0] and place.address_components[0].short_name or ""
          place.address_components[1] and place.address_components[1].short_name or ""
          place.address_components[2] and place.address_components[2].short_name or ""
        ].join(" ")
        cb address, place, map
      else
        cb $(input).val(), place, map

  ###
      Helper methods
  ###
  toLatLng: (location)->
    new google.maps.LatLng(location[1],location[0]);
  toLocation: (latlng)->
    [latlng.lng(), latlng.lat()];

  ###
      fromLoc = [25.312986840220695, 54.68497543662714]
      toLoc = [25.284004099999947, 54.6713496]
      encoded = encodePoints([fromLoc, toLoc]);
  ###
  encodePoints: (coords) ->
    i = 0
    plat = 0
    plng = 0
    encoded_points = ""
    i = 0
    while i < coords.length
      lat = coords[i][0]
      lng = coords[i][1]
      encoded_points += encodePoint(plat, plng, lat, lng)
      plat = lat
      plng = lng
      ++i
    # do not close polyline
    #encoded_points += encodePoint(plat, plng, coords[0][0], coords[0][1]);
    encoded_points

  decodePoints: (encoded) ->
    # array that holds the points
    points = []
    index = 0
    len = encoded.length
    lat = 0
    lng = 0
    while index < len
      b = undefined
      shift = 0
      result = 0
      loop
        b = encoded.charAt(index++).charCodeAt(0) - 63 #finds ascii and substract it by 63
        result |= (b & 0x1f) << shift
        shift += 5
        break unless b >= 0x20
      dlat = ((if (result & 1) isnt 0 then ~(result >> 1) else (result >> 1)))
      lat += dlat
      shift = 0
      result = 0
      loop
        b = encoded.charAt(index++).charCodeAt(0) - 63
        result |= (b & 0x1f) << shift
        shift += 5
        break unless b >= 0x20
      dlng = ((if (result & 1) isnt 0 then ~(result >> 1) else (result >> 1)))
      lng += dlng
      points.push [
        lat / 1e5
        lng / 1e5
      ]
    points

# Creating service to allow methods calls that will be parked
googleServices = new GoogleServicesClient

Meteor.startup =>
  #JSAPI should be loaded already
  googleServices.init();
