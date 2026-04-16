-- ==========================================================
-- 03_SPATIAL_ANALYSIS.SQL
-- Goal: Aggregate LSR points to County Polygons
-- ==========================================================

-- B. County-Level Aggregation (Total Reports)
-- Using LEFT JOIN to ensure all counties in study area are represented
CREATE OR REPLACE VIEW lsr_analysis.v_storm_extent AS
SELECT ST_ConvexHull (ST_Collect (geom)) AS boundary
FROM lsr_analysis.clean_lsr;

-- Query with 'rubber band' using ConvexHull to isolate counties only where the bounds of the LSR data is.
DROP TABLE IF EXISTS lsr_analysis.county_report_counts;

CREATE TABLE lsr_analysis.county_report_counts AS
SELECT a.geoid, a.namelsad, a.statefp, COUNT(b.*) AS total_lsr_count
FROM reference.counties a
    LEFT JOIN lsr_analysis.clean_lsr b ON ST_Intersects (a.geom_5070, b.geom)
WHERE
    ST_Intersects (
        a.geom_5070,
        (
            SELECT boundary
            FROM lsr_analysis.v_storm_extent
        )
    )
GROUP BY
    a.geoid,
    a.namelsad,
    a.statefp;

-- C. Report Breakdown by Type (Pivoted View)
-- This helps identify what KIND of storm hit which area
SELECT
    namelsad,
    COUNT(*) FILTER (
        WHERE
            type = 'TORNADO'
    ) AS tornado_count,
    COUNT(*) FILTER (
        WHERE
            type = 'TSTM WND'
            OR type = 'WIND'
    ) AS wind_count,
    COUNT(*) FILTER (
        WHERE
            type = 'HAIL'
    ) AS hail_count
FROM lsr_analysis.county_report_counts -- (Joining back to clean_lsr for type)