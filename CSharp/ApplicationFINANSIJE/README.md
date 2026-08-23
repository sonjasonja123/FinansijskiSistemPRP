# Finansijski Sistem

## Projekat

Programiranje i podaci (PRP)

## Tehnologije

- SQL Server 2025
- C#
- SQL CLR
- Full-Text Search

## Struktura

- SQL
- CSharp
- Dokumentacija

## Pokretanje

1. Pokrenuti SQL skripte 01 do 08 (redom).
2. Pokrenuti `11_ParticionisanjeIspravka.sql` (particionisanje + arhiva preko synonyma).
3. Dodati `PrpMonitoring.cs` u projekat FinansijskiSistemCLR (ako već nije dodat) i build-ovati ga (Release).
4. Kopirati `FinansijskiSistemCLR.dll` u `C:\CLR\` (zameniti stari fajl).
5. Pokrenuti `13_CLR_ExternalAccess.sql` (zamenjuje stari `09_CLR.sql` — kreira EXTERNAL_ACCESS assembly, CLR triger i CLR monitoring proceduru).
6. Pokrenuti `12_LanacIXml.sql` (drugi rekurzivni CTE + FOR XML PATH).
7. Pokrenuti `10_Testovi.sql`.
8. Pokrenuti ApplicationFINANSIJE.
9. Pokrenuti ApplicationKONTROLA.

## Napomena

Originalni `09_CLR.sql` se više ne koristi — u potpunosti ga zamenjuje `13_CLR_ExternalAccess.sql`.