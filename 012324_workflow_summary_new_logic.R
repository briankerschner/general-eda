

# ------------------------------
# HERE IS THE NEW QUERY (THE OLD QUERY IS BELOWs)
# ------------------------------

# NOTES:
# BOTH PULL BACK 1930 ROWS
# VISUAL INSPECTION:
# THE NEW LOGIC HAS MORE COMPLETION DATES FILLED, RATHER THAN NULL (AND NOT THE OTHER WAY AROUND) - THIS IS EXPECTED
# THE NEW LOGIC HAS NO_TIME_THROUGH AS 1 LESS THAN THE OL LOGIC, WHEN THE OLD LOGIC HAD A NULL COMPLETION - THIS IS EXPECTED
# THE NEW LOGIC HAS "0" INSTEAD OF "1" TIMES THROUGH WHEN THE OLD LOGIC SHOWED ONLY NULL COMPLETION DATE - THIS IS EXPECTED

# WITH UserWorkflows AS (
#   SELECT 
#   b.workflow_name,
#   b.workflow_description,
#   b.ref_workflow_id,
#   a.user_workflow_id,
#   zz.device_name,
#   c.external_ref_user_id as community_ref_user_id,
#   c.email,
#   c.sso_object_id,
#   a.row_created_datetime_utc AS most_recent_start_date_time_utc,
#   a.completed_datetime_utc AS most_recent_completion_date_time_utc,
#   max_c.most_recent_not_null_completion_date_time_utc,
#   ROW_NUMBER() OVER(PARTITION BY a.ref_user_id,a.ref_workflow_id ORDER BY a.user_workflow_id desc) AS row_number,
#   COUNT(a.ref_user_id) OVER(PARTITION BY a.ref_user_id ,a.ref_workflow_id) AS no_times_through_flow,
#   count_c.no_times_through_flow_not_null AS  no_times_through_flow_not_null,
#   a.row_created_datetime_utc as transaction_datetime_utc
#   FROM user_workflow a
#   JOIN ref_workflow b
#   ON b.ref_workflow_id = a.ref_workflow_id
#   LEFT OUTER JOIN ref_device zz
#   ON zz.ref_device_id = b.ref_device_id
#   JOIN (Select ref_user_id, external_ref_user_id, email, sso_object_id from ref_user where ref_app_id = 2) c
#   ON c.ref_user_id = a.ref_user_id
#   LEFT JOIN ( SELECT a.ref_user_id,
#               b.ref_workflow_id,
#               max(completed_datetime_utc) as most_recent_not_null_completion_date_time_utc
#               FROM user_workflow a
#               JOIN ref_workflow b
#               ON b.ref_workflow_id = a.ref_workflow_id
#               GROUP BY a.ref_user_id,b.ref_workflow_id) max_c 
#   ON max_c.ref_user_id = a.ref_user_id 
#   AND max_c.ref_workflow_id = b.ref_workflow_id
#   LEFT JOIN ( SELECT a.ref_user_id,
#               b.ref_workflow_id,
#               count(completed_datetime_utc) as no_times_through_flow_not_null
#               FROM user_workflow a
#               JOIN ref_workflow b
#               ON b.ref_workflow_id = a.ref_workflow_id
#               GROUP BY a.ref_user_id,b.ref_workflow_id) count_c 
#   ON count_c.ref_user_id = a.ref_user_id 
#   AND count_c.ref_workflow_id = b.ref_workflow_id
#   WHERE a.ref_user_id <> 0
# )
# 
# SELECT a.*
#   FROM UserWorkflows a
# WHERE a.row_number = 1



# ------------------------------
# HERE IS THE OLD QUERY
# ------------------------------

# WITH UserWorkflows AS (
#   SELECT 
#   b.workflow_name,
#   b.workflow_description,
#   a.user_workflow_id,
#   zz.device_name,
#   a.ref_user_id,
#   c.external_ref_user_id as community_ref_user_id,
#   c.email,
#   c.sso_object_id,
#   a.row_created_datetime_utc AS most_recent_start_date_time_utc,
#   a.completed_datetime_utc AS most_recent_completion_date_time_utc,
#   ROW_NUMBER() OVER(PARTITION BY a.ref_user_id,a.ref_workflow_id ORDER BY a.user_workflow_id desc) AS row_number,
#   COUNT(a.ref_user_id) OVER(PARTITION BY a.ref_user_id ,a.ref_workflow_id) AS no_times_through_flow,
#   a.row_created_datetime_utc as transaction_datetime_utc
#   FROM user_workflow a
#   JOIN ref_workflow b
#   ON b.ref_workflow_id = a.ref_workflow_id
#   LEFT OUTER JOIN ref_device zz
#   ON zz.ref_device_id = b.ref_device_id
#   JOIN (Select ref_user_id, external_ref_user_id, email, sso_object_id from ref_user where ref_app_id = 2) c
#   on c.ref_user_id = a.ref_user_id
#   WHERE a.ref_user_id <> 0
#   --AND a.ref_workflow_id = 8
# )
# 
# 
# 
# SELECT a.*
#   FROM UserWorkflows a
# WHERE a.row_number = 1