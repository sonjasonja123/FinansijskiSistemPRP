USE master;
GO

IF DB_ID(N'FinansijskiSistem') IS NOT NULL
BEGIN
    ALTER DATABASE FinansijskiSistem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FinansijskiSistem;
END;
GO

CREATE DATABASE FinansijskiSistem
COLLATE Serbian_Cyrillic_100_CI_AS;
GO

ALTER DATABASE FinansijskiSistem SET MULTI_USER;
GO

USE FinansijskiSistem;
GO

CREATE SCHEMA impl;
GO

CREATE SCHEMA spec;
GO

CREATE SCHEMA api_finansije;
GO

CREATE SCHEMA api_kontrola;
GO
