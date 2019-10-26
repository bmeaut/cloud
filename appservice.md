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
    - ha elrontottuk, akkor a Windows Credentials Manager-rel töröljük (Windows Credentials fül)
 - nem jó még, hiba van
 
 ## App Service Logs
 - Kapcsoljuk be az App Service Logs blade-en, a logging site extension-t is kapcsoljuk be
 - Log stream-et nézzük meg
 
 ## App Service Configuration
 - A portálról másoljuk ki a connection string-et
 - Configuration / App Settings
  - `ASPNETCORE_ENVIRONMENT` : `Production`
  - `MyDbConnection` : `connection string` (a jelszót adjuk meg!)
 - Most már jónak kell lennie
 
 ## Local loop + git redeploy
  - https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-dotnetcore-sqldb#update-locally-and-redeploy
  - Azure SQL update
    - `$env:ASPNETCORE_ENVIRONMENT = 'Production'`
    - `dotnet ef migrations script InitialCreate`
 
 ## App Service Misc Blades
  - Support + Troubleshooting
  - Monitoring - Process Explorer, Alerts, Metrics
  - API - CORS, API Definition
  - Mobile - Easy Tables / API - kivezetés alatt
  
 ## App Service Blades - Dev Tools
  - Extensions - már ott van a naplózó kiterjesztés, de pl. a [letsencrypt támogatás (klasszikus) verziója](https://github.com/sjkp/letsencrypt-siteextension) is site extension, az [új verzió](https://github.com/sjkp/letsencrypt-azure) már nem
  - Resource explorer - API tesztelésre
  - Perf test
  - App Service Editor
  - Advanced Tools ~ Kudu Tools
  - Console
  - Clone App - csak fizetős plan-ekben
 
 ## App Service Blades - App Service Plan
  - App Service Plan link
  - Átkötés másik App Service Plan-re
  - Kvóták
  
  ## App Service Blades - Settings
  - Export template (ARM), Locks, Properties
  - MySQL-In-App - adatbázis + Free plan => ingyen adatbázisos alkalmazások
  - Push - Notification Hub-bal való összekötés
  - [WebJobs](https://docs.microsoft.com/en-us/azure/app-service/webjobs-create) - háttérprogramok, pl. karbantartási funkciókhoz. Ütemezetten is.
  - Scale up / out
  - Networking
  - TLS/SSL settings - TLS beállítások, Free plan-ben nem teljeskörű a támogatás. Tipp: [letsencrypt](https://github.com/sjkp/letsencrypt-siteextension)
  - Custom domains - Free plan-ben nem teljeskörű a támogatás
  - Backups - Free plan-ben nincs
  - Identity - az **alkalmazáshoz** identitást rendelhetünk, amihez aztán jogokat oszthatunk ki. Jó pl. az infrastruktúra szintű konfigurációmenedzsmenthez.
  - App Insights - monitorozó erőforrás, az Azure Monitor része
  - Autentication/authorization - az alkalmazásból (részben) kiszervezett [authentikációs/autorizációs szolgáltatás](https://docs.microsoft.com/en-us/azure/app-service/overview-authentication-authorization#how-it-works)
 
 ## Epilógus
  - Azure SQL <=> App Service Managed Service Identity-vel: https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-connect-msi
  
