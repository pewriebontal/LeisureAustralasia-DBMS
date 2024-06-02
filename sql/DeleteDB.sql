-- This script deletes the database LeisureAustralasiaDB

-- If the database is in use, it will not be deleted.
-- So, you need to kill all the sessions that are using the database. (See Kill.sql)
-- Then, you can delete the database.


-- CAUTION: This script will delete the database LeisureAustralasiaDB.
-- ONLY RUN IF YOU KNOW WHAT YOU ARE DOING.

DROP DATABASE LeisureAustralasiaDB;
GO
-- IF CANNOt DROP DATABASE, FOLLOW Steps in Kill.sql