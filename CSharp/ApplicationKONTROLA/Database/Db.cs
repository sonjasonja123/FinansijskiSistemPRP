using Microsoft.Data.SqlClient;

namespace ApplicationKONTROLA.Database;

public static class Db
{
    public static SqlConnection OpenConnection()
    {
        string connectionString =
            "Server=localhost;Database=FinansijskiSistem;Trusted_Connection=True;TrustServerCertificate=True;";

        SqlConnection connection = new SqlConnection(connectionString);
        connection.Open();

        return connection;
    }
}