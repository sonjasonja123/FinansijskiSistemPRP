USE FinansijskiSistem;
GO

CREATE OR ALTER VIEW spec.vw_TRANSAKCIJA
AS
SELECT
    t.Id,
    t.IdKompanije,
    k.Naziv AS NazivKompanije,
    k.PIB,
    t.Iznos,
    t.TipTr,
    t.DatVreme,
    t.Opis
FROM impl.tblTransakcija t
JOIN impl.tblKompanija k ON t.IdKompanije = k.Id;
GO

CREATE OR ALTER VIEW spec.vw_AUDIT_LOG
AS
SELECT
    a.Id,
    a.IdTr,
    a.Akcija,
    a.DatVremeAudit,
    a.Korisnik
FROM impl.tblAuditLog a;
GO

CREATE OR ALTER PROCEDURE spec.upr_UnesiTransakciju
    @idKompanije INT,
    @iznos DECIMAL(15,2),
    @tipTr NVARCHAR(20),
    @datVreme DATETIME,
    @opis NVARCHAR(MAX)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        INSERT INTO impl.tblTransakcija (IdKompanije, Iznos, TipTr, DatVreme, Opis)
        VALUES (@idKompanije, @iznos, @tipTr, @datVreme, @opis);
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE spec.upr_AzurirajTransakciju
    @id INT,
    @iznos DECIMAL(15,2),
    @tipTr NVARCHAR(20),
    @datVreme DATETIME,
    @opis NVARCHAR(MAX)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        UPDATE impl.tblTransakcija
        SET Iznos = @iznos,
            TipTr = @tipTr,
            DatVreme = @datVreme,
            Opis = @opis
        WHERE Id = @id;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE spec.upr_ObrisiTransakciju
    @id INT
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        DELETE FROM impl.tblTransakcija
        WHERE Id = @id;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE spec.upr_KumulativniIzvestaj
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH MesecniPodaci AS
    (
        SELECT
            k.Id AS IdKompanije,
            k.Naziv AS NazivKompanije,
            DATEFROMPARTS(YEAR(t.DatVreme), MONTH(t.DatVreme), 1) AS Mesec,
            SUM(CASE WHEN t.TipTr = N'Приход' THEN t.Iznos ELSE 0 END) AS Prihod,
            SUM(CASE WHEN t.TipTr = N'Расход' THEN ABS(t.Iznos) ELSE 0 END) AS Rashod
        FROM impl.tblTransakcija t
        JOIN impl.tblKompanija k ON t.IdKompanije = k.Id
        GROUP BY k.Id, k.Naziv, DATEFROMPARTS(YEAR(t.DatVreme), MONTH(t.DatVreme), 1)
    ),
    Numerisano AS
    (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY IdKompanije ORDER BY Mesec) AS rn
        FROM MesecniPodaci
    ),
    RekurzivniCTE AS
    (
        SELECT IdKompanije, NazivKompanije, Mesec, Prihod, Rashod, Prihod AS KumulativniPrihod, Rashod AS KumulativniRashod, rn
        FROM Numerisano
        WHERE rn = 1
        UNION ALL
        SELECT n.IdKompanije, n.NazivKompanije, n.Mesec, n.Prihod, n.Rashod, r.KumulativniPrihod + n.Prihod, r.KumulativniRashod + n.Rashod, n.rn
        FROM Numerisano n
        JOIN RekurzivniCTE r ON n.IdKompanije = r.IdKompanije AND n.rn = r.rn + 1
    )
    SELECT IdKompanije, NazivKompanije, Mesec, Prihod, Rashod, KumulativniPrihod, KumulativniRashod
    FROM RekurzivniCTE
    ORDER BY IdKompanije, Mesec
    OPTION (MAXRECURSION 0);
END;
GO

CREATE OR ALTER PROCEDURE spec.upr_PretragaTransakcija
    @pojam NVARCHAR(100)
WITH ENCRYPTION
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.Id,
        t.IdKompanije,
        k.Naziv AS NazivKompanije,
        k.PIB,
        t.Iznos,
        t.TipTr,
        t.DatVreme,
        t.Opis
    FROM impl.tblTransakcija t
    JOIN impl.tblKompanija k ON t.IdKompanije = k.Id
    WHERE CONTAINS(t.Opis, @pojam);
END;
GO

CREATE OR ALTER PROCEDURE spec.upr_AktivniUpiti
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        r.session_id,
        r.status,
        r.command,
        r.cpu_time,
        r.total_elapsed_time,
        r.reads,
        r.writes,
        DB_NAME(r.database_id) AS DatabaseName,
        SUBSTRING(t.text, (r.statement_start_offset / 2) + 1, (CASE WHEN r.statement_end_offset = -1 THEN LEN(CONVERT(NVARCHAR(MAX), t.text)) * 2 ELSE r.statement_end_offset END - r.statement_start_offset) / 2 + 1) AS SqlText
    FROM sys.dm_exec_requests r
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
    WHERE r.session_id <> @@SPID;
END;
GO
