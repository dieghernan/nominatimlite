# Returning empty query

    Code
      obj <- geo_lite_struct_sf()
    Message
      No search parameters were provided.

---

    Code
      obj <- geo_lite_struct_sf("xbzbzbzoa aiaia")
    Message
      No results were found for the query.

# Data format

    Code
      test <- geo_lite_struct_sf(city = "Madrid", points_only = FALSE, limit = 100)
    Message
      Nominatim returns at most 50 results per query. `limit` has been set to 50.

# Fail

    Code
      several <- geo_lite_struct_sf("madrid", full_results = TRUE, nominatim_server = "https://api.jsonserver.io/")
    Message
      Could not reach the API endpoint: https://api.jsonserver.io/search?format=geojson&limit=1&addressdetails=1&amenity=madrid.

