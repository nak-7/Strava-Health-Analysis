-- ============================================================
-- STRAVA FITNESS DATA ANALYTICS - SQL ANALYSIS
-- Project   : Strava EDA Analysis
-- Author    : Nakshatra Devkar
-- Tool      : SQL
-- Dataset   : Strava Fitness Data
-- ============================================================

CREATE DATABASE Strava;

-- Imported all the files using Table Data Import Wizard

-- ============================================================
-- SECTION 1: DATA INTEGRITY CHECK & CLEANING PREPARATION
-- ============================================================

-- 1.1 Check total record count in each table
SELECT 'dailyActivity'   AS TableName, COUNT(*) AS RowCount FROM dailyActivity_merged
UNION ALL
SELECT 'dailyCalories',  COUNT(*) FROM dailyCalories_merged
UNION ALL
SELECT 'dailyIntensities', COUNT(*) FROM dailyIntensities_merged
UNION ALL
SELECT 'dailySteps',     COUNT(*) FROM dailySteps_merged
UNION ALL
SELECT 'sleepDay',       COUNT(*) FROM sleepDay_merged
UNION ALL
SELECT 'weightLogInfo',  COUNT(*) FROM weightLogInfo_merged;


-- 1.2 Check number of unique users in each table
SELECT 'dailyActivity'    AS TableName, COUNT(DISTINCT Id) AS UniqueUsers FROM dailyActivity_merged
UNION ALL
SELECT 'dailyCalories',   COUNT(DISTINCT Id) FROM dailyCalories_merged
UNION ALL
SELECT 'dailyIntensities',COUNT(DISTINCT Id) FROM dailyIntensities_merged
UNION ALL
SELECT 'dailySteps',      COUNT(DISTINCT Id) FROM dailySteps_merged
UNION ALL
SELECT 'sleepDay',        COUNT(DISTINCT Id) FROM sleepDay_merged
UNION ALL
SELECT 'weightLogInfo',   COUNT(DISTINCT Id) FROM weightLogInfo_merged;


-- 1.3 Check for negative values (data quality validation)
SELECT
    MIN(TotalDistance)             AS Min_TotalDistance,
    MAX(TotalDistance)             AS Max_TotalDistance,
    MIN(TotalSteps)                AS Min_TotalSteps,
    MAX(TotalSteps)                AS Max_TotalSteps,
    MIN(LoggedActivitiesDistance)  AS Min_LoggedActDist,
    MAX(LoggedActivitiesDistance)  AS Max_LoggedActDist,
    MIN(SedentaryMinutes)          AS Min_SedentaryMin,
    MAX(SedentaryMinutes)          AS Max_SedentaryMin,
    MIN(Calories)                  AS Min_Calories,
    MAX(Calories)                  AS Max_Calories
FROM dailyActivity_merged;


-- 1.4 Identify records with full-day sedentary activity (1440 min = 24 hours = tracker not worn)
SELECT
    Id,
    ActivityDate,
    SedentaryMinutes,
    TotalSteps,
    Calories
FROM dailyActivity_merged
WHERE SedentaryMinutes >= 1440
ORDER BY Id, ActivityDate;


-- 1.5 Count sedentary days (>=1440 mins) per user
SELECT
    Id,
    COUNT(*) AS SedentaryDays
FROM dailyActivity_merged
WHERE SedentaryMinutes >= 1440
GROUP BY Id
ORDER BY SedentaryDays DESC;


-- 1.6 Check date range of dataset
SELECT
    MIN(ActivityDate) AS EarliestDate,
    MAX(ActivityDate) AS LatestDate,
    COUNT(DISTINCT ActivityDate) AS UniqueDays
FROM dailyActivity_merged;


-- ============================================================
-- SECTION 2: ANALYSIS – STEPS & ACTIVITY
-- ============================================================

-- 2.1 Average steps taken per day of week
SELECT
    CASE DayNum
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS DayOfWeek,
    COUNT(*) AS Records,
    ROUND(AVG(TotalMinutesAsleep) / 60, 2) AS Avg_HoursAsleep,
    ROUND(AVG(TotalTimeInBed) / 60, 2) AS Avg_HoursInBed
FROM (
    SELECT 
        DAYOFWEEK(SleepDay) AS DayNum,
        TotalMinutesAsleep,
        TotalTimeInBed
    FROM sleepDay_merged
) t
GROUP BY DayNum
ORDER BY DayNum;


-- 2.2 Average steps by participant (sorted highest to lowest)
SELECT
    Id,
    ROUND(AVG(TotalSteps), 0)    AS Avg_Daily_Steps,
    ROUND(AVG(Calories), 0)      AS Avg_Daily_Calories,
    ROUND(AVG(TotalDistance), 2) AS Avg_Daily_Distance,
    COUNT(*)                     AS DaysTracked
FROM dailyActivity_merged
GROUP BY Id
ORDER BY Avg_Daily_Steps DESC;


-- 2.3 User classification by average daily steps (CDC guidelines)
SELECT
    Id,
    ROUND(AVG(TotalSteps), 0) AS Avg_Steps,
    CASE
        WHEN AVG(TotalSteps) < 5000  THEN 'Sedentary (<5K steps)'
        WHEN AVG(TotalSteps) < 7500  THEN 'Low Active (5K–7.5K steps)'
        WHEN AVG(TotalSteps) < 10000 THEN 'Fairly Active (7.5K–10K steps)'
        ELSE                              'Very Active (>10K steps)'
    END AS UserType
FROM dailyActivity_merged
GROUP BY Id
ORDER BY Avg_Steps DESC;


-- 2.4 Count of users in each activity category
SELECT
    UserType,
    COUNT(*) AS UserCount
FROM (
    SELECT
        Id,
        CASE
            WHEN AVG(TotalSteps) < 5000  THEN 'Sedentary (<5K steps)'
            WHEN AVG(TotalSteps) < 7500  THEN 'Low Active (5K–7.5K steps)'
            WHEN AVG(TotalSteps) < 10000 THEN 'Fairly Active (7.5K–10K steps)'
            ELSE 'Very Active (>10K steps)'
        END AS UserType
    FROM dailyActivity_merged
    GROUP BY Id
) AS t   -- ✅ alias added here
GROUP BY UserType
ORDER BY UserCount DESC;


-- 2.5 Percentage of days where users meet 10,000 step CDC goal
SELECT
    Id,
    COUNT(*) AS TotalDays,
    SUM(CASE WHEN TotalSteps >= 10000 THEN 1 ELSE 0 END) AS DaysMet10K,
    ROUND(100.0 * SUM(CASE WHEN TotalSteps >= 10000 THEN 1 ELSE 0 END) / COUNT(*), 1) AS Pct_Met10K
FROM dailyActivity_merged
GROUP BY Id
ORDER BY Pct_Met10K DESC;


-- ============================================================
-- SECTION 3: ANALYSIS – CALORIES & ACTIVE MINUTES
-- ============================================================

-- 3.1 Average active minutes breakdown by day of week
SELECT
    CASE DayNum
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS DayOfWeek,
    ROUND(AVG(VeryActiveMinutes), 1)    AS Avg_VeryActive,
    ROUND(AVG(FairlyActiveMinutes), 1)  AS Avg_FairlyActive,
    ROUND(AVG(LightlyActiveMinutes), 1) AS Avg_LightlyActive,
    ROUND(AVG(SedentaryMinutes), 1)     AS Avg_Sedentary,
    ROUND(AVG(Calories), 0)             AS Avg_Calories
FROM (
    SELECT 
        DAYOFWEEK(ActivityDate) AS DayNum,
        VeryActiveMinutes,
        FairlyActiveMinutes,
        LightlyActiveMinutes,
        SedentaryMinutes,
        Calories
    FROM dailyActivity_merged
) t
GROUP BY DayNum
ORDER BY DayNum;

-- 3.2 Top 10 highest calorie-burning days
SELECT
    Id,
    ActivityDate,
    Calories,
    TotalSteps,
    VeryActiveMinutes,
    FairlyActiveMinutes
FROM dailyActivity_merged
ORDER BY Calories DESC
LIMIT 10;


-- 3.3 Calories burned vs total active minutes correlation summary
SELECT
    ROUND(AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes), 1) AS Avg_TotalActiveMin,
    ROUND(AVG(Calories), 0)  AS Avg_Calories,
    ROUND(MIN(Calories), 0)  AS Min_Calories,
    ROUND(MAX(Calories), 0)  AS Max_Calories,
    ROUND(AVG(SedentaryMinutes), 0) AS Avg_SedentaryMin
FROM dailyActivity_merged
WHERE Calories > 0;


-- 3.4 Average calories by participant with activity breakdown
SELECT
    Id,
    ROUND(AVG(Calories), 0)                                                         AS Avg_Calories,
    ROUND(AVG(VeryActiveMinutes), 1)                                                AS Avg_VeryActive_Min,
    ROUND(AVG(FairlyActiveMinutes), 1)                                              AS Avg_FairlyActive_Min,
    ROUND(AVG(LightlyActiveMinutes), 1)                                             AS Avg_LightlyActive_Min,
    ROUND(AVG(SedentaryMinutes), 0)                                                 AS Avg_Sedentary_Min,
    ROUND(AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes), 1)   AS Avg_TotalActive_Min
FROM dailyActivity_merged
GROUP BY Id
ORDER BY Avg_Calories DESC;


-- ============================================================
-- SECTION 4: ANALYSIS – SEDENTARY BEHAVIOUR
-- ============================================================

-- 4.1 Average sedentary minutes per participant, ordered worst to best
SELECT
    Id,
    ROUND(AVG(SedentaryMinutes), 0) AS Avg_SedentaryMinutes,
    ROUND(AVG(SedentaryMinutes) / 60.0, 1) AS Avg_SedentaryHours
FROM dailyActivity_merged
GROUP BY Id
ORDER BY Avg_SedentaryMinutes DESC;


-- 4.2 Sedentary pattern by day of week
SELECT
    CASE DayNum
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS DayOfWeek,
    ROUND(AVG(SedentaryMinutes), 0)        AS Avg_Sedentary_Min,
    ROUND(AVG(SedentaryMinutes) / 60, 1)   AS Avg_Sedentary_Hrs,
    COUNT(*)                              AS RecordCount
FROM (
    SELECT 
        DAYOFWEEK(ActivityDate) AS DayNum,
        SedentaryMinutes
    FROM dailyActivity_merged
) t
GROUP BY DayNum
ORDER BY Avg_Sedentary_Min DESC;

-- ============================================================
-- SECTION 5: ANALYSIS – SLEEP
-- ============================================================

-- 5.1 Average sleep duration per user
SELECT
    Id,
    COUNT(*)                                     AS SleepRecordCount,
    ROUND(AVG(TotalMinutesAsleep), 0)            AS Avg_MinutesAsleep,
    ROUND(AVG(TotalMinutesAsleep) / 60.0, 2)    AS Avg_HoursAsleep,
    ROUND(AVG(TotalTimeInBed), 0)               AS Avg_TimeInBed_Min,
    ROUND(AVG(TotalTimeInBed - TotalMinutesAsleep), 0) AS Avg_WakeInBed_Min
FROM sleepDay_merged
GROUP BY Id
ORDER BY Avg_HoursAsleep DESC;


-- 5.2 Users getting less than 7 hours of sleep on average
SELECT
    Id,
    ROUND(AVG(TotalMinutesAsleep) / 60.0, 2) AS Avg_HoursAsleep
FROM sleepDay_merged
GROUP BY Id
HAVING AVG(TotalMinutesAsleep) < 420
ORDER BY Avg_HoursAsleep ASC;


-- 5.3 Average sleep by day of week
SELECT
    CASE DayNum
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS DayOfWeek,
    COUNT(*) AS Records,
    ROUND(AVG(TotalMinutesAsleep) / 60, 2) AS Avg_HoursAsleep,
    ROUND(AVG(TotalTimeInBed) / 60, 2) AS Avg_HoursInBed
FROM (
    SELECT 
        DAYOFWEEK(SleepDay) AS DayNum,
        TotalMinutesAsleep,
        TotalTimeInBed
    FROM sleepDay_merged
) t
GROUP BY DayNum
ORDER BY DayNum;

-- 5.4 Overall sleep summary statistics
SELECT
    ROUND(AVG(TotalMinutesAsleep) / 60.0, 2)  AS Overall_Avg_HoursAsleep,
    ROUND(MIN(TotalMinutesAsleep) / 60.0, 2)  AS Min_HoursAsleep,
    ROUND(MAX(TotalMinutesAsleep) / 60.0, 2)  AS Max_HoursAsleep,
    COUNT(*)                                   AS TotalSleepRecords,
    COUNT(DISTINCT Id)                         AS UsersWithSleepData
FROM sleepDay_merged;


-- ============================================================
-- SECTION 6: ANALYSIS – WEIGHT & BMI
-- ============================================================

-- 6.1 Weight and BMI summary per user
SELECT
    Id,
    COUNT(*) AS WeightLogCount,
    ROUND(AVG(WeightKg), 1) AS Avg_WeightKg,
    ROUND(AVG(WeightPounds), 1) AS Avg_WeightLbs,
    ROUND(AVG(BMI), 1) AS Avg_BMI,
    ROUND(MIN(BMI), 1) AS Min_BMI,
    ROUND(MAX(BMI), 1) AS Max_BMI,
    MAX(IsManualReport) AS IsManualReport
FROM weightLogInfo_merged
GROUP BY Id
ORDER BY Avg_BMI DESC;

-- 6.2 BMI category classification per user
SELECT
    Id,
    ROUND(AVG(BMI), 1) AS Avg_BMI,
    CASE
        WHEN AVG(BMI) < 18.5 THEN 'Underweight'
        WHEN AVG(BMI) < 25.0 THEN 'Normal Weight'
        WHEN AVG(BMI) < 30.0 THEN 'Overweight'
        ELSE                      'Obese'
    END AS BMI_Category
FROM weightLogInfo_merged
GROUP BY Id
ORDER BY Avg_BMI DESC;


-- ============================================================
-- SECTION 7: COMBINED / JOINED ANALYSIS
-- ============================================================

-- 7.1 Join steps + sleep to find relationship
SELECT
    a.Id,
    a.ActivityDate,
    a.TotalSteps,
    a.Calories,
    a.SedentaryMinutes,
    s.TotalMinutesAsleep,
    ROUND(s.TotalMinutesAsleep / 60.0, 2) AS HoursAsleep
FROM dailyActivity_merged a
LEFT JOIN sleepDay_merged s
    ON a.Id = s.Id
    AND DATE(a.ActivityDate) = DATE(s.SleepDay)
WHERE s.TotalMinutesAsleep IS NOT NULL
ORDER BY a.Id, a.ActivityDate;


-- 7.2 Aggregate: active users tend to sleep more?
SELECT
    CASE
        WHEN AVG_Steps < 5000  THEN 'Sedentary'
        WHEN AVG_Steps < 7500  THEN 'Low Active'
        WHEN AVG_Steps < 10000 THEN 'Fairly Active'
        ELSE 'Very Active'
    END AS UserType,
    COUNT(*) AS UserCount,
    ROUND(AVG(AVG_Steps), 0) AS Avg_Steps,
    ROUND(AVG(Avg_Sleep_Hrs), 2) AS Avg_Sleep_Hours
FROM (
    SELECT
        a.Id,
        AVG(a.TotalSteps) AS AVG_Steps,
        AVG(s.TotalMinutesAsleep / 60.0) AS Avg_Sleep_Hrs
    FROM dailyActivity_merged a
    LEFT JOIN sleepDay_merged s
        ON a.Id = s.Id
        AND DATE(a.ActivityDate) = DATE(s.SleepDay)
    GROUP BY a.Id
) AS t   -- ✅ THIS LINE FIXES YOUR ERROR
GROUP BY UserType
ORDER BY Avg_Steps DESC;

-- 7.3 Steps + Calories combined daily summary
SELECT
    DATE(a.ActivityDate) AS Date,
    ROUND(AVG(a.TotalSteps), 0)  AS Avg_Steps,
    ROUND(AVG(a.Calories), 0)    AS Avg_Calories,
    ROUND(AVG(a.SedentaryMinutes), 0) AS Avg_Sedentary_Min,
    COUNT(DISTINCT a.Id)         AS ActiveUsers
FROM dailyActivity_merged a
GROUP BY DATE(a.ActivityDate)
ORDER BY Date;


-- ============================================================
-- SECTION 8: SUMMARY INSIGHTS QUERIES
-- ============================================================

-- 8.1 Overall dataset summary
SELECT
    COUNT(DISTINCT Id)                                  AS TotalUsers,
    COUNT(*)                                            AS TotalRecords,
    MIN(ActivityDate)                                   AS StartDate,
    MAX(ActivityDate)                                   AS EndDate,
    ROUND(AVG(TotalSteps), 0)                           AS Avg_Daily_Steps,
    ROUND(AVG(Calories), 0)                             AS Avg_Daily_Calories,
    ROUND(AVG(TotalDistance), 2)                        AS Avg_Daily_Distance,
    ROUND(AVG(SedentaryMinutes), 0)                     AS Avg_Sedentary_Min,
    ROUND(AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes), 0) AS Avg_Active_Min,
    SUM(CASE WHEN TotalSteps >= 10000 THEN 1 ELSE 0 END) AS Days_Met_10K_Goal,
    ROUND(100.0 * SUM(CASE WHEN TotalSteps >= 10000 THEN 1 ELSE 0 END) / COUNT(*), 1) AS Pct_Met_10K_Goal
FROM dailyActivity_merged;


-- 8.2 Most consistent users (most days tracked)
SELECT
    Id,
    COUNT(*) AS DaysTracked,
    ROUND(AVG(TotalSteps), 0) AS Avg_Steps,
    ROUND(AVG(Calories), 0)   AS Avg_Calories
FROM dailyActivity_merged
GROUP BY Id
ORDER BY DaysTracked DESC, Avg_Steps DESC
LIMIT 10;


-- 8.3 Busiest days overall (sum of steps across all users)
SELECT
    ActivityDate,
    SUM(TotalSteps) AS Total_Steps_All_Users,
    COUNT(DISTINCT Id) AS ActiveUsers,
    ROUND(AVG(TotalSteps), 0) AS Avg_Steps_Per_User
FROM dailyActivity_merged
GROUP BY ActivityDate
ORDER BY Total_Steps_All_Users DESC
LIMIT 10;

-- ============================================================
-- END OF SQL ANALYSIS
-- Project: Strava Fitness Data Analytics Case Study
-- Author : Nakshatra Devkar
-- ============================================================
