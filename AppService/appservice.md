# AppService SQL adatbázissal

https://github.com/VIAUBC01/MovieCatalog.Azure

## Azure SQL

  - válasszuk: standalone Standard S0 (10 DTU) - **12 hónapig ingyenes** (https://azure.microsoft.com/en-us/free/free-account-faq/)
  - nézzük meg:
    - a szerver és az adatbázis erőforrásokat
    - skálázás (db)
    - firewall (szerver)
    - backup (szerver)
    - connection strings (db)
    - Azure Search indexer (db)
    - a webes *Query Editor*-ban ellenőrizzük, hogy üres az adatbázis
    
## Példaprojekt beüzemelése

  - git clone https://github.com/VIAUBC01/MovieCatalog.Azure.git
  - Azure-os connection string az appsettings.Development.json-be
  - futtat. Automatikus adatbázis inicializáció van a projektben. Ellenőrizzük weben az adatbázis tartalmat.


## Web App / App Service

  - https://azure.microsoft.com/en-us/pricing/details/app-service/plans/
  - Publish: code
  - Runtime stack: .NET Core 3.1
  - OS: Linux
  - Region: WEU
  - Windows plan - **Free (F1)** legyen
  - App Insights: nem kell (még)

Egy előfizetés-régió-OS kombináción belül egyetlen free plan lehet.
  
 ## Git deployment
 
  - Deployment Center-ben a local git deployment with kudu beállítása (https://github.com/projectkudu/kudu)
  - `git remote add <remote név> <git deployment url>`
  - commit + push, push során adjuk meg a portálról a git repo app szintű jelszót (\ utáni rész kell csak a usernévből)
    - ha elrontottuk, akkor Windows-on a Windows Credentials Manager-rel töröljük (Windows Credentials fül)
 - nem jó még, hiba van
 
 ## App Service Logs
 
 - Kapcsoljuk be az App Service Logs blade-en
 - Log stream-et nézzük meg
 
 ## App Service Configuration
 
 - A portálról másoljuk ki a connection string-et
 - Configuration / App Settings
  - `MovieCatalog` : `connection string` (a jelszót adjuk meg!)
 - Most már jónak kell lennie
 
 ## SQL AD Auth MSI-vel
 
 - Kapcsoljuk be az App Service-ben a system managed indetity-t (*Identity* lap)
 - Kapcsoljuk be az SQL Server-en az AD integrációt (*Active Directory admin* lap), saját magunkat adjuk meg
 - [Osszunk jogokat](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-connect-msi#grant-permissions-to-managed-identity) az SQL Server-ben az MSI-nek
 
```sql
CREATE USER [<identity-name>] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [<identity-name>];
ALTER ROLE db_datawriter ADD MEMBER [<identity-name>];
```
  - Állítsuk át a connection string-et `"Server=tcp:<server-name>.database.windows.net,1433;Database=<database-name>;"`
  - Próba, működni kell

 - tipp a felhasználók listázásához
 
```sql
select name as username,
       create_date,
       modify_date,
       type_desc as type,
       authentication_type_desc as authentication_type
from sys.database_principals
where type not in ('A', 'G', 'R', 'X')
      and sid is not null
order by username;
```
  
 ## Jogosultság teszt
  
 - Takarító szkript: `dotnet ef migrations script TitleRatings 0 -o clear.sql`. Ezt futtassuk le.
    - ef core tools telepítése: `dotnet tool install --global dotnet-ef`
 - Próba, nem fog tudni elindulni, mert nem fog tudni táblát (sem) létrehozni
 - Teljes szkript nulláról: `dotnet ef migrations script -o full.sql`. Ezt futtassuk le.
 - Migráció kikpacsolása: Application settings - `DOTNET_DbInitHasMigration`: `false`
 
 ## Csatlakozás fejlesztői gépről AD felhasználóként
 
 - `appsettings.Development.json`-be connection stringet átírni ugyanarra, mint az app service-é
 - [tokenforrást](https://docs.microsoft.com/en-us/dotnet/api/azure.identity.defaultazurecredential?view=azure-dotnet) beállítani; VSCode [Azure account extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
   - Linuxon az Azure.Identity 1.2.2 valamivel jobb, az 1.2.3 [hibás](https://github.com/Azure/azure-sdk-for-net/issues/12939#issuecomment-702746462)
   
 ## Application Insights w Log Analytics Workspace
 
 - Log Analytics Workspace létrehozása
 - Application Insights létrehozása és hozzákötése a workspace-hez
 - `dotnet add package Microsoft.ApplicationInsights.AspNetCore`
 -  `AddApplicationInsightsTelemetry()` a service-ek közé
 - új app konfiguráció: `APPINSIGHTS_INSTRUMENTATIONKEY`
 - `appsettings.json`:
 
 ```javascript
 {
  "Logging": {
    "LogLevel": {
      "Default": "Warning"
    },
    "ApplicationInsights": {
      "LogLevel": {
        "Default": "Information"
      }
    }
  },
  "AllowedHosts": "*"
}
 ```
 - navigáljunk pár nemlétező oldalra (pl. /phpmyadmin)
 - kis idő múlva figyeljük meg, hogy megjelennek a hibás (404) hívások
 - Kusto Query Language (KQL) - https://docs.microsoft.com/en-us/azure/kusto/query/, https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/tutorial
 - Azure Monitor pricing - https://azure.microsoft.com/en-us/pricing/details/monitor/
 
 ## Deployment slots
 
 - fel kell skálázni S1 szintre (**0,085 EUR/óra költség!**)
 - hozzunk létre új slot-ot *test* néven
 - ez egy új app, inicializálni kell a deployment opciókat
 - Identity-t be kell kapcsolni + fel kell venni az SQL adatbázisba a slot felhasználót `[<appnév>/slots/<slotnév>]`
 - push
    
## Labor végén/után

- App Service Plan visszaskálázás (előbb egy kivételével minden slot-ot törölni kell) vagy törlés
  
