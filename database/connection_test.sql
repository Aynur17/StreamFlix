-- Check our database connection
SELECT current_database() AS database_name,
       current_user AS connected_user,
       version() AS postgresql_version;