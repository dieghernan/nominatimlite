# geo_lite_struct_sf() handles missing and unmatched components

    Code
      obj <- geo_lite_struct_sf()
    Message
      No search parameters were provided.

---

    Code
      obj <- geo_lite_struct_sf("xbzbzbzoa aiaia")
    Message
      No results were found for the query.

# geo_lite_struct_sf() returns point and polygon geometries

    Code
      test <- geo_lite_struct_sf(city = "Madrid", points_only = FALSE, limit = 100)
    Message
      Nominatim returns at most 50 results per query. `limit` has been set to 50.

# geo_lite_struct_sf() returns empty geometry after API failure

    Code
      several <- geo_lite_struct_sf("madrid", full_results = TRUE)
    Message
      Could not reach the API endpoint: https://nominatim.openstreetmap.org/search?format=geojson&limit=1&addressdetails=1&amenity=madrid.

