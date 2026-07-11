# Returning empty query

    Code
      obj <- geo_lite_sf("xbzbzbzoa aiaia")
    Message
      No results were found for the query: xbzbzbzoa aiaia.

# Fail

    Code
      several <- geo_lite_sf("madrid", full_results = TRUE)
    Message
      Could not reach the API endpoint: https://nominatim.openstreetmap.org/search?q=madrid&format=geojson&limit=1&addressdetails=1.

