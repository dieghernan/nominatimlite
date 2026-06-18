# Returning empty query

    Code
      obj <- geo_address_lookup(34633854, "N")
    Message
      No results were found for query: N34633854.

---

    Code
      obj_renamed <- geo_address_lookup(34633854, "N", lat = "lata", long = "longa")
    Message
      No results were found for query: N34633854.

# Handle several

    Code
      several <- geo_address_lookup(vector_ids, vector_type, verbose = TRUE)
    Condition
      Warning in `geo_address_lookup()`:
      No results were found for some OSM IDs. Check the output.

# Fail

    Code
      several <- geo_address_lookup(vector_ids, vector_type, full_results = TRUE,
        nominatim_server = "https://api.jsonserver.io/")
    Message
      Could not reach the API endpoint: https://api.jsonserver.io/lookup?osm_ids=R343921,N240109189&format=jsonv2&addressdetails=1.

