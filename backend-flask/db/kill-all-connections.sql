

DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM pg_database WHERE datname = 'cruddur') THEN
          SELECT pg_terminate_backend(pid) 
          FROM pg_stat_activity 
          WHERE 
          -- don't kill my own connection!
          pid <> pg_backend_pid()
          -- don't kill the connections to other databases
          AND datname = 'cruddur';
    END IF;
END $$;
