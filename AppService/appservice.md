# AppService SQL adatbázissal

A gyakorlat menete hasonló, de több helyen eltér ettől [a gyakorlatanyagtól](https://github.com/BMEVIAUBB04/gyakorlat-azure).

A telepítendő alkalmazásként egy [MS példaalkalmazást használunk](https://github.com/Azure-Samples/msdocs-app-service-sqldb-dotnetcore/tree/3655d08a7503ce5ff3951a74e420afc639a8b7a8).

## Azure SQL

  - válasszuk: serverless (Development workload)
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

  - Töltsük le a [példaprojektet]([https://github.com/Azure-Samples/msdocs-app-service-sqldb-dotnetcore](https://github.com/Azure-Samples/msdocs-app-service-sqldb-dotnetcore/archive/3655d08a7503ce5ff3951a74e420afc639a8b7a8.zip))
  - Azure-os connection string dotnet user secret-be, majd EF Migrations beüzemelése. A projektfájl (.csproj) könyvtárában:
  ```powershell
  dotnet user-secrets init
  dotnet user-secrets set "ConnectionStrings:MyDbConnection" "connectionstringünk"
  dotnet tool install -g dotnet-ef
  dotnet ef database update --connection "connectionstringünk"
  ```
  - jelszót ne felejtsük el beírni a connection string-be!
  - futtat, próba. Ellenőrizzük weben az adatbázis tartalmat.

## Web App / App Service

  - https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/compute-decision-tree
  - https://azure.microsoft.com/en-us/pricing/details/app-service/plans/
  - Publish: code
  - Runtime stack: .NET 6
  - OS: Linux vagy Windows
  - Region: WEU
  - **Free (F1)** legyen
  - App Insights: nem kell (még)

Egy előfizetés-régió-OS kombináción belül egyetlen free plan lehet.

 ## App Service Configuration
 
 - A portálról másoljuk ki a connection string-et
 - Configuration / App Settings
 - adjuk meg a connection stringet a secretnek megfelelően
  
 ## Deployment

 Aletrnatívaként a gyakorlatanyagból az Azure CLI-s megoldás is jó lehet.
 
 A solution könyvtárában álljunk!
  - `git init`
  - `git add --all` (.gitignore már van a projektben)
  - `git commit`
  - Deployment Center-ben a Local git deployment (with kudu) beállítása (https://github.com/projectkudu/kudu)
  - `git remote add <remote név> <git deployment url>`
  - push ( `git push --set-upstream az master`), push során adjuk meg a portálról a git repo app szintű jelszót (\ utáni rész kell csak a usernévből)
    - ha elrontottuk, akkor Windows-on a Windows Credentials Manager-rel töröljük (Windows Credentials fül)
 
 ## Diagnose & solve problems
 
 - Diagnose & solve problems > Application Logs
 
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
 - Állítsuk át a connection string-et `"Server=tcp:<server-name>.database.windows.net;Authentication=Active Directory Default; Database=<database-name>;"`
 - Próba, nem működik :(
 - Frissítsük az SqlClient-et: `dotnet add package Microsoft.Data.SqlClient --version 5.0.1` (**nem!** System.Data.SqlClient) Commit+push.

 - Ellenőrző szkript felhasználók listázásához 
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
 - Ellenőrző szkript jogosultságok listázásához
```sql
-- List of database roles for the MSI user
SELECT dp.name AS principal_name, dp.type_desc AS principal_type, r.name AS role_name
FROM sys.database_role_members AS m
JOIN sys.database_principals AS dp ON m.member_principal_id = dp.principal_id
JOIN sys.database_principals AS r ON m.role_principal_id = r.principal_id
WHERE dp.name = 'your_msi_principal';

-- List of object-level permissions for the MSI user (optional)
SELECT d.name AS object_name, dp.name AS principal_name, dp.type_desc AS principal_type, p.permission_name
FROM sys.database_permissions AS p
JOIN sys.database_principals AS dp ON p.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects AS d ON p.major_id = d.object_id
WHERE dp.name = 'your_msi_principal';
```


  
 ## Csatlakozás fejlesztői gépről AD felhasználóként
 
 - `appsettings.Development.json`-be connection stringet átírni: 
    ```
    "Server=tcp:<server-name>.database.windows.net,1433;Authentication=Active Directory Default;Database=<database-name>;"
    ```
 - [tokenforrást](https://docs.microsoft.com/en-us/dotnet/api/azure.identity.defaultazurecredential?view=azure-dotnet) beállítani; VSCode [Azure account extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azure-account). A tokenforrások sorrndje nem függ attól, hogy milyen alkalmazásban fejlesztünk éppen (VSCode-ban dolgozva is a VS tokenjét használjuk, ha van)!
   
 ## Application Insights w Log Analytics Workspace
 
 https://learn.microsoft.com/en-us/azure/azure-monitor/overview#overview
 
 - Log Analytics Workspace létrehozása
 - Application Insights létrehozása és hozzákötése a workspace-hez
 - Auto instrumentation már [Linuxos ASP.NET Core alkalmazásokhoz is](https://learn.microsoft.com/en-us/azure/azure-monitor/app/azure-web-apps-net-core?tabs=Linux%2Cwindows#enable-client-side-monitoring) ([támogatott keretrendszerek](https://learn.microsoft.com/en-us/azure/azure-monitor/app/codeless-overview#supported-environments-languages-and-resource-providers))
 - navigáljunk pár nemlétező oldalra (pl. /phpmyadmin)
 - kis idő múlva figyeljük meg, hogy megjelennek a hibás (404) hívások
 - Kusto Query Language (KQL) - https://docs.microsoft.com/en-us/azure/kusto/query/, https://docs.microsoft.com/en-us/azure/data-explorer/kusto/query/tutorial
 - Azure Monitor pricing - https://azure.microsoft.com/en-us/pricing/details/monitor/
 
 ## Deployment slots
 
 - fel kell skálázni S1 szintre (**0,085 EUR/óra költség!**)
 - hozzunk létre új slot-ot *test* néven
 - ez egy új app, inicializálni kell a deployment opciókat
 - Identity-t be kell kapcsolni + fel kell venni az SQL adatbázisba a slot felhasználót `[<appnév>/slots/<slotnév>]`
 - legyen egy kis eltérés, pl. a \_Layout.cshtml-be:
   ```html
   <a class="navbar-brand" asp-area="" asp-controller="Home" asp-action="Index">@(Environment.GetEnvironmentVariable("WEBSITE_HOSTNAME") ?? "My TodoList App")</a>
   ```
 - push
 - [swap](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots#what-happens-during-a-swap) a két slot között
    
## Labor végén/után

- App Service Plan visszaskálázás (előbb egy kivételével minden slot-ot törölni kell) vagy törlés
  
