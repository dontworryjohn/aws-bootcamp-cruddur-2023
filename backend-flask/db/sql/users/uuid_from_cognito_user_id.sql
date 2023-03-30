SELECT
    users.uuid
FROM public.users
WHERE
    user.cognito_user_id=%(cognito_user_id)s
LIMIT 1