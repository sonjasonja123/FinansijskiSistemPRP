using ApplicationFINANSIJE.Database;
using ApplicationFINANSIJE.Services;
Console.OutputEncoding = System.Text.Encoding.UTF8;
Console.InputEncoding = System.Text.Encoding.UTF8;
using var connection = Db.OpenConnection();

Console.WriteLine("Povezano na FinansijskiSistem.");

FinansijeService finansijeService = new FinansijeService(connection);
finansijeService.AktivirajUlogu();

Console.WriteLine("Aktivirana uloga DataProviderFINANSIJE.");
Console.WriteLine();

while (true)
{
    Console.WriteLine("1. Unesi transakciju");
    Console.WriteLine("2. Izmeni transakciju");
    Console.WriteLine("3. Obriši transakciju");
    Console.WriteLine("4. Prikaži sve transakcije");
    Console.WriteLine("0. Izlaz");

    string? izbor = Console.ReadLine();
    Console.WriteLine();

    if (izbor == "0")
        break;

    if (izbor == "1")
        finansijeService.UnesiTransakciju();
    else if (izbor == "2")
        finansijeService.AzurirajTransakciju();
    else if (izbor == "3")
        finansijeService.ObrisiTransakciju();
    else if (izbor == "4")
        finansijeService.PrikaziTransakcije();
    else
        Console.WriteLine("Nepoznata opcija.");


    Console.WriteLine();
}