# AppService SQL adatbázissal

https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-dotnetcore-sqldb

## Azure SQL
  - Árazási modellek: https://docs.microsoft.com/en-us/azure/sql-database/sql-database-purchase-models
    - elastic vs standalone (vs managed) https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-pool
    - vCore vs DTU (DTU kalkulátor: https://dtucalculator.azurewebsites.net/)
    - vCore-on belül Serverless (*preview*): https://docs.microsoft.com/en-us/azure/sql-database/sql-database-serverless
  - válasszuk: standalone Standard S0 (10 DTU) - **12 hónapig ingyenes** (https://azure.microsoft.com/en-us/free/free-account-faq/)
  - nézzük meg:
    - a szerver és az adatbázis erőforrásokat
    - skálázás (db)
    - firewall (szerver)
    - backup (szerver)
    - connection strings (db)
    - Azure Search indexer (db)
    
## App Service
  - https://azure.microsoft.com/en-us/pricing/details/app-service/plans/
  - Publish: code
  - Runtime stack: .NET Core 2.2
  - OS: Windows
  - Region: WEU
  - Windows plan - **Free (F1)** legyen
  - App Insights: nem kell (még)
  
## Példaprojekt beüzemelése
  - git clone https://github.com/azure-samples/dotnetcore-sqldb-tutorial
  - fordít, dotnet ef database update (.NET Core SDK 3 esetén `dotnet tool install --global dotnet-ef --version 3.0.0`)
  - sqlite adatbázis létrejön
  - **Projektként** futtassuk
  
## Azure SQL adatbázis inicializálása
  - https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-dotnetcore-sqldb#connect-to-sql-database-in-production
  - `Automatically perform database migration` rész nem kell
  - `$env:ASPNETCORE_ENVIRONMENT = 'Production'`
  - `dotnet ef migrations script`
  - SQL szerver tűzfal beállítás
  - szkript futtatása a portálon
  
 ## Git deployment
  - Deployment Center-ben a local git deployment with kudu beállítása (https://github.com/projectkudu/kudu)
  - `git remote add <git deployment url>`
  - commit + push, push során adjuk meg a portálról a git repo app szintű jelszót (\ utáni rész kell csak a usernévből)
    - ha elrontottuk, akkor a windows credentials manager-rel töröljük (Windows Credential)
 - nem jó még, hiba van
 
 ## App Service Logs
 - Kapcsoljuk be, logging site extension-t kapcsoljuk be
 - Log stream-et nézzük meg
 
 ## App Service Configuration
 - A portálról másoljuk ki a connection string-et
 - Configuration / App Settings
  - `ASPNETCORE_ENVIRONMENT` : `Production`
  - `MyDbConnection` : `connection string` (a jelszót adjuk meg!)
 - Most már jónak kell lennie
  


