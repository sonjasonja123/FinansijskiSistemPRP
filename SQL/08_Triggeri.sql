USE FinansijskiSistem;
GO

CREATE OR ALTER TRIGGER impl.trgAuditTransakcija
ON impl.tblTransakcija
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO impl.tblAuditLog (IdTr, Akcija, Korisnik)
    SELECT
        i.Id,
        CASE WHEN d.Id IS NOT NULL THEN N'UPDATE' ELSE N'INSERT' END,
        SUSER_SNAME()
    FROM inserted i
    LEFT JOIN deleted d ON i.Id = d.Id;
    INSERT INTO impl.tblAuditLog (IdTr, Akcija, Korisnik)
    SELECT
        d.Id,
        N'DELETE',
        SUSER_SNAME()
    FROM deleted d
    LEFT JOIN inserted i ON d.Id = i.Id
    WHERE i.Id IS NULL;
END;
GO
