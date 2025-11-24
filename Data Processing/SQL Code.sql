-- Select sample rows from viewership table
SELECT * 
FROM Bright.Tv_viewership
LIMIT 5;

-- Select sample rows from user profiles table
SELECT * 
FROM bright.tv_user_profiles
LIMIT 5;

-- Main query: joining viewership and user profile information
SELECT 
      V.UserID,

      -- Clean Gender values: replace NULL/empty/None with 'Unknown'
      CASE
         WHEN P.Gender IS NULL OR P.Gender = '' OR P.Gender = 'None' THEN 'Unknown'
        ELSE P.Gender
      END AS Gender,

      -- Clean Race values: replace NULL/empty/None with 'Unknown'
      CASE 
        WHEN P.Race = 'None' OR P.Race = '' OR P.Race IS NULL THEN 'Unknown'
        ELSE P.Race
      END as Race,

      P.Age,

      -- Group Age into categories
      CASE
        WHEN P.Age BETWEEN 5 AND 12 THEN 'Kids'
        WHEN P.Age BETWEEN 13 AND 19 THEN 'Teens'
        WHEN P.Age BETWEEN 20 AND 34 THEN 'Young Adults'
        WHEN P.Age BETWEEN 35 AND 44 THEN ' Middle Adults'
        WHEN P.Age >= 45  THEN 'Adults'
        ELSE 'Unknown'
      END AS Age_Group,

      P.Province,
      P.`Social Media Handle`,
      V.Channel2,
      V.RecordDate2,

      -- Extract day name from record date
      CASE 
        WHEN V.RecordDate2 IS NOT NULL 
        THEN DAYNAME(TO_DATE(V.RecordDate2, 'yyyy/MM/dd HH:mm')) 
        ELSE NULL 
      END AS Day_Of_Week,

      -- Categorize day as Weekday or Weekend
      CASE 
        WHEN V.RecordDate2 IS NOT NULL
        THEN CASE
            WHEN DAYNAME(TO_DATE(V.RecordDate2, 'yyyy/MM/dd HH:mm')) IN ('Sat', 'Sun') THEN 'Weekend'
            ELSE 'Weekday'
        END
        ELSE NULL
      END AS Day_Type,

      -- Extract hour from timestamp
      CASE 
        WHEN V.RecordDate2 IS NOT NULL
        THEN HOUR(TO_TIMESTAMP(V.RecordDate2, 'yyyy/MM/dd HH:mm'))
        ELSE NULL
      END AS Hour_Of_Day,

      -- Categorize time of day into time slots
      CASE 
        WHEN V.RecordDate2 IS NOT NULL
        THEN CASE 
            WHEN HOUR(TO_TIMESTAMP(V.RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 0 AND 5 THEN 'Early_Morning'
            WHEN HOUR(TO_TIMESTAMP(V.RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 6 AND 11 THEN 'Morning' 
            WHEN HOUR(TO_TIMESTAMP(V.RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN HOUR(TO_TIMESTAMP(V.RecordDate2, 'yyyy/MM/dd HH:mm')) BETWEEN 18 AND 23 THEN 'Night'
            ELSE 'Unknown'
        END
        ELSE NULL
      END AS Time_slot

FROM Bright.Tv_viewership AS V
LEFT JOIN bright.tv_user_profiles AS P
ON V.UserID = P.UserID

-- Filter out invalid or empty channel and date values
WHERE V.Channel2 IS NOT NULL
    AND V.Channel2 != ''
    AND V.Channel2 != 'None'
    AND V.RecordDate2 IS NOT NULL;
