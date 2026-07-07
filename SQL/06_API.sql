USE FinansijskiSistem;
GO

CREATE OR ALTER PROCEDURE api_finansije.UnesiTransakciju
    @idKompanije INT,
    @iznos DECIMAL(15,2),
    @tipTr NVARCHAR(20),
    @datVreme DATETIME,
    @opis NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_UnesiTransakciju @idKompanije, @iznos, @tipTr, @datVreme, @opis;
END;
GO

CREATE OR ALTER PROCEDURE api_finansije.AzurirajTransakciju
    @id INT,
    @iznos DECIMAL(15,2),
    @tipTr NVARCHAR(20),
    @datVreme DATETIME,
    @opis NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_AzurirajTransakciju @id, @iznos, @tipTr, @datVreme, @opis;
END;
GO

CREATE OR ALTER PROCEDURE api_finansije.ObrisiTransakciju
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_ObrisiTransakciju @id;
END;
GO

CREATE OR ALTER VIEW api_finansije.TRANSAKCIJE
AS
SELECT *
FROM spec.vw_TRANSAKCIJA;
GO

CREATE OR ALTER VIEW api_kontrola.TRANSAKCIJE
AS
SELECT *
FROM spec.vw_TRANSAKCIJA;
GO

CREATE OR ALTER VIEW api_kontrola.AUDIT_LOG
AS
SELECT *
FROM spec.vw_AUDIT_LOG;
GO

CREATE OR ALTER PROCEDURE api_kontrola.KumulativniIzvestaj
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_KumulativniIzvestaj;
END;
GO

CREATE OR ALTER PROCEDURE api_kontrola.PretragaTransakcija
    @pojam NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_PretragaTransakcija @pojam;
END;
GO

CREATE OR ALTER PROCEDURE api_kontrola.AktivniUpiti
AS
BEGIN
    SET NOCOUNT ON;
    EXEC spec.upr_AktivniUpiti;
END;
GO

CREATE SYNONYM api_finansije.syn_UnesiTransakciju FOR spec.upr_UnesiTransakciju;
GO

CREATE SYNONYM api_finansije.syn_AzurirajTransakciju FOR spec.upr_AzurirajTransakciju;
GO

CREATE SYNONYM api_finansije.syn_ObrisiTransakciju FOR spec.upr_ObrisiTransakciju;
GO

CREATE SYNONYM api_kontrola.syn_TRANSAKCIJE FOR spec.vw_TRANSAKCIJA;
GO

CREATE SYNONYM api_kontrola.syn_AUDIT_LOG FOR spec.vw_AUDIT_LOG;
GO
