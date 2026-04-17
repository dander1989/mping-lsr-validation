-- ==========================================================
-- 03_SPATIAL_ANALYSIS.SQL
-- Goal: Aggregate LSR points to County Polygons
-- ==========================================================

-- A. Create a View for the Study Area (Dynamic Boundary)
-- Using LEFT JOIN to ensure all counties in study area are represented
CREATE OR REPLACE VIEW lsr_analysis.v_storm_extent AS
SELECT ST_ConvexHull (ST_Collect (geom)) AS boundary
FROM lsr_analysis.clean_lsr;

-- B. County-Level Aggregation (Total Reports)
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

-- C. Report Breakdown by typetext (Pivoted View)
-- This helps identify what KIND of storm hit which area
SELECT
    namelsad,
    COUNT(*) FILTER (
        WHERE
            typetext = 'TORNADO'
    ) AS tornado_count,
    COUNT(*) FILTER (
        WHERE
            typetext = 'TSTM WND'
            OR typetext = 'WIND'
    ) AS wind_count,
    COUNT(*) FILTER (
        WHERE
            typetext = 'HAIL'
    ) AS hail_count
FROM lsr_analysis.county_report_counts -- (Joining back to clean_lsr for typetext)

-- D. Daily Spatial Breakdown
-- Goal: See the progression of the storm across counties by date
DROP TABLE IF EXISTS lsr_analysis.daily_county_summary;

CREATE TABLE lsr_analysis.daily_county_summary AS
SELECT
    a.geoid,
    a.namelsad,
    a.statefp,
    date_trunc('day', b.event_time) AS storm_date,
    COUNT(b.*) AS report_count
FROM reference.counties a
    JOIN lsr_analysis.clean_lsr b ON ST_Intersects (a.geom_5070, b.geom)
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
    a.statefp,
    storm_date
ORDER BY storm_date ASC, report_count DESC;

-- E. County Severity Index
-- Goal: Calculate a weighted impact score per county based on report type and intensity
DROP TABLE IF EXISTS lsr_analysis.county_severity_index;

CREATE TABLE lsr_analysis.county_severity_index AS
WITH
    weighted_reports AS (
        SELECT
            b.event_time,
            b.geom,
            CASE
                WHEN b.typetext = 'TORNADO' THEN 10
                WHEN b.typetext IN ('TSTM WND', 'WND') THEN 5 + (COALESCE(b.magnitude, 0) / 10)
                WHEN b.typetext = 'HAIL' THEN 2 + (COALESCE(b.magnitude, 0))
                ELSE 1
            END AS report_weight
        FROM lsr_analysis.clean_lsr b
    )
SELECT
    a.geoid,
    a.namelsad,
    SUM(r.report_weight) AS severity_score,
    COUNT(r.*) AS total_reports
FROM
    reference.counties a
    JOIN weighted_reports r ON ST_Intersects (a.geom_5070, r.geom)
GROUP BY
    a.geoid,
    a.namelsad
ORDER BY severity_score DESC;