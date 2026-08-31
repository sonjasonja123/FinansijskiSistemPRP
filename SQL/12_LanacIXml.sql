
USE FinansijskiSistem;
GO

CREATE OR ALTER PROCEDURE spec.upr_LanacAudita
    @idTr INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Numerisano AS
    (
        SELECT
            a.Id,
            a.IdTr,
            a.Akcija,
            a.DatVremeAudit,
            a.Korisnik,
            ROW_NUMBER() OVER (PARTITION BY a.IdTr ORDER BY a.DatVremeAudit, a.Id) AS rn
        FROM impl.tblAuditLog a
        WHERE a.IdTr = @idTr
    ),
    LanacCTE AS
    (
        SELECT
            Id, IdTr, Akcija, DatVremeAudit, Korisnik, rn,
            CAST(1 AS INT) AS NivoDubine
        FROM Numerisano
        WHERE rn = 1

        UNION ALL

        SELECT
            n.Id, n.IdTr, n.Akcija, n.DatVremeAudit, n.Korisnik, n.rn,
            l.NivoDubine + 1
        FROM Numerisano n
        JOIN LanacCTE l ON n.rn = l.rn + 1 AND n.IdTr = l.IdTr
    )
    SELECT
        NivoDubine,
        Id AS IdAuditZapisa,
        IdTr,
        Akcija,
        DatVremeAudit,
        Korisnik
    FROM LanacCTE
    ORDER BY NivoDubine
    OPTION (MAXRECURSION 0);
END;
GO

CREATE OR ALTER PROCEDURE api_kontrola.LanacAudita
    @idTr INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_LanacAudita @idTr;
END;
GO

GRANT EXECUTE ON OBJECT::api_kontrola.LanacAudita TO DataProviderKONTROLA;
GO

CREATE OR ALTER PROCEDURE api_finansije.LanacAudita
    @idTr INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_LanacAudita @idTr;
END;
GO


CREATE OR ALTER PROCEDURE spec.upr_GenerisiXmlIzvestaj
    @idKompanije INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xml XML;

    SELECT @xml =
    (
        SELECT
            k.Id AS '@Id',
            k.Naziv AS '@Naziv',
            k.PIB AS '@PIB',
            k.Email AS '@Email',
            (
                SELECT
                    t.Id AS '@Id',
                    t.TipTr AS '@Tip',
                    t.Iznos AS '@Iznos',
                    t.DatVreme AS '@DatumVreme',
                    t.Opis AS 'Opis'
                FROM impl.tblTransakcija t
                WHERE t.IdKompanije = k.Id
                ORDER BY t.DatVreme
                FOR XML PATH('Transakcija'), TYPE
            ) AS 'Transakcije'
        FROM impl.tblKompanija k
        WHERE k.Id = @idKompanije
        FOR XML PATH('Kompanija'), ROOT('IzvestajTransakcija'), TYPE
    );

    SELECT @xml AS XmlIzvestaj;
END;
GO

CREATE OR ALTER PROCEDURE api_finansije.GenerisiXmlIzvestaj
    @idKompanije INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_GenerisiXmlIzvestaj @idKompanije;
END;
GO

GRANT EXECUTE ON OBJECT::api_finansije.GenerisiXmlIzvestaj TO DataProviderFINANSIJE;
GO

EXEC api_kontrola.LanacAudita @idTr = 1;
GO

EXEC api_finansije.GenerisiXmlIzvestaj @idKompanije = 1;
GO
