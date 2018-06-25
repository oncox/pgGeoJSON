# pgGeoJSON

pgGeoJSON is a PostgreSQL module providing additional functionality for generating GeoJSON output.

The [PostGIS](https://postgis.net/) extension to PostgreSQL provides a wealth of geospatial functionality within PostgreSQL.  However, many of these are atomic operations, providing the building blocks for users to build queries that build output, but resulting in compplicated queries that are utilised repeatedly.

This has been found to be particularly true with GeoJSON outputs.  pgGeoJSON contains functions for converting an entire table to GeoJSON, with non-geometry columns assumed to be properties of the spatial feature defined by the geometry column.


## Getting Started <a name="getstarted"></a>

- ###### Installation

Clone the repository.

    git clone https://github.com/oncox/pgGeoJSON.git

On a PostgreSQL instance with PostGIS available, copy the pggeojson--[version].sql file and pggeojson.control files to PostgreSQL's /share/extensions directory.

Create the PostGIS extension if it hasn't yet been created, and similarly create the pggeojson extension.

	CREATE EXTENSION postgis;   
	CREATE EXTENSION pggeojson;
    

- ###### Usage

Create a table which has a geometry column and some other non-Geometry properties:

	CREATE TABLE pgg_test(gid serial, ref varchar(1), geom geometry(Point))

Populate the table with some data:

	INSERT INTO pgg_test (ref, geom) VALUES (E'a', ST_GeomFromText('POINT(45.0000 0.000000)',4326));
	INSERT INTO pgg_test (ref, geom) VALUES (E'b', ST_GeomFromText('POINT(50.0000 0.000000)',4326));
	INSERT INTO pgg_test (ref, geom) VALUES (E'c', ST_GeomFromText('POINT(45.0000 5.000000)',4326));
	INSERT INTO pgg_test (ref, geom) VALUES (E'd', ST_GeomFromText('POINT(50.0000 5.000000)',4326));

Finally, the pgg_AsGeoJSON function can be used to generate GeoJSON output:

	SELECT pgg_AsGeoJSON('pgg_test')
    
    {
        "type": "FeatureCollection",
        "crs": {
            "type": "name",
            "properties": {
                "name": "EPSG:4326"
            }
        },
        "features": [
            {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [45, 0]
                },
                "properties": {
                    "gid": 1,
                    "ref": "a"
                }
            },
            {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [50, 0]
                },
                "properties": {
                    "gid": 2,
                    "ref": "b"
                }
            },
            {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [45, 5]
                },
                "properties": {
                    "gid": 3,
                    "ref": "c"
                }
            },
            {
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [50, 5]
                },
                "properties": {
                    "gid": 4,
                    "ref": "d"
                }
            }
        ]
    }
    
    
## Advanced 
 

