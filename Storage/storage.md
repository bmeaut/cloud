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
1. ASP.NET Core MVC projekt (`Intellipix`)

```powershell
dotnet new webapp
```

2. Próba

3. NuGet csomagok

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

5. `IndexModel`-ben konfig kiolvasás

```csharp
 private readonly IConfiguration _config;

public IndexModel(ILogger<IndexModel> logger, IConfiguration config)
{
    _logger = logger;
    _config =  config;
}
```


6. `BlobInfo` egy új `Models` alkönyvtárba

```csharp
public class BlobInfo
{
    public string ImageUri { get; set; }
    public string ThumbnailUri { get; set; }
    public string Caption { get; set; }
}
```


7. Blob adatok listázása az `IndexModel`-be

```csharp
public IEnumerable<BlobInfo> Blobs {get; set;} 

public async Task OnGet()

{
    BlobServiceClient blobSvc = new BlobServiceClient(_config["Az:StoreConnString"]);
    BlobContainerClient blobcc=blobSvc.GetBlobContainerClient("photos");

    Blobs=await blobcc.GetBlobsAsync()
        .Select(b=>blobcc.GetBlobClient(b.Name).Uri.ToString())
        .Select(u=>new BlobInfo{ImageUri=u, ThumbnailUri=u.Replace("/photos/","/thumbnails/")})                
        .ToListAsync();
}
```

8. Felület az Index.cshtml-be

```html
<div class="container" style="padding-top: 24px">
    <div class="row">
        <div class="col-sm-8">
            <form method="post" enctype="multipart/form-data">
                <input type="file" asp-for="Upload" id="upload" style="display: none" onchange="$('#submit').click();"/>
                <input type="button" value="Upload a Photo" class="btn btn-primary btn-lg" onclick="$('#upload').click();" />
                <input type="submit" id="submit" style="display: none"/>
            </form>
        </div>
        <div class="col-sm-4 pull-right">
        </div>
    </div>
    <hr />
    <div class="row">
        <div class="col-sm-12">
            @foreach (BlobInfo blob in Model.Blobs)
            {
                <img src="@blob.ThumbnailUri" width="192" title="@blob.Caption" style="padding-right: 16px; padding-bottom: 16px" />
            }

        </div>
    </div>
</div>
```

9. Feltöltés az `IndexModel`-be

```csharp
[BindProperty]
public IFormFile Upload { get; set; }

public async Task<IActionResult> OnPostAsync()
{   
    BlobServiceClient blobSvc = new BlobServiceClient(_config["Az:StoreConnString"]);
    BlobContainerClient blobccP=blobSvc.GetBlobContainerClient("photos");
    BlobClient blobc= blobccP.GetBlobClient(Upload.FileName);
    using(Stream stream= Upload.OpenReadStream())
    {
        var resp=await blobc.UploadAsync(stream);
        stream.Seek(0,SeekOrigin.Begin);
        using (Image image = Image.Load(stream, out IImageFormat fmt))
        {            
            image.Mutate(x => x.Resize(192, 0));
            BlobContainerClient blobccT=blobSvc.GetBlobContainerClient("thumbnails");
            using(MemoryStream memoryStream=new MemoryStream())
            {
                image.Save(memoryStream, fmt);
                memoryStream.Seek(0,SeekOrigin.Begin);
                await blobccT.UploadBlobAsync(Upload.FileName,memoryStream);
             }
        }
    }
    return new RedirectToPageResult("Index");            
}
```



## Ex. 4.
- Kihagyható

## Ex. 5.
- A 8-as pontban azt írja, hogy az URL-t ki kell egészíteni. Az újabb verziós NuGet csomagot használva nem kell.

## Ex. 9.
- Application Insights nem kell
- App Service Plan - **Free (F) méretű legyen!**



