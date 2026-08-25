# geo_lite() returns a typed row when no address matches

    Code
      obj <- geo_lite("xbzbzbzoa aiaia")
    Message
      No results were found for the query: xbzbzbzoa aiaia.

---

    Code
      obj_renamed <- geo_lite("xbzbzbzoa aiaia", lat = "lata", long = "longa")
    Message
      No results were found for the query: xbzbzbzoa aiaia.

# geo_lite() returns a typed row when the API is unavailable

    Code
      several <- geo_lite("Madrid", full_results = TRUE)
    Message
      Could not reach the API endpoint: https://nominatim.openstreetmap.org/search?q=Madrid&format=jsonv2&limit=1&addressdetails=1.

