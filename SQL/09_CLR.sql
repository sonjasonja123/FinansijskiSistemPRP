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
    EXEC sys.sp_add_trusted_assembly @hash = @hash, @description = N'FinansijskiSistemCLR';
END;
GO

USE FinansijskiSistem;
GO

DROP TRIGGER IF EXISTS impl.trgClrAuditTransakcija;
GO

DROP ASSEMBLY IF EXISTS FinansijskiSistemCLR;
GO

CREATE ASSEMBLY FinansijskiSistemCLR
FROM 'C:\CLR\FinansijskiSistemCLR.dll'
WITH PERMISSION_SET = SAFE;
GO

CREATE TRIGGER impl.trgClrAuditTransakcija
ON impl.tblTransakcija
AFTER INSERT, UPDATE, DELETE
AS EXTERNAL NAME FinansijskiSistemCLR.TransakcijaClrTrigger.trgClrAuditTransakcija;
GO

DISABLE TRIGGER impl.trgClrAuditTransakcija ON impl.tblTransakcija;
GO
