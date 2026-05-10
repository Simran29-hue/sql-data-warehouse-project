/*
CREATE DATABASE AND SCHEMAS
================================================
SCRIPT PURPOSE:
     This script creates a new databbasenamed 'DATAWAREHOUSE' after checking if it already exists.
     If the databse exists, it is dropped and recreated. Additionally, the scriptt sets up three schemaswithin the database: 'bronze', 'silver', and 'gold'. 

WARNING:
      Runninng this sccript will drop the entire 'DATAWAREHOUSE' databse if it exists.
      All data in the database will be permanantly deletd. Proceed with caution
      and ensure you have proper backups before running this scrtipt.
*/


use master;
go

  -- Drop and recreate the 'DATAWAREHOUSE' database
  If EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DATAWAREHOUSE'
  BEGIN 
       ALTER DATABASE DATAWAREHOUSE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
       DROP DATABASE DATAWAREHOUSE;
END;
GO

  
--Create the 'DATAWAREHOUSE' database
CREATE DATABASE DATAWAREHOUSE;
go
  
USE DATAWAREHOUSE;
go

  -- Create Schemas
create schema bronze;
go

create schema gold;
go 

create schema silver1;
go
