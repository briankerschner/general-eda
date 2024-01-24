
library(bigrquery)
library(here)
library(dplyr)

# ---------------------------
# PULL THE DATAs
# ---------------------------

projectid = "protected-00-349215"

summary <- bq_table_download(
             bq_project_query(projectid, 
                              "SELECT * 
                               FROM `protected-00-349215.person_output.lore_workflow_summary`"
          ))

details <- bq_table_download(
            bq_project_query(projectid, 
                             "SELECT * 
                              FROM `protected-00-349215.person_output.lore_workflow_details`"
          ))

# ---------------------------
# REF_USER_ID OVERLAP
# ---------------------------

# SUMMARY OF WHAT I FOUND:
### USERS IN DETAIL, NOT IN SUMMARY - NONE
### USERS IN SUMMARY, NOT IN DETAILS - USERS THAT STARTED A WORKFLOW, DIDN'T COMPLETE AN ANSWER

users_details <- details %>% distinct(ref_user_id) %>% mutate(in_details=1)
users_summary <- summary %>% distinct(ref_user_id) %>% mutate(in_summary=1)

users_overlap <- users_details %>% 
                 full_join(users_summary)

# REF_USER_ID #893
## PROCEEDED THROUGH TWO STEPS (REF_WORKFLOW_STEP_ID) - 39, 33 
## DIDN'T ANSWER 33, ****BUT DID ANSWER 39**** ? - 39 HAS A NULL VALUE

# REF_USER_ID #488
## PROCEEDED THROUGH TWO STEPS (REF_WORKFLOW_STEP_ID) - 41,42 
## DIDN'T ANSWER 42, ****BUT DID ANSWER 41**** ? DON'T UNDERSTAND WHAT THIS IS REALLY

# REF_USER_ID #3
## PROCEEDED THROUGH A SINGLE STEP (REF_WORKFLOW_STEP_ID) - 17, 
## BUT DIDN'T ANSWER ANYTHING, NO RECORD IN 'user_workflow_step_question_answer'
s
# REF_USER_ID #106
## PROCEEDED THROUGH A SINGLE STEP (REF_WORKFLOW_STEP_ID) - 17, 
## BUT DIDN'T ANSWER ANYTHING, NO RECORD IN 'user_workflow_step_question_answer'

# ---------------------------
# COMMUNITY_REF_USER_ID_OVERLAP
# ---------------------------

com_users_details <- details %>% distinct(community_ref_user_id) %>% mutate(in_details=1)
com_users_summary <- summary %>% distinct(community_ref_user_id) %>% mutate(in_summary=1)

#SAME AS ABOVE AT THE USER ID LEVEL
com_users_overlap <- com_users_details %>% 
                     full_join(com_users_summary)

workflow_count_details <- details %>% 
                          distinct(community_ref_user_id,workflow_description) %>%
                          group_by(workflow_description) %>%
                          summarise(n_details=n())

workflow_count_summary <- summary %>% 
                          distinct(community_ref_user_id,workflow_description) %>%
                          group_by(workflow_description) %>%
                          summarise(n_summary=n())


workflow_overlap <- workflow_count_summary %>%
                    left_join(workflow_count_details)

workflow_overlap_other_way <- workflow_count_details %>%
                              left_join(workflow_count_summary)

workflow_overlap_full <- workflow_count_details %>%
                         full_join(workflow_count_summary)


total <- workflow_overlap_full %>%
         summarise(across(where(is.numeric), sum, na.rm = TRUE))

total$label <- "Total" # Add a label column to the total

workflow_overlap_full_with_totals <- bind_rows(workflow_overlap_full,total)


