# AppService SQL adatbázissal

Telepítendő alkalmazásként egy [másik tárgy példaalkalmazását](https://github.com/bmeaut/BookShop/tree/cloud) használjuk.

## Azure SQL

  - szolgáltatási szint: free serverless
  - Networking (a szerveren) - állítsuk be a saját IP-nket (_Add Client IP_) és engedélyezzük az Azure hozzáférést is (_Allow Azure services and resources to access this server_
)
  - nézzük meg:
    - a szerver és az adatbázis erőforrásokat
    - skálázás (db)
    - backup (szerver)
    - connection strings (db)
    - Add Azure Search (db)
    - a webes *Query Editor*-ban ellenőrizzük, hogy üres az adatbázis
    
## Példaprojekt beüzemelése

  - Töltsük le a [példaprojektet]([(https://github.com/bmeaut/BookShop/tree/cloud)](https://github.com/bmeaut/BookShop/tree/cloud))
  - EF Migrations beüzemelése. Használjuk az Entra alapú connection stringet (cseréljük "" -> ''). A projektfájl (.csproj) könyvtárában:
  ```powershell
  dotnet tool install -g dotnet-ef
  dotnet ef database update --project BookShop.Dal --startup-project BookShop.Web/BookShop.Web --connection "connectionstringünk"
  ```
  - futtat, próba. Ellenőrizzük weben az adatbázis tartalmat.

## Web App / App Service

  - https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/compute-decision-tree
  - https://azure.microsoft.com/en-us/pricing/details/app-service/linux/
  - Publish: code
  - Runtime stack: .NET 10
  - OS: Linux
  - Region: amit a hallgatói előfizetés enged
  - **Free (F1)** legyen
  - App Insights: nem kell (még)

Egy előfizetés-régió-OS kombináción belül egyetlen free plan lehet.

## App Service Service Connector

 Kattintsuk össze a Service Connector kapcsolatot (System-assigned MSI), a végén kiköp egy Azure CLI parancsot. Futtatásnál tegyünk a parancs végére plusz egy kapcsolót: `--customized-keys AZURE_SQL_CONNECTIONSTRING=ConnectionStrings__DefaultConnection`

 Ellenőrizzük portálon, hogy létrejött-e (*Validate* gomb)
  
## Deployment

  ```powershell
dotnet publish "BookShop.Web\BookShop.Web\BookShop.Web.csproj" -c Release -o ./publish
Compress-Archive -Path "./publish/*" -DestinationPath "publish.zip" -Force
az webapp deploy --resource-group bookshop --name <app service neve> --src-path publish.zip --type zip --async
  ```

 
## Diagnose & solve problems
 
 - Diagnose & solve problems > Application Logs
 
## SQL AD Auth MSI-vel, ha a Service Connector nem működne
 
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
JOIN sys.database_principals AS r ON m.role_principal_id = r.principal_id;

-- List of object-level permissions for the MSI user
SELECT d.name AS object_name, dp.name AS principal_name, dp.type_desc AS principal_type, p.permission_name
FROM sys.database_permissions AS p
JOIN sys.database_principals AS dp ON p.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects AS d ON p.major_id = d.object_id
WHERE dp.name NOT IN ('dbo','public');
```
- Ellenőrző szkript - ki járt az adatbázisban
```sql
SELECT connection_id, 
       c.client_net_address,
       c.session_id, 
       connect_time,
       client_net_address, 
       client_tcp_port,
       host_name,
       program_name, 
       login_name, 
	     original_login_name,
	     nt_user_name,
       row_count
FROM sys.dm_exec_connections c
JOIN sys.dm_exec_sessions s ON s.session_id = c.session_id
WHERE DATETRUNC(d, s.login_time)= DATETRUNC( d, GETDATE())
```

- Ellenőrző szkript - session login name visszafejtése
```bash
az ad sp show --id <a login_name @ előtti része>
```
   
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
 - hozzunk létre új slot-ot *test* néven, klónoztassuk a configot az eredetiből
 - ez egy új app, Identity-t be kell kapcsolni + fel kell venni az SQL adatbázisba a slot felhasználót `[<appnév>/slots/<slotnév>]`
 - legyen egy kis eltérés, pl. a \_Layout.cshtml-be:
   ```html
   <li class="nav-item">
     <a class="nav-link text-dark" asp-area="" asp-controller="Todos" asp-action="Index">Todos</a>
   </li>
   ```
 - Ha git-tel publikálunk: deployment opciókat inicializálni, majd push
 - Ha Az CLI-vel publikálunk: `--slot slotnév` hozzáadása az `az webapp deploy` parancshoz
 - [swap](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots#what-happens-during-a-swap) a két slot között

## Azure Load test & scale-out lehetőségek

- [Load Test erőforrás és egyszerű load test létrehozása](https://learn.microsoft.com/en-us/azure/load-testing/quickstart-create-and-run-load-test?tabs=portal)
- Load Test lefutás real-time megfigyeléssel (App Insights Live Metrics)
- Scale-out lehetőségek bemutatása
    
## Labor végén/után

- App Service Plan visszaskálázás (előbb egy kivételével minden slot-ot törölni kell) vagy törlés
  
