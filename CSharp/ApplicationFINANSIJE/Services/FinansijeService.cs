using Microsoft.Data.SqlClient;
using System.Data;

namespace ApplicationFINANSIJE.Services;

public class FinansijeService
{
    private readonly SqlConnection _connection;

    public FinansijeService(SqlConnection connection)
    {
        _connection = connection;
    }

    public void AktivirajUlogu()
    {
        using SqlCommand roleCommand = new SqlCommand("sp_setapprole", _connection);
        roleCommand.CommandType = CommandType.StoredProcedure;
        roleCommand.Parameters.AddWithValue("@rolename", "DataProviderFINANSIJE");
        roleCommand.Parameters.AddWithValue("@password", "Fin@nsije2025!");
        roleCommand.ExecuteNonQuery();
    }

    public void UnesiTransakciju()
    {
        Console.Write("Id kompanije: ");
        int idKompanije = int.Parse(Console.ReadLine()!);

        Console.Write("Iznos: ");
        decimal iznos = decimal.Parse(Console.ReadLine()!);

        Console.Write("Tip transakcije (Приход/Расход/Пренос/Повраћај): ");
        string tipTr = Console.ReadLine()!;

        Console.Write("Opis: ");
        string opis = Console.ReadLine()!;

        using SqlCommand cmd = new SqlCommand("api_finansije.UnesiTransakciju", _connection);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.AddWithValue("@idKompanije", idKompanije);
        cmd.Parameters.AddWithValue("@iznos", iznos);
        cmd.Parameters.AddWithValue("@tipTr", tipTr);
        cmd.Parameters.AddWithValue("@datVreme", DateTime.Now);
        cmd.Parameters.AddWithValue("@opis", opis);

        cmd.ExecuteNonQuery();

        Console.WriteLine("Transakcija je uspešno uneta.");
    }

    public void AzurirajTransakciju()
    {
        Console.Write("Id transakcije: ");
        int id = int.Parse(Console.ReadLine()!);

        Console.Write("Novi iznos: ");
        decimal iznos = decimal.Parse(Console.ReadLine()!);

        Console.Write("Tip transakcije (Приход/Расход/Пренос/Повраћај): ");
        string tipTr = Console.ReadLine()!;

        Console.Write("Novi opis: ");
        string opis = Console.ReadLine()!;

        using SqlCommand cmd = new SqlCommand("api_finansije.AzurirajTransakciju", _connection);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.AddWithValue("@id", id);
        cmd.Parameters.AddWithValue("@iznos", iznos);
        cmd.Parameters.AddWithValue("@tipTr", tipTr);
        cmd.Parameters.AddWithValue("@datVreme", DateTime.Now);
        cmd.Parameters.AddWithValue("@opis", opis);

        cmd.ExecuteNonQuery();

        Console.WriteLine("Transakcija je uspešno ažurirana.");
    }

    public void ObrisiTransakciju()
    {
        Console.Write("Id transakcije za brisanje: ");
        int id = int.Parse(Console.ReadLine()!);

        using SqlCommand cmd = new SqlCommand("api_finansije.ObrisiTransakciju", _connection);
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@id", id);

        cmd.ExecuteNonQuery();

        Console.WriteLine("Transakcija je uspešno obrisana.");
    }
    public void PrikaziTransakcije()
    {
        Console.WriteLine("=== TRANSAKCIJE ===");

        using SqlCommand cmd = new SqlCommand("SELECT * FROM api_finansije.TRANSAKCIJE", _connection);
        using SqlDataReader reader = cmd.ExecuteReader();

        while (reader.Read())
        {
            Console.WriteLine(
                $"{reader["Id"]} | {reader["NazivKompanije"]} | {reader["Iznos"]} | {reader["TipTr"]} | {reader["DatVreme"]} | {reader["Opis"]}"
            );
        }
    }
}