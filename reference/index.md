# Package index

## Address search

Perform free-form and structured address searches to find coordinates
and place information.

- [`geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite.md)
  : Address search API (free-form query)

- [`geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_sf.md)
  :

  Address search API with [sf](https://CRAN.R-project.org/package=sf)
  output (free-form query)

- [`geo_lite_struct()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct.md)
  : Address search API (structured query)

- [`geo_lite_struct_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_lite_struct_sf.md)
  :

  Address search API with [sf](https://CRAN.R-project.org/package=sf)
  output (structured query)

## Reverse geocoding

Find addresses and place information from latitude and longitude
coordinates.

- [`reverse_geo_lite()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite.md)
  : Reverse geocoding API

- [`reverse_geo_lite_sf()`](https://dieghernan.github.io/nominatimlite/reference/reverse_geo_lite_sf.md)
  :

  Reverse geocoding API with [sf](https://CRAN.R-project.org/package=sf)
  output

## Amenity lookup

Search for OpenStreetMap amenities within a bounding box.

- [`geo_amenity()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity.md)
  : Look up amenities

- [`geo_amenity_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_amenity_sf.md)
  :

  Look up amenities with [sf](https://CRAN.R-project.org/package=sf)
  output

- [`osm_amenities`](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md)
  : OpenStreetMap amenities

## Address lookup

Retrieve address details for OpenStreetMap node, way and relation
identifiers.

- [`geo_address_lookup()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup.md)
  : Address lookup API

- [`geo_address_lookup_sf()`](https://dieghernan.github.io/nominatimlite/reference/geo_address_lookup_sf.md)
  :

  Address lookup API with [sf](https://CRAN.R-project.org/package=sf)
  output

## Spatial helpers

Convert bounding boxes to `sf` geometries. Functions that return `sf`
objects are listed with their corresponding API operations above.

- [`bbox_to_poly()`](https://dieghernan.github.io/nominatimlite/reference/bbox_to_poly.md)
  :

  Convert a bounding box to an
  [`sfc`](https://r-spatial.github.io/sf/reference/sfc.html) `POLYGON`
  object

## Datasets

Data shipped with the package.

- [`osm_amenities`](https://dieghernan.github.io/nominatimlite/reference/osm_amenities.md)
  : OpenStreetMap amenities

## Package documentation

Package overview and metadata.

- [`nominatimlite`](https://dieghernan.github.io/nominatimlite/reference/nominatimlite-package.md)
  [`nominatimlite-package`](https://dieghernan.github.io/nominatimlite/reference/nominatimlite-package.md)
  : nominatimlite: Interface to the 'Nominatim' API
