# Returning Empty

    Code
      obj <- geo_address_lookup_sf(34633854, "N")
    Message
      No results found for query: N34633854.

# Handle several

    Code
      several <- geo_address_lookup_sf(vector_ids, vector_type, verbose = TRUE)
    Condition
      Warning in `geo_address_lookup_sf()`:
      Some OSM IDs returned no results. Check the output.

# Fail

    Code
      several <- geo_address_lookup_sf(vector_ids, vector_type, full_results = TRUE,
        nominatim_server = "https://api.jsonserver.io/")
    Message
      Cannot reach the API endpoint: https://api.jsonserver.io/lookup?osm_ids=R343921,N240109189&format=geojson&addressdetails=1.

