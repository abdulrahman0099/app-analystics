-- USER  ANALYSIS --

-- Daily active user -- 

SELECT
  event_date as dates,
  COUNT(DISTINCT user_pseudo_id) AS daily_active_users
FROM `firebase-public-project.analytics_153293282.events_*`
GROUP BY event_date
ORDER BY event_date;

-- Quickplay vs Progressive --
SELECT
  CASE WHEN event_name LIKE '%_quickplay' THEN 'Quickplay' ELSE 'Progressive' END AS mode,
  REGEXP_REPLACE(event_name, '_quickplay$', '') AS stage,
  COUNT(*) AS user_count
FROM `firebase-public-project.analytics_153293282.events_*`
WHERE event_name IN (
  'level_start','level_end','level_complete','level_fail','level_retry','level_reset',
  'level_start_quickplay','level_end_quickplay','level_complete_quickplay',
  'level_fail_quickplay','level_retry_quickplay','level_reset_quickplay')
GROUP BY mode, stage;

-- app fails vs. app uninstall users

WITH user_flags AS (
  SELECT
    user_pseudo_id,
    COUNTIF(event_name IN ('level_fail','level_fail_quickplay')) AS fail_count,
    COUNTIF(event_name IN ('app_exception','error')) AS crash_count,
    COUNTIF(event_name = 'app_remove') AS removed
  FROM `firebase-public-project.analytics_153293282.events_*`
  GROUP BY user_pseudo_id)
SELECT
  IF(crash_count > 0, 'Had app error', 'No app error') AS error_group,
  COUNT(*) AS users,
  SUM(removed) AS uninstalled_users,
  ROUND(SAFE_DIVIDE(SUM(removed), COUNT(*)) * 100, 2) AS uninstall_user_pct
FROM user_flags
GROUP BY error_group ;

-- ad vs. currency --
SELECT
  event_name,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS unique_users
FROM `firebase-public-project.analytics_153293282.events_*`
WHERE event_name IN ('no_more_extra_steps','ad_reward','spend_virtual_currency','use_extra_steps')
GROUP BY event_name 
ORDER BY event_count DESC ;

-- Top screens viewed
SELECT
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'firebase_screen_class') AS screen,
  COUNT(*) AS views
FROM `firebase-public-project.analytics_153293282.events_*`
WHERE event_name = 'screen_view'
GROUP BY screen
ORDER BY views DESC
LIMIT 20 ;

-- App breaks by OS/app version
SELECT
  device.operating_system AS os,
  app_info.version AS app_version,
  COUNTIF(event_name IN ('app_exception','error')) AS failed_count
FROM `firebase-public-project.analytics_153293282.events_*`
GROUP BY os, app_version
HAVING failed_count > 0
ORDER BY failed_count DESC ;

-- Active users --
WITH user_activity AS (
  SELECT
    user_pseudo_id,
    COUNTIF(event_name = 'first_open') AS installed,
    COUNTIF(event_name = 'completed_5_levels') AS reached_5_levels
  FROM `firebase-public-project.analytics_153293282.events_*`
  GROUP BY user_pseudo_id)
SELECT
  COUNT(*) AS total_new_users,
  SUM(reached_5_levels) AS activated_users,
  ROUND(SAFE_DIVIDE(SUM(reached_5_levels), COUNT(*)) * 100, 2) AS activation_rate_pct
FROM user_activity
WHERE installed > 0; 

WITH funnel AS (
  SELECT
    CASE WHEN event_name LIKE '%_quickplay' THEN 'Quickplay' ELSE 'Progressive' END AS mode,
    REGEXP_REPLACE(event_name, '_quickplay$', '') AS stage,
    user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
  WHERE event_name IN ('level_start','level_complete','level_start_quickplay','level_complete_quickplay')
),
agg AS (
  SELECT
    mode,
    COUNT(DISTINCT IF(stage='level_start', user_pseudo_id, NULL)) AS started_users,
    COUNT(DISTINCT IF(stage='level_complete', user_pseudo_id, NULL)) AS completed_users
  FROM funnel
  GROUP BY mode
)
SELECT mode, started_users, completed_users,
  ROUND(SAFE_DIVIDE(completed_users, started_users) * 100, 2) AS completion_rate_pct
FROM agg
UNION ALL
SELECT 'Overall', SUM(started_users), SUM(completed_users),
  ROUND(SAFE_DIVIDE(SUM(completed_users), SUM(started_users)) * 100, 2)
FROM agg;

select(
  select value.string_value from unnest(event_params) where key = 'firebase_screen_class')as screen,count(*) as views
from `firebase-public-project.analytics_153293282.events_*`
where event_name = 'screen_view'
group by screen 
order by views desc
limit 6