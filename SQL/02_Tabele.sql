USE FinansijskiSistem;
GO

CREATE TABLE impl.tblKompanija
(
    Id INT IDENTITY(1,1) NOT NULL,
    Naziv NVARCHAR(200) NOT NULL,
    PIB CHAR(9) NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_tblKompanija PRIMARY KEY (Id),
    CONSTRAINT UQ_tblKompanija_Naziv UNIQUE (Naziv),
    CONSTRAINT UQ_tblKompanija_PIB UNIQUE (PIB),
    CONSTRAINT CK_tblKompanija_Id CHECK (Id > 0),
    CONSTRAINT CK_tblKompanija_Naziv CHECK (LEN(LTRIM(RTRIM(Naziv))) > 0),
    CONSTRAINT CK_tblKompanija_PIB CHECK (LEN(PIB) = 9 AND PIB NOT LIKE '%[^0-9]%'),
    CONSTRAINT CK_tblKompanija_Email CHECK (Email LIKE '%@%.%')
);
GO

CREATE TABLE impl.tblTransakcija
(
    Id INT IDENTITY(1,1) NOT NULL,
    IdKompanije INT NOT NULL,
    Iznos DECIMAL(15,2) NOT NULL,
    TipTr NVARCHAR(20) NOT NULL,
    DatVreme DATETIME NOT NULL,
    Opis NVARCHAR(MAX) NOT NULL,
    CONSTRAINT PK_tblTransakcija PRIMARY KEY (Id),
    CONSTRAINT FK_tblTransakcija_tblKompanija FOREIGN KEY (IdKompanije) REFERENCES impl.tblKompanija(Id),
    CONSTRAINT CK_tblTransakcija_Id CHECK (Id > 0),
    CONSTRAINT CK_tblTransakcija_Iznos CHECK (Iznos <> 0),
    CONSTRAINT CK_tblTransakcija_TipTr CHECK (TipTr IN (N'Приход', N'Расход', N'Пренос', N'Повраћај')),
    CONSTRAINT CK_tblTransakcija_DatVreme CHECK (DatVreme <= GETDATE()),
    CONSTRAINT CK_tblTransakcija_Opis CHECK (LEN(LTRIM(RTRIM(Opis))) > 0)
);
GO

CREATE TABLE impl.tblAuditLog
(
    Id INT IDENTITY(1,1) NOT NULL,
    IdTr INT NOT NULL,
    Akcija NVARCHAR(20) NOT NULL,
    DatVremeAudit DATETIME NOT NULL CONSTRAINT DF_tblAuditLog_DatVremeAudit DEFAULT GETDATE(),
    Korisnik NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_tblAuditLog PRIMARY KEY (Id),
    CONSTRAINT CK_tblAuditLog_Id CHECK (Id > 0),
    CONSTRAINT CK_tblAuditLog_IdTr CHECK (IdTr > 0),
    CONSTRAINT CK_tblAuditLog_Akcija CHECK (Akcija IN (N'INSERT', N'UPDATE', N'DELETE')),
    CONSTRAINT CK_tblAuditLog_DatVremeAudit CHECK (DatVremeAudit <= GETDATE()),
    CONSTRAINT CK_tblAuditLog_Korisnik CHECK (LEN(LTRIM(RTRIM(Korisnik))) > 0)
);
GO

CREATE INDEX idx_tblTransakcija_IdKompanije ON impl.tblTransakcija(IdKompanije);
GO

CREATE INDEX idx_tblTransakcija_DatVreme ON impl.tblTransakcija(DatVreme);
GO

CREATE INDEX idx_tblAuditLog_IdTr ON impl.tblAuditLog(IdTr);
GO
