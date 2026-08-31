USE master;
GO

EXEC sp_configure 'clr enabled', 1;
GO
RECONFIGURE;
GO

DECLARE @hash VARBINARY(64);
SELECT @hash = HASHBYTES('SHA2_512', BulkColumn)
FROM OPENROWSET(BULK 'C:\CLR\FinansijskiSistemCLR.dll', SINGLE_BLOB) AS dll;

IF NOT EXISTS (SELECT 1 FROM sys.trusted_assemblies WHERE hash = @hash)
BEGIN
    EXEC sys.sp_add_trusted_assembly @hash = @hash, @description = N'FinansijskiSistemCLR (v2, EXTERNAL_ACCESS)';
END;
GO

USE FinansijskiSistem;
GO

IF OBJECT_ID('impl.trgClrAuditTransakcija', 'TR') IS NOT NULL
    DROP TRIGGER impl.trgClrAuditTransakcija;
GO

IF OBJECT_ID('impl.PrpProveriNeaktivnost', 'PC') IS NOT NULL
    DROP PROCEDURE impl.PrpProveriNeaktivnost;
GO

DROP ASSEMBLY IF EXISTS FinansijskiSistemCLR;
GO

CREATE ASSEMBLY FinansijskiSistemCLR
FROM 'C:\CLR\FinansijskiSistemCLR.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS;
GO

CREATE TRIGGER impl.trgClrAuditTransakcija
ON impl.tblTransakcija
AFTER INSERT, UPDATE, DELETE
AS EXTERNAL NAME FinansijskiSistemCLR.TransakcijaClrTrigger.trgClrAuditTransakcija;
GO

DISABLE TRIGGER impl.trgClrAuditTransakcija ON impl.tblTransakcija;
GO

CREATE PROCEDURE impl.PrpProveriNeaktivnost
AS EXTERNAL NAME FinansijskiSistemCLR.PrpMonitoring.PrpProveriNeaktivnost;
GO

CREATE OR ALTER PROCEDURE spec.upr_ProveriNeaktivneKompanije
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    EXEC impl.PrpProveriNeaktivnost;
END;
GO

CREATE OR ALTER PROCEDURE api_finansije.ProveriNeaktivneKompanije
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_ProveriNeaktivneKompanije;
END;
GO

GRANT EXECUTE ON OBJECT::api_finansije.ProveriNeaktivneKompanije TO DataProviderFINANSIJE;
GO

SELECT name, permission_set_desc FROM sys.assemblies WHERE name = 'FinansijskiSistemCLR';
GO

EXEC api_finansije.ProveriNeaktivneKompanije;
GO

