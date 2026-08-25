# geo_address_lookup() returns a typed row when no object matches

    Code
      obj <- geo_address_lookup(34633854, "N")
    Message
      No results were found for the query: N34633854.

---

    Code
      obj_renamed <- geo_address_lookup(34633854, "N", lat = "lata", long = "longa")
    Message
      No results were found for the query: N34633854.

# geo_address_lookup() matches multiple IDs and drops missing ones

    Code
      several <- geo_address_lookup(vector_ids, vector_type, verbose = TRUE)
    Condition
      Warning in `geo_address_lookup()`:
      No results were found for the following OSM IDs: J146. The output contains only matched IDs.

# geo_address_lookup() returns typed rows after API failure

    Code
      several <- geo_address_lookup(vector_ids, vector_type, full_results = TRUE)
    Message
      Could not reach the API endpoint: https://nominatim.openstreetmap.org/lookup?osm_ids=R343921,N240109189&format=jsonv2&addressdetails=1.

