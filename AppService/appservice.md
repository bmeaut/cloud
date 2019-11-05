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
  - `git remote add <remote név> <git deployment url>`
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
  - Resource explorer - segédeszköz az Azure management REST API böngészéséhez, hívásához
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

## Slot kezelés
  - hozzunk létre egy storage erőforrást
  - SQL Server copy-val készítsük el az adatbázis másolatát (mehet ugyanarra a szerverre)
  - nézzük meg a Plan blade-jét, itt láthatók az app-ok (*Apps* blade)
  - skálázzunk fel S1 szintre (**0,085 EUR/óra költség!**)
  - hozzunk létre új slot-ot *test* néven
  - ellenőrzés: üres webapp
  - a backup-restore funkcióval másoljuk át a test-be az App Service-t - ehhez használjuk az előbb létrehozott storage erőforrást
  - ellenőrzés: ugyanaz az adat, mint az eredeti web app-ban
  - állítsuk át a test app connection string-jét, hogy a test db-re mutasson - **slot setting** legyen
  - ellenőrzés: a két webapp connection string-je különböző
  - hozzunk létre új elemet a teszten
  - ellenőrzés: a két webapp adata különböző
  - git deployment kapcsoljuk be a test app-ra is, állítsunk be új lokális remote-ot
  
## Application Insights
  - állítsuk be a *test* app-on
    - Agent based vs. manual - https://docs.microsoft.com/en-us/azure/azure-monitor/app/azure-web-apps#enable-application-insights
  - navigáljunk pár nemlétező oldalra (pl. /phpmyadmin)
  - kis idő múlva figyeljük meg, hogy megjelennek a hibás (404) hívások
  - Kusto Query Language (KQL) - https://docs.microsoft.com/en-us/azure/kusto/query/
  - Azure Monitor pricing - https://azure.microsoft.com/en-us/pricing/details/monitor/
  
## Labor végén/után
- App Service Plan visszaskálázás (előbb egy kivételével minden slot-ot törölni kell) vagy törlés

## Epilógus
  - Azure SQL <=> App Service Managed Service Identity-vel: https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-connect-msi
  
