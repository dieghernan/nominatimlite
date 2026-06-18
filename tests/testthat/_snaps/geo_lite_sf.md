# Returning empty query

    Code
      obj <- geo_lite_sf("xbzbzbzoa aiaia")
    Message
      No results found for query: xbzbzbzoa aiaia.

# Fail

    Code
      several <- geo_lite_sf("madrid", full_results = TRUE, nominatim_server = "https://api.jsonserver.io/")
    Message
      Cannot reach the API endpoint: https://api.jsonserver.io/search?q=madrid&format=geojson&limit=1&addressdetails=1.

