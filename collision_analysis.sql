//

NYC MOTOR VEHICLE COLLISIONS ANALYSIS 

Collision Trends:
•	Calculate the Total Crashes per year and see if they’re increasing or decreasing.
•	Break down crashes by borough to find which areas have the highest rates.
•	Find the top 10 streets or intersections with the most collisions. 

Contributing Factors:
•	Count how often each contributing factor (e.g., “Driver Inattention/Distraction,” “Aggressive Driving”) appears.
•	Identify the top 5 causes of crashes.
•	Compare factors between boroughs (e.g., Is speeding more common in Queens than Manhattan?).

Injury & Fatality Analysis:
•	Analyze the total number of people injured and killed by borough.
•	Separate out pedestrians, cyclists, and motorists to see which groups are most affected.
•	Create charts showing injury/fatality trends over time.

Vehicle Types
•	Determine which vehicle types are most often involved in crashes (e.g., Sedans, SUVs, Trucks, Mopeds).
•	Compare if certain vehicle types are linked to more severe crashes (higher injury/fatality rates).


//

KEY METRICS

# Total Crash Count

SELECT 
    COUNT(collision_id) AS total_crashes
FROM cleaned_collisions_data;

---
# Total Casualties (Injured + Killed)

SELECT 
    SUM(persons_injured) AS total_injured,
    SUM(persons_killed) AS total_killed,
    SUM(persons_injured + persons_killed) AS total_casualties
FROM cleaned_collisions_data;

---
# Fatality and Injury Rates per 100 Collisions (Percentages)

SELECT 
    COUNT(collision_id) AS total_crashes,
    -- Fatality Rate (%)
    ROUND(
        (SUM(persons_killed) * 100.0) / NULLIF(COUNT(collision_id), 0), 2
    ) AS fatality_rate_pct,
    -- Injury Rate (%)
    ROUND(
        (SUM(persons_injured) * 100.0) / NULLIF(COUNT(collision_id), 0), 2
    ) AS injury_rate_pct
FROM cleaned_collisions_data;

---
#  Rates per 1,000 Collisions (Traffic Safety Standard)

SELECT 
    ROUND(
        (SUM(persons_killed) * 1000.0) / NULLIF(COUNT(collision_id), 0), 2
    ) AS fatalities_per_1k_crashes,
    ROUND(
        (SUM(persons_injured) * 1000.0) / NULLIF(COUNT(collision_id), 0), 2
    ) AS injuries_per_1k_crashes
FROM cleaned_collisions_data;

---
# Vulnerable Road User (VRU) Metrics

SELECT 
    -- Pedestrians
    SUM(ped_injured + ped_killed) AS total_pedestrian_vru,
    -- Cyclists
    SUM(cyclist_injured + cyclist_killed) AS total_cyclist_vru,
    -- Total Combined VRU Casualties
    SUM(
        ped_injured + ped_killed +
        cyclist_injured + cyclist_killed
    ) AS total_vru_casualties
FROM cleaned_collisions_data;

---
# Crash Breakdown by Borough

SELECT 
    COALESCE(borough, 'Unspecified') AS borough,
    COUNT(collision_id) AS total_crashes,
    SUM(persons_injured) AS total_injured,
    SUM(persons_killed) AS total_killed,
    ROUND(
        (COUNT(collision_id) * 100.0) / SUM(COUNT(collision_id)) OVER(), 2
    ) AS pct_of_city_total
FROM cleaned_collisions_data
GROUP BY borough
ORDER BY total_crashes DESC;


---
# Hourly Peak Crash Times

SELECT 
    CAST(strftime('%H', crash_time) AS INTEGER) AS crash_hour,
    COUNT(collision_id) AS total_crashes,
    SUM(persons_killed) AS total_fatalities
FROM cleaned_collisions_data
WHERE crash_time IS NOT NULL
GROUP BY crash_hour
ORDER BY crash_hour ASC;

---
# Peak crash hour for each day of the week
--ranked to identify which specific weekday and hour combination has the highest number of crashes

------

SELECT 
    CASE strftime('%w', crash_date)
        WHEN '1' THEN 'Monday'
        WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday'
        WHEN '4' THEN 'Thursday'
        WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday'
        WHEN '0' THEN 'Sunday'
    END AS day_of_week,
    CAST(strftime('%H', crash_time) AS INTEGER) AS crash_hour,
    COUNT(collision_id) AS total_crashes
FROM cleaned_collisions_data
WHERE crash_date IS NOT NULL AND crash_time IS NOT NULL  
GROUP BY day_of_week, crash_hour
ORDER BY day_of_week, crash_hour;

--- 
---
COLLISION TRENDS

# Total crashes per year:
# Since the crash_date column is formatted as a TIMESTAMP (or date string), we use the strftime function in SQLite to extract the year

SELECT 
    strftime('%Y', crash_date) AS crash_year,
    COUNT(*) AS total_crashes
FROM cleaned_collisions_data
WHERE crash_date IS NOT NULL
GROUP BY crash_year
ORDER BY crash_year ASC;

---
# Breakdown of crashes by borough 

SELECT 
    borough, 
    COUNT(*) AS total_crashes
FROM cleaned_collisions_data
GROUP BY borough
ORDER BY total_crashes DESC;

---
# The top 10 streets combinations/intersections with the most collisions

SELECT 
    on_street, 
    cross_street,
    off_street,
    COUNT(*) AS total_crashes
FROM cleaned_collisions_data
WHERE on_street != 'Unspecified'
  AND cross_street != 'Unspecified'
  AND off_street != 'Unspecified'
GROUP BY on_street, cross_street, off_street  
ORDER BY total_crashes DESC
LIMIT 10;

---
# Top 10 individual streets overall with the most collisions

SELECT 
    street_name,
    COUNT(*) AS total_crashes
FROM (
    SELECT on_street AS street_name FROM cleaned_collisions_data
    UNION ALL
    SELECT cross_street AS street_name FROM cleaned_collisions_data
    UNION ALL
    SELECT off_street AS street_name FROM cleaned_collisions_data
) AS combined_streets
WHERE street_name != 'Unspecified'
  AND street_name IS NOT NULL
GROUP BY street_name
ORDER BY total_crashes DESC
LIMIT 10;

---
---
CONTRIBUTING FACTORS ANALYSIS

--- Count of Contributing Factors 
# Alternative 1: The primary reason for each crash
-- To determine the primary cause of each crash (which is recorded in factor_1)

SELECT 
    factor_1 AS primary_factor, 
    COUNT(*) AS crash_count
FROM cleaned_collisions_data
WHERE factor_1 IS NOT NULL 
  AND factor_1 NOT IN ('Unspecified', 'Not Applicable', '')
GROUP BY factor_1
ORDER BY crash_count DESC;


---

# Top 5 Primary Reasons for Crashes 

SELECT 
    factor_1 AS primary_factor, 
    COUNT(*) AS crash_count
FROM cleaned_collisions_data
WHERE factor_1 IS NOT NULL 
  AND factor_1 NOT IN ('Unspecified', 'Not Applicable', '')
GROUP BY factor_1
ORDER BY crash_count DESC
LIMIT 5;

---

# Alternative 2: The least contributing factors across all factor columns combined
-- To count how often each factor appears across all factor columns combined
-- Used a UNION ALL subquery to stack all factors into a single column first, 
-- Filtered out non-values like 'Unspecified' or 'Not Applicable', and then aggregated.

SELECT 
    factor_name, 
    COUNT(*) AS total_occurrences
FROM (
    SELECT factor_1 AS factor_name FROM cleaned_collisions_data
    UNION ALL
    SELECT factor_2 AS factor_name FROM cleaned_collisions_data
    UNION ALL
    SELECT factor_3 AS factor_name FROM cleaned_collisions_data
    UNION ALL
    SELECT factor_4 AS factor_name FROM cleaned_collisions_data
    UNION ALL
    SELECT factor_5 AS factor_name FROM cleaned_collisions_data
) AS combined_factors
WHERE factor_name IS NOT NULL 
  AND factor_name NOT IN ('Unspecified', 'Not Applicable', '')
GROUP BY factor_name
ORDER BY total_occurrences ASC;

---
# Top 10 ranked Primary reasons for Crashes by Borough
-- Using a CTE and a Window Function [ROW_NUMBER()]
-- PARTITION BY borough: Tells SQL to restart the ranking counter from 1 for every unique borough
-- ROW_NUMBER() OVER (...): Assigns ranks 1, 2, 3, 4, 5 based on crash_count DESC within each borough.
-- WHERE factor_rank <= 5: Filters the results so we only see the top 5 factors for each borough.

WITH ranked_factors AS (
    SELECT 
        borough,
        factor_1 AS primary_factor, 
        COUNT(*) AS crash_count,
        ROW_NUMBER() OVER (
            PARTITION BY borough 
            ORDER BY COUNT(*) DESC
        ) AS factor_rank
    FROM cleaned_collisions_data
    WHERE factor_1 IS NOT NULL 
      AND factor_1 NOT IN ('Unspecified', 'Not Applicable', '')
      AND borough IS NOT NULL
      AND borough NOT IN ('Unspecified', '')
    GROUP BY borough, factor_1
)
SELECT 
    borough,
    primary_factor,
    crash_count,
    factor_rank
FROM ranked_factors
WHERE factor_rank <= 10
ORDER BY borough, factor_rank;


---
---
-- INJURY AND FATALITY ANALYSIS
# Total number of people injured and killed broken down by borough

SELECT 
    borough,
    SUM(persons_injured) AS total_injured,
    SUM(persons_killed) AS total_killed,
    SUM(persons_injured + persons_killed) AS total_casualty_count
FROM cleaned_collisions_data
WHERE borough IS NOT NULL 
  AND borough NOT IN ('Unspecified', '')
GROUP BY borough
ORDER BY total_casualty_count DESC;

---
# Injuries and Fatalities by Mode of Transport

WITH base_data AS (
    SELECT 
        COALESCE(ped_injured, 0) AS ped_inj,
        COALESCE(ped_killed, 0)  AS ped_kill,
        COALESCE(cyclist_injured, 0)     AS cyc_inj,
        COALESCE(cyclist_killed, 0)      AS cyc_kill,
        COALESCE(motorist_injured, 0)    AS mot_inj,
        COALESCE(motorist_killed, 0)     AS mot_kill
    FROM cleaned_collisions_data
),
unioned_totals AS (
    SELECT 'Pedestrians' AS victim_group, SUM(ped_inj) AS total_injured, SUM(ped_kill) AS total_killed, SUM(ped_inj + ped_kill) AS total_casualties FROM base_data
    UNION ALL
    SELECT 'Cyclists' AS victim_group, SUM(cyc_inj) AS total_injured, SUM(cyc_kill) AS total_killed, SUM(cyc_inj + cyc_kill) AS total_casualties FROM base_data
    UNION ALL
    SELECT 'Motorists' AS victim_group, SUM(mot_inj) AS total_injured, SUM(mot_kill) AS total_killed, SUM(mot_inj + mot_kill) AS total_casualties FROM base_data
)
SELECT * 
FROM unioned_totals
ORDER BY total_casualties DESC;


----
--Each group's percentage share of total injuries and fatalities

SELECT 
    SUM(ped_injured) AS pedestrian_injured,
    SUM(ped_killed) AS pedestrian_killed,
    SUM(cyclist_injured) AS cyclist_injured,
    SUM(cyclist_killed) AS cyclist_killed,
    SUM(motorist_injured) AS motorist_injured,
    SUM(motorist_killed) AS motorist_killed, 
    SUM(persons_injured) AS total_injured,
    SUM(persons_killed) AS total_killed, 
        -- Percentage Calculations
    ROUND(100.0 * SUM(ped_injured) / NULLIF(SUM(persons_injured), 0), 2) AS pct_pedestrian_injured,
    ROUND(100.0 * SUM(cyclist_injured) / NULLIF(SUM(persons_injured), 0), 2) AS pct_cyclist_injured,
    ROUND(100.0 * SUM(motorist_injured) / NULLIF(SUM(persons_injured), 0), 2) AS pct_motorist_injured
FROM cleaned_collisions_data;


----
# Injuries trends over time 
--using a HAVING clause to check if all 12 distinct months exist in a particular year. 
--It excludes any year missing data for one or more months. 

SELECT 
    strftime('%Y', crash_date) AS crash_year,
    SUM(total_injured) AS total_injuries
FROM cleaned_collisions_data
GROUP BY crash_year
HAVING COUNT(DISTINCT strftime('%m', crash_date)) = 12
ORDER BY crash_year ASC;


----
# Fatality trends over time

SELECT 
    strftime('%Y', crash_date) AS crash_year,
    SUM(total_killed) AS total_fatalities
FROM cleaned_collisions_data
GROUP BY crash_year
HAVING COUNT(DISTINCT strftime('%m', crash_date)) = 12
ORDER BY crash_year ASC;


---
# Crashes by Vehicle Type

SELECT 
    vehicle_1  AS Vehicle_Type, 
    COUNT(*) AS crash_count
FROM cleaned_collisions_data
WHERE vehicle_1 IS NOT NULL 
  AND vehicle_1 NOT IN ('Unspecified', 'Not Applicable', '')
GROUP BY vehicle_1
ORDER BY crash_count DESC
LIMIT 10;

----
# Injury by Vehicle Type

SELECT 
    vehicle_1  AS Vehicle_Type, 
    SUM(total_injured) AS injury_count
FROM cleaned_collisions_data
WHERE vehicle_1 IS NOT NULL 
  AND vehicle_1 NOT IN ('Unspecified', 'Not Applicable', '')
GROUP BY vehicle_1
ORDER BY injury_count DESC
LIMIT 20;


----
# Fatality by Vehicle Type

SELECT 
    vehicle_1  AS Vehicle_Type, 
    SUM(total_killed) AS fatality_count
FROM cleaned_collisions_data
WHERE vehicle_1 IS NOT NULL 
  AND vehicle_1 NOT IN ('Unspecified', 'Not Applicable', '')
GROUP BY vehicle_1
ORDER BY fatality_count DESC
LIMIT 20;