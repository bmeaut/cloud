# AppService SQL adatbázissal

A gyakorlat menete hasonló, de több helyen eltér ettől [a hivatalos MS útmutatótól](https://learn.microsoft.com/en-us/azure/app-service/tutorial-dotnetcore-sqldb-app).

## Azure SQL

  - válasszuk: standalone Standard S0 (10 DTU) - **12 hónapig ingyenes** (https://azure.microsoft.com/en-us/free/free-account-faq/) vagy serverless (Development workload-ot választva ingyenes)
  - Networking (a szerveren) - állítsuk be a saját IP-nket (_Add Client IP_) és engedélyezzük az Azure hozzáférést is (_Allow Azure services and resources to access this server_
)
  - nézzük meg:
    - a szerver és az adatbázis erőforrásokat
    - skálázás (db)
    - backup (szerver)
    - connection strings (db)
    - Replication (db)
    - Add Azure Search (db)
    - a webes *Query Editor*-ban ellenőrizzük, hogy üres az adatbázis
    
## Példaprojekt beüzemelése

  - Töltsük le a [példaprojektet](https://github.com/Azure-Samples/msdocs-app-service-sqldb-dotnetcore)
  - Azure-os connection string dotnet user secret-be 
  ```powershell
  dotnet user-secrets init
  dotnet user-secrets set "ConnsectionStrings:MyDbConnection" "connectionstringünk"
  dotnet ef database update --connection "connectionstringünk"
  ```
  - jelszót ne felejtsük el beírni a connection string-be!
  - futtat, próba. Ellenőrizzük weben az adatbázis tartalmat.


## Web App / App Service

  - https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/compute-decision-tree
  - https://azure.microsoft.com/en-us/pricing/details/app-service/plans/
  - Publish: code
  - Runtime stack: .NET 5
  - OS: Linux
  - Region: WEU
  - Windows plan - **Free (F1)** legyen
  - App Insights: nem kell (még)

Egy előfizetés-régió-OS kombináción belül egyetlen free plan lehet.
  
 ## Git deployment
  
 A solution könyvtárában álljunk!
  - `git init`
  - `git add --all` (.gitignore már van a projektben)
  - `git commit`
  - Deployment Center-ben a Local git deployment (with kudu) beállítása (https://github.com/projectkudu/kudu)
  - `git remote add <remote név> <git deployment url>`
  - push ( `git push --set-upstream az master`), push során adjuk meg a portálról a git repo app szintű jelszót (\ utáni rész kell csak a usernévből)
    - ha elrontottuk, akkor Windows-on a Windows Credentials Manager-rel töröljük (Windows Credentials fül)
 - nem jó még, hiba van
 
 ## Diagnose & solve problems
 
 - Diagnose & solve problems > Application Logs
 
 ## App Service Configuration
 
 - A portálról másoljuk ki a connection string-et
 - Configuration / App Settings
 - adjuk meg a connection stringet a secretnek megfelelően
 - Most már jónak kell lennie
 
 ## SQL AD Auth MSI-vel
 
 - Kapcsoljuk be az App Service-ben a system managed indetity-t (*Identity* lap)
 - Kapcsoljuk be az SQL Server-en az AD integrációt (*Active Directory admin* lap), saját magunkat adjuk meg
 - [Osszunk jogokat](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-connect-msi#grant-permissions-to-managed-identity) az SQL Server-ben az MSI-nek
 - Az identitás neve App Service esetében az App Service neve
 
```sql
CREATE USER [<identity-name>] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [<identity-name>];
ALTER ROLE db_datawriter ADD MEMBER [<identity-name>];
```
  - Állítsuk át a connection string-et `"Server=tcp:<server-name>.database.windows.net,1433;Authentication=Active Directory Managed Identity;Database=<database-name>;"`
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
 
 - `appsettings.Development.json`-be connection stringet átírni: `"Server=tcp:<server-name>.database.windows.net,1433;Authentication=Active Directory Default;Database=<database-name>;"`
 - [tokenforrást](https://docs.microsoft.com/en-us/dotnet/api/azure.identity.defaultazurecredential?view=azure-dotnet) beállítani; VSCode [Azure account extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account)
   
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
  
