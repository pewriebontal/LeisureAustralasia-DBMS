-- Kill all connections to the database
-- RUN THIS SCRIPT IF YOU CANNOT DROP THE DATABASE


-- This will show all the sessions that are using the database.
-- You can kill the sessions using the KILL command.
-- Uncomment the KILL command to kill the session.


SELECT *
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('LeisureAustralasiaDB');

-- Uncomment this line to kill the session. For example, KILL 51;

-- KILL 00; -- replace 00 with the session_id that you want to kill.