\echo Use "CREATE EXTENSION pair" to load this file. \quit

CREATE OR REPLACE FUNCTION PGG_AsGeoJSON(tbl regclass, maxdecimaldigits int = 15, ign text[] = '{}'::text[]) RETURNS json AS $$
DECLARE
  sql text;
  geomcol text;
  cols text[];
  formatcol text;
  dprec RECORD;
  crs json;
  result json;
BEGIN
  sql := E'SELECT attname::text AS col, atttypid::regtype::text AS datatype FROM pg_attribute WHERE  attrelid = \''|| tbl || E'\'::regclass AND attnum > 0 AND NOT attisdropped';

  --+ Identify the columns

  FOR dprec IN EXECUTE sql LOOP
  IF dprec.datatype = 'geometry' THEN
    geomcol := dprec.col;
  ELSE
    IF NOT dprec.col = ANY(ign) THEN
      cols := cols || (E'\'' || dprec.col || E'\'') || dprec.col;
    END IF;
  END IF;
  END LOOP;


  IF array_length(cols, 1) IS NULL THEN
    formatcol := '';
  ELSE
    formatcol := array_to_string(cols, ', ');
  END IF;

  --+ Create the individual features

  sql := E'SELECT json_agg(json_build_object(\'type\', \'Feature\', \'geometry\', ST_AsGeoJSON(geom, $1)::json, \'properties\', json_build_object(' || formatcol || '))) FROM ' || tbl || ';';
  EXECUTE sql INTO result USING maxdecimaldigits;


  --+ Identify the CRS

  sql := E'SELECT json_build_object(\'type\', \'name\', \'properties\', json_build_object(\'name\', \'EPSG:\' || ST_SRID(' || geomcol || ')::text)) As srid FROM ' || tbl || ' LIMIT 1;';
  EXECUTE sql INTO crs;

  --+ Bring the result together

  sql := E'SELECT json_build_object(\'type\', \'FeatureCollection\', \'crs\', $1, \'features\', $2);';
  EXECUTE sql INTO result USING crs, result;


  RETURN result;
END;
$$ LANGUAGE plpgsql;


--+ Overloaded function to allow specifying ignore columns without needing to specify accurarcy

CREATE OR REPLACE FUNCTION PGG_AsGeoJSON(tbl regclass, ign text[] = '{}'::text[]) RETURNS json AS $$
BEGIN
	RETURN PGG_AsGeoJSON(tbl, 15, ign);
END;
$$ LANGUAGE plpgsql;