# AppService SQL adatbázissal

Telepítendő alkalmazásként egy [másik tárgy példaalkalmazását](https://github.com/bmeaut/BookShop/tree/cloud) használjuk.

DB inicializálás után használható [felhasználói fiókok](https://github.com/bmeaut/BookShop/blob/9493385a60ffd800502c366c174a23a295bd584b/BookShop.Dal/EntityConfiguration/ApplicationUserEntityConfiguration.cs#L34)

## Azure SQL Database

  - név: bookshopdb
  - szervernév (egyedinek kell lennie): bookshop{neptun_kód}dbsrv
  - auth: Entra only
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
  - ugyanezt a connection stringet használjuk a backend projekt appsettings.json-jában is.
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

Kattintsuk össze a Service Connector kapcsolatot (neve:bookshopdbconn, auth: System-assigned MSI), a végén kiköp egy Azure CLI parancsot. Futtatásnál tegyünk a parancs végére plusz egy kapcsolót: `--customized-keys AZURE_SQL_CONNECTIONSTRING=ConnectionStrings__DefaultConnection`

Ellenőrizzük portálon, hogy létrejött-e (*Validate* gomb)

Kicsit sok jogot ad (CONTROL DATABASE), így visszavonhatjuk

```sql
REVOKE CONTROL ON DATABASE::[bookshopdb] FROM [<identity-name>];
ALTER ROLE db_datareader ADD MEMBER [<identity-name>];
ALTER ROLE db_datawriter ADD MEMBER [<identity-name>];
```
  
## Deployment

Állítsuk be a futtatandó appot, mert az App Service az ASP.NET Core Web API és a Blazor appot is indíthatja, de az előbbit kellene.

Configuration -> Stack Settings -> Startup command: `dotnet BookShop.Web.dll`


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
- Vegyünk fel környezeti változót az App Service-be (*Environment variables*) _ConnectionStrings__DefaultConnection_ néven, értéke legyen ugyanaz, mint amit az EF Migrations-nál használtunk ("" nélkül).

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

-- DB permissions for external users
SELECT 
  pr.name AS PrincipalName,
  pr.type_desc AS PrincipalType,
  pr.authentication_type_desc AS AuthType,
  perm.permission_name,
  perm.state_desc,
  perm.class_desc
FROM sys.database_permissions perm
JOIN sys.database_principals pr ON perm.grantee_principal_id = pr.principal_id
WHERE pr.type = 'E'  -- External users only
ORDER BY pr.name;

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
 - Kusto Query Language (KQL) - https://docs.microsoft.com/en-us/azure/kusto/query/, https://learn.microsoft.com/en-us/kusto/query/tutorials/learn-common-operators
 - Azure Monitor pricing - https://azure.microsoft.com/en-us/pricing/details/monitor/
 
## Deployment slots
 
 - fel kell skálázni S1 szintre (**0,085 EUR/óra költség!**)
 - hozzunk létre új slot-ot *test* néven, klónoztassuk a configot az eredetiből
 - ez egy új app, az SQL felé a kapcsolatot ide is fel kell venni. Az Entra-s identity user neve: `[<appnév>/slots/<slotnév>]`
 - legyen egy kis eltérés, a Program.cs-ben tegyünk egy mesterséges késleltetést az egyik API végpontra (az `app.UseAuthorization();` után):
```csharp
const int cpuBurnMs = 2000;

app.UseWhen(
  ctx => HttpMethods.IsGet(ctx.Request.Method) &&
         ctx.Request.Path.Equals("/api/Categories", StringComparison.OrdinalIgnoreCase),
  branch =>
  {
      var loggerFactory =
          branch.ApplicationServices.GetRequiredService<ILoggerFactory>();  
      var logger =
          loggerFactory.CreateLogger("CpuBurnCategoriesBranch");  
      branch.Use(async (context, next) =>
      {
          logger.LogInformation(
              "CPU burn branch activated for {Method} {Path}",
              context.Request.Method,
              context.Request.Path);  
          var sw = System.Diagnostics.Stopwatch.StartNew();
          double x = 0; 
          logger.LogInformation(
              "Starting CPU burn for {DurationMs} ms on {Path}",
              cpuBurnMs,
              context.Request.Path);  
          while (sw.ElapsedMilliseconds < cpuBurnMs)
          {
              context.RequestAborted.ThrowIfCancellationRequested();  
              x += Math.Sqrt((sw.ElapsedTicks & 1023) + 1);
              if (x > 1_000_000)
                  x = 0;
          } 
          logger.LogInformation(
              "Finished CPU burn after {ElapsedMs} ms on {Path}",
              sw.ElapsedMilliseconds,
              context.Request.Path);  
          await next(context);
      });
  }
);
```
 - publikálás: `--slot slotnév` hozzáadása az `az webapp deploy` parancshoz
 - [swap](https://learn.microsoft.com/en-us/azure/app-service/deploy-staging-slots#what-happens-during-a-swap) a két slot között
 - Application Insights: **Requests** response time statisztika KQL nézete -> nézet leszűrése egy slot-ra.

## Azure Load test & scale-out lehetőségek

- [Load Test erőforrás és egyszerű load test létrehozása kifejezetten a fő App Service-hez](https://learn.microsoft.com/en-us/azure/app-testing/load-testing/how-to-create-load-test-app-service)
- Load Test lefutás real-time megfigyeléssel (App Insights Live Metrics)
  - Number of VU: 50
  - Test duration: 5 min
  - Ramp-up time: 1 min
- Scale-out lehetőségek bemutatása: metrika alapú autoscale (autoscale-profile.json).
    
## Labor végén/után

- App Service Plan visszaskálázás (előbb egy kivételével minden slot-ot törölni kell) vagy törlés
  
