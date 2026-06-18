# Returning empty query

    Code
      obj <- geo_lite_struct()
    Message
      No query parameters were provided.

---

    Code
      obj <- geo_lite_struct(amenity = "xbzbzbzoa aiaia")
    Message
      No results found for the query.

---

    Code
      obj_renamed <- geo_lite_struct("xbzbzbzoa aiaia", lat = "lata", long = "longa")
    Message
      No results found for the query.

# Fail

    Code
      several <- geo_lite_struct("Madrid", full_results = TRUE, nominatim_server = "https://api.jsonserver.io/")
    Message
      Cannot reach the API endpoint: https://api.jsonserver.io/search?format=jsonv2&limit=1&addressdetails=1&amenity=Madrid.

