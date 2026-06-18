# Returning empty query

    Code
      obj <- geo_lite("xbzbzbzoa aiaia")
    Message
      No results were found for query: xbzbzbzoa aiaia.

---

    Code
      obj_renamed <- geo_lite("xbzbzbzoa aiaia", lat = "lata", long = "longa")
    Message
      No results were found for query: xbzbzbzoa aiaia.

# Fail

    Code
      several <- geo_lite("Madrid", full_results = TRUE, nominatim_server = "https://api.jsonserver.io/")
    Message
      Could not reach the API endpoint: https://api.jsonserver.io/search?q=Madrid&format=jsonv2&limit=1&addressdetails=1.

