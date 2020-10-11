# Azure Storage Hands-On Lab
https://github.com/bmeaut/computerscience/blob/master/Labs/Azure%20Services/Azure%20Storage/Azure%20Storage%20and%20Cognitive%20Services%20(MVC).md

Sajnos már nagyon elavult a leírás :disappointed:

## Azure Portal 
### Nyelvi beállítások
A jobb felső részen fogaskerék ikonra bökve. Érdemes angolra állítani.

### Költségfigyelés
https://docs.microsoft.com/en-us/azure/billing/billing-check-free-service-usage
Ebben laborban:
 - Storage -> 5 GB LRS blob hallgatóknak ingyenes 12 hónapig
 - Computer Vision -> ha free tier-t választod, akkor ingyenes (kvóta van)
 - App Service -> az App Service Plan-ért kellene fizetni, de van ingyenes változat (kvóta van)
 
 Ingyenes szolgáltatások: https://azure.microsoft.com/en-us/free/
 Azure sponsorship portál: https://www.microsoftazuresponsorships.com/ 
 
**Tehát az egész labort ingyenes erőforrásokkal végig lehet csinálni.**

### Névválasztás
Bizonyos erőforrásoknak globálisan vagy a régióban egyedi neve kell legyen. Így könnyen előfordulhat, hogy a név már foglalt. Érdemes ilyenkor valamilyen személyre egyedi prefixet/postfixet alkalmazni pl. neptun kód vagy monogram.

## Ex. 1.
- új Storage fiók létrehozása
- hogy ingyenes legyen (LRS)
- resourcegroup: IntellipixResources
- két konténert hozzunk létre: photos, thumbnails
  - mindkettőben hozzá lehessen férni publikusan a blobokhoz

## Ex. 2.
- Nézzünk körül Storage Explorer-ben

## Ex. 3.
1. ASP.NET Core MVC projekt (Intellipix)

```powershell
dotnet new webapp
```

2. Próba

3. ImageResizer és Azure.Storage.Blobs NuGet csomagok

```powershell
dotnet add package SixLabors.ImageSharp
dotnet add package Azure.Storage.Blobs
dotnet add package System.Interactive.Async
```

4. User Secrets

```bash
dotnet user-secrets init
dotnet user-secrets set "Az:StoreConnString" "connstring"
```

5. BlobInfo egy új `Models` alkönyvtárba

```csharp
public class BlobInfo
{
    public string ImageUri { get; set; }
    public string ThumbnailUri { get; set; }
    public string Caption { get; set; }
}
```

## Ex. 4.
- Kihagyható

## Ex. 5.
- A 8-as pontban azt írja, hogy az URL-t ki kell egészíteni. Az újabb verziós NuGet csomagot használva nem kell.

## Ex. 9.
- Application Insights nem kell
- App Service Plan - **Free (F) méretű legyen!**



