
CREATE USER app_iam_user;
GRANT rds_iam TO app_iam_user;
GRANT CONNECT ON DATABASE ujjvalauroraaws TO app_iam_user;

GRANT USAGE ON SCHEMA USER_SCHEMA TO app_iam_user;
GRANT CREATE on SCHEMA USER_SCHEMA to app_iam_user;

ALTER USER app_iam_user WITH LOGIN;