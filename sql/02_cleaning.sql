-- Active: 1745767497425@@127.0.0.1@25432@storm_analysis@lsr_analysis
-- Active: 1745767497425@@127.0.0.1@25432@storm_analysis
CREATE TABLE lsr_analysis.clean_lsr (
    gid SERIAL PRIMARY KEY,
    event_time TIMESTAMPTZ NOT NULL, -- Taken from VALID2. Dropping VALID column
    latitude FLOAT8 NOT NULL,
    longitude FLOAT8 NOT NULL,
    magnitude NUMERIC NULL, -- Left NULLs available as some damage codes have no magnitude value
    wfo TEXT NOT NULL,
    typecode TEXT NOT NULL,
    typetext TEXT NOT NULL,
    city TEXT,
    county TEXT,
    state TEXT,
    source TEXT,
    remark TEXT,
    ugc TEXT,
    ugcname TEXT,
    qualifier TEXT,
    geom GEOMETRY (Point, 5070) NOT NULL
);

INSERT INTO
    lsr_analysis.clean_lsr (
        event_time,
        latitude,
        longitude,
        magnitude,
        wfo,
        typecode,
        typetext,
        city,
        county,
        state,
        source,
        remark,
        ugc,
        ugcname,
        qualifier,
        geom
    )
SELECT
    to_timestamp(VALID2, 'YYYY/MM/DD HH24:MI') AT TIME ZONE 'UTC', -- Cast VALID2 text to TIMESTAMPTZ
    LAT,
    LON,
    -- Check for empty MAG records and replace with NULL
    CASE
        WHEN mag = 0 THEN NULL
        ELSE mag
    END,
    WFO,
    -- Convert lowercase 'q' to 'Q'
    CASE
        WHEN typecode = 'q' THEN 'Q'
        ELSE typecode
    END,
    TYPETEXT,
    CITY,
    COUNTY,
    STATE,
    SOURCE,
    REMARK,
    UGC,
    UGCNAME,
    QUALIFIER,
    ST_Transform (
        ST_SetSRID (ST_MakePoint (LON, LAT), 4326),
        5070
    )
FROM lsr_analysis.staging_lsr
    -- Remove gid 617 and 794, which were 2 problematic records not adhering to the schema.
WHERE
    gid NOT IN (617, 794);

-- 1. Add a dedicated column for the projected coordinate system (EPSG:5070)
-- We keep the original wkb_geometry (4269) as a backup and for reference.
ALTER TABLE reference.counties
ADD COLUMN IF NOT EXISTS geom_5070 geometry (MultiPolygon, 5070);

-- 2. Transform the data from 4269 (NAD83) to 5070 (CONUS Albers)
-- This is a one-time cost that makes every future query 100x faster.
UPDATE reference.counties
SET
    geom_5070 = ST_Transform (wkb_geometry, 5070)
WHERE
    geom_5070 IS NULL;

-- 3. Create the Spatial Index (The "Secret Sauce" for speed)
CREATE INDEX IF NOT EXISTS idx_counties_geom_5070 ON reference.counties USING GIST (geom_5070);

-- 4. Clean up the database statistics
-- This tells the Query Planner exactly how the data is distributed.
ANALYZE reference.counties;