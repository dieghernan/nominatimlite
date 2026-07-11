# Package index

## Geocoding

Search OpenStreetMap using free-form text, structured queries or
geographic coordinates.

### Address search

Search for places and addresses using free-form text or structured
address components.

- [`geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite.md)
  : Search for addresses with free-form queries

- [`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_sf.md)
  :

  Search for addresses with free-form queries and return
  [sf](https://CRAN.R-project.org/package=sf) objects

- [`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct.md)
  : Search for addresses with structured queries

- [`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_lite_struct_sf.md)
  :

  Search for addresses with structured queries and return
  [sf](https://CRAN.R-project.org/package=sf) objects

### Reverse geocoding

Convert latitude and longitude coordinates into human-readable
addresses.

- [`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite.md)
  : Reverse geocode coordinates

- [`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/reverse_geo_lite_sf.md)
  :

  Reverse geocode coordinates and return
  [sf](https://CRAN.R-project.org/package=sf) objects

## OpenStreetMap lookups

Retrieve OpenStreetMap features directly from existing OSM identifiers
or search for amenities within a geographic area.

### Address lookup

Retrieve OpenStreetMap nodes, ways and relations from their OSM
identifiers.

- [`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup.md)
  : Look up OpenStreetMap objects

- [`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_address_lookup_sf.md)
  :

  Look up OpenStreetMap objects and return
  [sf](https://CRAN.R-project.org/package=sf) objects

### Amenity lookup

Find OpenStreetMap amenities and points of interest inside a bounding
box.

- [`geo_amenity()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity.md)
  : Look up OpenStreetMap amenities

- [`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/dev/reference/geo_amenity_sf.md)
  :

  Look up OpenStreetMap amenities and return
  [sf](https://CRAN.R-project.org/package=sf) objects

## Utilities

Helper functions and bundled datasets.

### Spatial output

Convert returned bounding boxes into `sf` polygon geometries.

- [`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/dev/reference/bbox_to_poly.md)
  :

  Convert a bounding box to an
  [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html) `POLYGON`
  object

### Datasets

Sample data included with the package.

- [`osm_amenities`](https://dieghernan.github.io/nominatimlite/dev/reference/osm_amenities.md)
  : OpenStreetMap amenities

## Package documentation

Package overview and metadata.

- [`nominatimlite`](https://dieghernan.github.io/nominatimlite/dev/reference/nominatimlite-package.md)
  [`nominatimlite-package`](https://dieghernan.github.io/nominatimlite/dev/reference/nominatimlite-package.md)
  : nominatimlite: Interface to the 'Nominatim' API
