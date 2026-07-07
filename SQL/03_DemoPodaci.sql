USE FinansijskiSistem;
GO

INSERT INTO impl.tblKompanija (Naziv, PIB, Email)
VALUES
(N'Технологија д.о.о.', '101234567', 'nabavka@tehnologija.rs'),
(N'БрзаДостава а.д.', '201234568', 'fin@brzadostava.rs'),
(N'MedSupply д.о.о.', '301234569', 'racunovodstvo@medsupply.rs');
GO

INSERT INTO impl.tblTransakcija (IdKompanije, Iznos, TipTr, DatVreme, Opis)
VALUES
(1, 500000.00, N'Приход', '2025-01-15T10:00:00', N'Наплата за испоручену робу клијенту АБЦ'),
(1, -120000.00, N'Расход', '2025-02-01T14:30:00', N'Плаћање добављачу за сировине'),
(2, 350000.00, N'Приход', '2025-02-10T09:15:00', N'Уговорена накнада за логистичке услуге'),
(3, -85000.00, N'Расход', '2025-03-05T11:00:00', N'Плата и доприноси — март 2025');
GO
