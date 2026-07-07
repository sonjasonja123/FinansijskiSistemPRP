
using ApplicationKONTROLA.Database;
using ApplicationKONTROLA.Services;

Console.OutputEncoding = System.Text.Encoding.UTF8;
Console.InputEncoding = System.Text.Encoding.UTF8;

using var connection = Db.OpenConnection();

Console.WriteLine("Povezano na FinansijskiSistem.");

KontrolaService kontrolaService = new KontrolaService(connection);
kontrolaService.AktivirajUlogu();

Console.WriteLine("Aktivirana uloga DataProviderKONTROLA.");
Console.WriteLine();

while (true)
{
    Console.WriteLine("=== APPLICATION KONTROLA ===");
    Console.WriteLine("1. Prikaži transakcije");
    Console.WriteLine("2. Prikaži audit log");
    Console.WriteLine("3. Kumulativni izveštaj");
    Console.WriteLine("4. Full-Text pretraga");
    Console.WriteLine("0. Izlaz");
    Console.Write("Izbor: ");

    string? izbor = Console.ReadLine();
    Console.WriteLine();

    if (izbor == "0")
        break;

    if (izbor == "1")
        kontrolaService.PrikaziTransakcije();
    else if (izbor == "2")
        kontrolaService.PrikaziAuditLog();
    else if (izbor == "3")
        kontrolaService.PrikaziKumulativniIzvestaj();
    else if (izbor == "4")
        kontrolaService.PretraziTransakcije();
    else
        Console.WriteLine("Nepoznata opcija.");

    Console.WriteLine();
}