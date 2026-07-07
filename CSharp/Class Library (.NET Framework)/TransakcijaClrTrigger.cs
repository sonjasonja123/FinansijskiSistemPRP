using System.Data.SqlClient;
using Microsoft.SqlServer.Server;

public class TransakcijaClrTrigger
{
    [SqlTrigger(
        Name = "trgClrAuditTransakcija",
        Target = "impl.tblTransakcija",
        Event = "FOR INSERT, UPDATE, DELETE"
    )]
    public static void trgClrAuditTransakcija()
    {
        SqlTriggerContext context = SqlContext.TriggerContext;

        string akcija = "UNKNOWN";

        if (context.TriggerAction == TriggerAction.Insert)
            akcija = "INSERT";
        else if (context.TriggerAction == TriggerAction.Update)
            akcija = "UPDATE";
        else if (context.TriggerAction == TriggerAction.Delete)
            akcija = "DELETE";

        string sourceTable;

        if (akcija == "DELETE")
            sourceTable = "deleted";
        else
            sourceTable = "inserted";

        using (SqlConnection connection = new SqlConnection("context connection=true"))
        {
            connection.Open();

            string sql = @"
                INSERT INTO impl.tblAuditLog (IdTr, Akcija, Korisnik)
                SELECT Id, @Akcija, SUSER_SNAME()
                FROM " + sourceTable;

            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.AddWithValue("@Akcija", akcija);
                command.ExecuteNonQuery();
            }
        }
    }
}