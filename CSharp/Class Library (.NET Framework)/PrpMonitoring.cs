using System;
using System.Data.SqlClient;
using System.Diagnostics;
using Microsoft.SqlServer.Server;


public class PrpMonitoring
{
    private const string EventSourceName = "FinansijskiSistem";
    private const string EventLogName = "Application";
    private const int PragBrojDana = 7;

    [SqlProcedure]
    public static void PrpProveriNeaktivnost()
    {
        try
        {
            using (SqlConnection connection = new SqlConnection("context connection=true"))
            {
                connection.Open();

                string sql = @"
                    SELECT k.Id, k.Naziv, MAX(t.DatVreme) AS PoslednjaTransakcija
                    FROM impl.tblKompanija k
                    LEFT JOIN impl.tblTransakcija t ON t.IdKompanije = k.Id
                    GROUP BY k.Id, k.Naziv
                    HAVING MAX(t.DatVreme) IS NULL
                        OR DATEDIFF(DAY, MAX(t.DatVreme), GETDATE()) > @PragBrojDana;";

                using (SqlCommand command = new SqlCommand(sql, connection))
                {
                    command.Parameters.AddWithValue("@PragBrojDana", PragBrojDana);

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        int brojUpozorenja = 0;

                        while (reader.Read())
                        {
                            int idKompanije = reader.GetInt32(0);
                            string naziv = reader.GetString(1);

                            string poruka = string.Format(
                                "Kompanija '{0}' (Id={1}) nema evidentiranih transakcija u poslednjih {2} dana.",
                                naziv, idKompanije, PragBrojDana);

                            UpisiUEventLog(poruka, EventLogEntryType.Warning);
                            brojUpozorenja++;
                        }

                        SqlContext.Pipe.Send(string.Format("Provera zavrsena. Upozorenja upisana u Event Log: {0}.", brojUpozorenja));
                    }
                }
            }
        }
        catch (SqlException sqlEx)
        {
            UpisiUEventLog(
                "Greska pri proveri neaktivnih kompanija (SqlException): " + sqlEx.Message,
                EventLogEntryType.Error);
        }
    }

    private static void UpisiUEventLog(string message, EventLogEntryType type)
    {
        try
        {
            if (!EventLog.SourceExists(EventSourceName))
                EventLog.CreateEventSource(EventSourceName, EventLogName);

            EventLog.WriteEntry(EventSourceName, message, type);
        }
        catch
        {
        }
    }
}
