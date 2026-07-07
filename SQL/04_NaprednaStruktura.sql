USE FinansijskiSistem;
GO

CREATE PARTITION FUNCTION pf_Transakcija_Godina (DATETIME)
AS RANGE RIGHT FOR VALUES
(
    '2025-01-01',
    '2026-01-01',
    '2027-01-01'
);
GO

CREATE PARTITION SCHEME ps_Transakcija_Godina
AS PARTITION pf_Transakcija_Godina
ALL TO ([PRIMARY]);
GO

CREATE TABLE impl.tblTransakcija_Part
(
    Id INT NOT NULL,
    IdKompanije INT NOT NULL,
    Iznos DECIMAL(15,2) NOT NULL,
    TipTr NVARCHAR(20) NOT NULL,
    DatVreme DATETIME NOT NULL,
    Opis NVARCHAR(MAX) NOT NULL,
    CONSTRAINT PK_tblTransakcija_Part PRIMARY KEY CLUSTERED (Id, DatVreme) ON ps_Transakcija_Godina(DatVreme),
    CONSTRAINT FK_tblTransakcija_Part_tblKompanija FOREIGN KEY (IdKompanije) REFERENCES impl.tblKompanija(Id),
    CONSTRAINT CK_tblTransakcija_Part_Iznos CHECK (Iznos <> 0),
    CONSTRAINT CK_tblTransakcija_Part_TipTr CHECK (TipTr IN (N'Приход', N'Расход', N'Пренос', N'Повраћај')),
    CONSTRAINT CK_tblTransakcija_Part_DatVreme CHECK (DatVreme <= GETDATE()),
    CONSTRAINT CK_tblTransakcija_Part_Opis CHECK (LEN(LTRIM(RTRIM(Opis))) > 0)
) ON ps_Transakcija_Godina(DatVreme);
GO

INSERT INTO impl.tblTransakcija_Part (Id, IdKompanije, Iznos, TipTr, DatVreme, Opis)
SELECT Id, IdKompanije, Iznos, TipTr, DatVreme, Opis
FROM impl.tblTransakcija;
GO

CREATE INDEX idx_tblTransakcija_Part_StatusDatVreme
ON impl.tblTransakcija_Part (TipTr, DatVreme)
INCLUDE (IdKompanije, Iznos);
GO

CREATE FULLTEXT CATALOG ftc_FinansijskiSistem AS DEFAULT;
GO

CREATE FULLTEXT INDEX ON impl.tblTransakcija
(
    Opis LANGUAGE 1050
)
KEY INDEX PK_tblTransakcija
ON ftc_FinansijskiSistem;
GO
