using Microsoft.Data.SqlClient;
using System.Data;

namespace ApplicationKONTROLA.Services;

public class KontrolaService
{
    private readonly SqlConnection _connection;

    public KontrolaService(SqlConnection connection)
    {
        _connection = connection;
    }

    public void AktivirajUlogu()
    {
        using SqlCommand roleCommand = new SqlCommand("sp_setapprole", _connection);
        roleCommand.CommandType = CommandType.StoredProcedure;
        roleCommand.Parameters.AddWithValue("@rolename", "DataProviderKONTROLA");
        roleCommand.Parameters.AddWithValue("@password", "K0ntr0la2025!");
        roleCommand.ExecuteNonQuery();
    }

    public void PrikaziTransakcije()
    {
        Console.WriteLine("=== TRANSAKCIJE ===");

        using SqlCommand cmd = new SqlCommand("SELECT * FROM api_kontrola.TRANSAKCIJE", _connection);
        using SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            Console.WriteLine(
                $"{reader["Id"]} | {reader["NazivKompanije"]} | {reader["Iznos"]} | {reader["TipTr"]} | {reader["Opis"]}"
            );
        }
    }

    public void PrikaziAuditLog()
    {
        Console.WriteLine("=== AUDIT LOG ===");

        using SqlCommand cmd = new SqlCommand("SELECT * FROM api_kontrola.AUDIT_LOG", _connection);
        using SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            Console.WriteLine(
                $"{reader["Id"]} | Tr:{reader["IdTr"]} | {reader["Akcija"]} | {reader["DatVremeAudit"]} | {reader["Korisnik"]}"
            );
        }
    }
    public void PrikaziKumulativniIzvestaj()
    {
        Console.WriteLine("=== KUMULATIVNI IZVEŠTAJ ===");

        using SqlCommand cmd = new SqlCommand("api_kontrola.KumulativniIzvestaj", _connection);
        cmd.CommandType = CommandType.StoredProcedure;

        
        using SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            Console.WriteLine(
                $"{reader["IdKompanije"]} | {reader["NazivKompanije"]} | {reader["Mesec"]} | Prihod: {reader["Prihod"]} | Rashod: {reader["Rashod"]} | Kum. prihod: {reader["KumulativniPrihod"]} | Kum. rashod: {reader["KumulativniRashod"]}"
            );
        }
    }

    public void PretraziTransakcije()
    {
        Console.Write("Unesi pojam za pretragu: ");
        string pojam = Console.ReadLine()!;

        string fullTextPojam = $"\"{pojam}\"";

        using SqlCommand cmd = new SqlCommand("api_kontrola.PretragaTransakcija", _connection);
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@pojam", fullTextPojam);

        using SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            Console.WriteLine(
                $"{reader["Id"]} | {reader["NazivKompanije"]} | {reader["Iznos"]} | {reader["TipTr"]} | {reader["Opis"]}"
            );
        }
    }
}