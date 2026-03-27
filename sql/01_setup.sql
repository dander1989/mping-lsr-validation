-- Create schema for LSR analysis
CREATE SCHEMA lsr_analysis;

-- Staging table mirrors raw CSV structure exactly
-- Column names match CSV headers for ogr2ogr compatibility
-- VALID and VALID2 stored as TEXT since raw formats are not directly castable to TIMESTAMPTZ
-- Geometry column defined as Point in WGS84 (EPSG:4326)
CREATE TABLE lsr_analysis.staging_lsr (
    GID SERIAL PRIMARY KEY,
    VALID TEXT,
    VALID2 TEXT,
    LAT FLOAT8,
    LON FLOAT8,
    MAG NUMERIC,
    WFO TEXT,
    TYPECODE TEXT,
    TYPETEXT TEXT,
    CITY TEXT,
    COUNTY TEXT,
    STATE TEXT,
    SOURCE TEXT,
    REMARK TEXT,
    UGC TEXT,
    UGCNAME TEXT,
    QUALIFIER TEXT,
    GEOM GEOMETRY (Point, 4326)
)