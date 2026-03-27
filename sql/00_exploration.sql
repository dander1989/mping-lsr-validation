-- Finding '0's in MAG that should be NULL
SELECT COUNT(*) FROM lsr_analysis.staging_lsr WHERE MAG = 0;

-- Where 0's are concentrated in the TYPECODES
SELECT TYPECODE, COUNT(*)
FROM lsr_analysis.staging_lsr
WHERE
    MAG = 0
GROUP BY
    typecode
ORDER BY COUNT(*) DESC;

-- Full Typecode and Typetext LISTEN
SELECT TYPECODE, TYPETEXT, COUNT(*)
FROM lsr_analysis.staging_lsr
GROUP BY
    typecode,
    typetext
ORDER BY typecode;