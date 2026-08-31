USE FinansijskiSistem;
GO

IF OBJECT_ID('impl.tblTransakcija_Part', 'U') IS NOT NULL
    DROP TABLE impl.tblTransakcija_Part;
GO

IF NOT EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'pf_Transakcija_Godina')
BEGIN
    CREATE PARTITION FUNCTION pf_Transakcija_Godina (DATETIME)
    AS RANGE RIGHT FOR VALUES
    (
        '2025-01-01',
        '2026-01-01',
        '2027-01-01'
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'ps_Transakcija_Godina')
BEGIN
    CREATE PARTITION SCHEME ps_Transakcija_Godina
    AS PARTITION pf_Transakcija_Godina
    ALL TO ([PRIMARY]);
END
GO

IF EXISTS (SELECT 1 FROM sys.fulltext_indexes WHERE object_id = OBJECT_ID('impl.tblTransakcija'))
    DROP FULLTEXT INDEX ON impl.tblTransakcija;
GO

IF OBJECT_ID('impl.trgAuditTransakcija', 'TR') IS NOT NULL
    DROP TRIGGER impl.trgAuditTransakcija;
GO

EXEC sp_rename 'impl.tblTransakcija', 'tblTransakcija_Arhiva';
GO

EXEC sp_rename 'impl.PK_tblTransakcija', 'PK_tblTransakcija_Arhiva';
GO

EXEC sp_rename 'impl.FK_tblTransakcija_tblKompanija', 'FK_tblTransakcija_Arhiva_tblKompanija';
GO

CREATE TABLE impl.tblTransakcija
(
    Id INT IDENTITY(1,1) NOT NULL,
    IdKompanije INT NOT NULL,
    Iznos DECIMAL(15,2) NOT NULL,
    TipTr NVARCHAR(20) NOT NULL,
    DatVreme DATETIME NOT NULL,
    Opis NVARCHAR(MAX) NOT NULL,
    CONSTRAINT PK_tblTransakcija PRIMARY KEY CLUSTERED (Id, DatVreme)
        ON ps_Transakcija_Godina(DatVreme),
    CONSTRAINT FK_tblTransakcija_tblKompanija FOREIGN KEY (IdKompanije)
        REFERENCES impl.tblKompanija(Id),
    CONSTRAINT CK_tblTransakcija_Id CHECK (Id > 0),
    CONSTRAINT CK_tblTransakcija_Iznos CHECK (Iznos <> 0),
    CONSTRAINT CK_tblTransakcija_TipTr CHECK (TipTr IN (N'Приход', N'Расход', N'Пренос', N'Повраћај')),
    CONSTRAINT CK_tblTransakcija_DatVreme CHECK (DatVreme <= GETDATE()),
    CONSTRAINT CK_tblTransakcija_Opis CHECK (LEN(LTRIM(RTRIM(Opis))) > 0)
) ON ps_Transakcija_Godina(DatVreme);
GO

SET IDENTITY_INSERT impl.tblTransakcija ON;
GO

INSERT INTO impl.tblTransakcija (Id, IdKompanije, Iznos, TipTr, DatVreme, Opis)
SELECT Id, IdKompanije, Iznos, TipTr, DatVreme, Opis
FROM impl.tblTransakcija_Arhiva;
GO

SET IDENTITY_INSERT impl.tblTransakcija OFF;
GO

DBCC CHECKIDENT ('impl.tblTransakcija', RESEED);
GO

CREATE INDEX idx_tblTransakcija_IdKompanije
    ON impl.tblTransakcija(IdKompanije)
    ON ps_Transakcija_Godina(DatVreme);
GO

CREATE INDEX idx_tblTransakcija_StatusDatVreme
    ON impl.tblTransakcija (TipTr, DatVreme)
    INCLUDE (IdKompanije, Iznos)
    ON ps_Transakcija_Godina(DatVreme);
GO


IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name = 'ftc_FinansijskiSistem')
    CREATE FULLTEXT CATALOG ftc_FinansijskiSistem AS DEFAULT;
GO

CREATE FULLTEXT INDEX ON impl.tblTransakcija
(
    Opis LANGUAGE 1050
)
KEY INDEX PK_tblTransakcija
ON ftc_FinansijskiSistem;
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

IF OBJECT_ID('spec.syn_ArhivaTransakcija', 'SN') IS NOT NULL
    DROP SYNONYM spec.syn_ArhivaTransakcija;
GO

CREATE SYNONYM spec.syn_ArhivaTransakcija FOR impl.tblTransakcija_Arhiva;
GO

CREATE OR ALTER VIEW spec.vw_ARHIVA_TRANSAKCIJA
AS
SELECT * FROM spec.syn_ArhivaTransakcija;
GO

CREATE OR ALTER VIEW api_kontrola.ARHIVA_TRANSAKCIJA
AS
SELECT * FROM spec.vw_ARHIVA_TRANSAKCIJA;
GO

GRANT SELECT ON api_kontrola.ARHIVA_TRANSAKCIJA TO DataProviderKONTROLA;
GO

SELECT
    $PARTITION.pf_Transakcija_Godina(DatVreme) AS Particija,
    Id, DatVreme, Opis
FROM impl.tblTransakcija
ORDER BY DatVreme;
GO

SELECT * FROM api_kontrola.ARHIVA_TRANSAKCIJA;
GO
