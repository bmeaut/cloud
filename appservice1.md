# AppService SQL adatbázissal

https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-dotnetcore-sqldb

## Azure SQL
  - Árazási modellek: https://docs.microsoft.com/en-us/azure/sql-database/sql-database-purchase-models
    - elastic vs standalone (vs managed) https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-pool
    - vCore vs DTU (DTU kalkulátor: https://dtucalculator.azurewebsites.net/)
    - vCore-on belül Serverless (*preview*): https://docs.microsoft.com/en-us/azure/sql-database/sql-database-serverless
  - válasszuk: standalone Standard S0 (10 DTU) - 12 hónapig ingyenes: https://azure.microsoft.com/en-us/free/free-account-faq/
  - nézzük meg:
    - a szerver és az adatbázis erőforrásokat
    - skálázás (db)
    - firewall (szerver)
    - backup (szerver)
    - connection strings (db)
    - Azure Search indexer (db)
  
## Példaprojekt beüzemelése
  - git clone https://github.com/azure-samples/dotnetcore-sqldb-tutorial
  - fordít, dotnet ef database update (.NET Core SDK 3 esetén `dotnet tool install --global dotnet-ef --version 3.0.0`)
  - sqlite adatbázis létrejön
  - Projektként futtassuk
  
