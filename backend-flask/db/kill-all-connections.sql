DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'cruddur') THEN
        RAISE NOTICE 'Killing all the users active!';
        PERFORM (
            SELECT pg_terminate_backend(pid) 
            FROM pg_stat_activity 
            WHERE pid <> pg_backend_pid()
            AND datname = 'cruddur'
        );
    END IF;
END $$;