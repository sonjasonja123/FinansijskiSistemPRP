USE FinansijskiSistem_TEST;
GO

SELECT N'01_Tabele_Kompanija' AS Test;
SELECT * FROM impl.tblKompanija;
GO

SELECT N'02_Tabele_Transakcija' AS Test;
SELECT * FROM impl.tblTransakcija;
GO

SELECT N'03_Tabele_AuditLog_Pre_Akcija' AS Test;
SELECT * FROM impl.tblAuditLog ORDER BY Id;
GO

SELECT N'04_Spec_Pogled_Transakcija' AS Test;
SELECT * FROM spec.vw_TRANSAKCIJA ORDER BY Id;
GO

SELECT N'05_Spec_Pogled_Audit' AS Test;
SELECT * FROM spec.vw_AUDIT_LOG ORDER BY Id;
GO

SELECT N'06_API_Pogledi' AS Test;
SELECT * FROM api_finansije.TRANSAKCIJE ORDER BY Id;
SELECT * FROM api_kontrola.TRANSAKCIJE ORDER BY Id;
SELECT * FROM api_kontrola.AUDIT_LOG ORDER BY Id;
GO

SELECT N'07_API_Unos' AS Test;
EXEC api_finansije.UnesiTransakciju
    @idKompanije = 1,
    @iznos = 12345,
    @tipTr = N'Приход',
    @datVreme = '2025-04-10T10:00:00',
    @opis = N'Тест трансакција за одбрану';
SELECT TOP 1 * FROM impl.tblTransakcija ORDER BY Id DESC;
SELECT TOP 5 * FROM impl.tblAuditLog ORDER BY Id DESC;
GO

SELECT N'08_API_Azuriranje' AS Test;
DECLARE @idZaIzmenu INT;
SELECT @idZaIzmenu = MAX(Id) FROM impl.tblTransakcija;
EXEC api_finansije.AzurirajTransakciju
    @id = @idZaIzmenu,
    @iznos = 15000,
    @tipTr = N'Приход',
    @datVreme = '2025-04-10T11:00:00',
    @opis = N'Измењена тест трансакција за одбрану';
SELECT TOP 1 * FROM impl.tblTransakcija ORDER BY Id DESC;
SELECT TOP 5 * FROM impl.tblAuditLog ORDER BY Id DESC;
GO

SELECT N'09_API_Brisanje' AS Test;
EXEC api_finansije.UnesiTransakciju
    @idKompanije = 2,
    @iznos = 7777,
    @tipTr = N'Приход',
    @datVreme = '2025-04-11T10:00:00',
    @opis = N'Тест трансакција за брисање';
DECLARE @idZaBrisanje INT;
SELECT @idZaBrisanje = MAX(Id) FROM impl.tblTransakcija;
EXEC api_finansije.ObrisiTransakciju @id = @idZaBrisanje;
SELECT TOP 10 * FROM impl.tblAuditLog ORDER BY Id DESC;
GO

SELECT N'10_Kumulativni_Izvestaj' AS Test;
EXEC api_kontrola.KumulativniIzvestaj;
GO

SELECT N'11_FullText_Pretraga' AS Test;
EXEC api_kontrola.PretragaTransakcija @pojam = N'"логистичке"';
GO

SELECT N'12_Partition' AS Test;
SELECT
    $PARTITION.pf_Transakcija_Godina(DatVreme) AS Particija,
    Id,
    DatVreme,
    Opis
FROM impl.tblTransakcija
ORDER BY DatVreme;
GO

SELECT N'13_DMV_Aktivni_Upiti' AS Test;
EXEC api_kontrola.AktivniUpiti;
GO

USE FinansijskiSistem_TEST;
GO

SELECT '14_CLR_Trigger' AS Test;

SELECT 
    name,
    is_disabled
FROM sys.triggers
WHERE name = 'trgClrAuditTransakcija';
GO

EXEC api_finansije.UnesiTransakciju
    @idKompanije = 1,
    @iznos = 22222,
    @tipTr = N'Приход',
    @datVreme = '2025-04-20T12:00:00',
    @opis = N'Тест CLR тригера';
GO

SELECT TOP 10
    Id,
    IdTr,
    Akcija,
    DatVremeAudit,
    Korisnik
FROM impl.tblAuditLog
ORDER BY Id DESC;
GO

SELECT N'15_Finalna_Provera' AS Test;
SELECT * FROM spec.vw_TRANSAKCIJA ORDER BY Id;
SELECT * FROM spec.vw_AUDIT_LOG ORDER BY Id DESC;
GO
