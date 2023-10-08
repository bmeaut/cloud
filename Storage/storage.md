# Azure Storage Hands-On Lab
Ennek a logikáját követjük: https://github.com/microsoft/AcademicContent/blob/5a77cd0fcb18137f39a2c0f95c7b91bd30edb603/Labs/Azure%20Services/Azure%20Storage/Azure%20Storage%20and%20Cognitive%20Services%20(MVC).md

Sajnos már teljesen elavult a leírás :disappointed:

Újabb laborfeladatok: https://docs.microsoft.com/en-us/learn/paths/store-data-in-azure/

Azure SDK for .NET csomagok: https://azure.github.io/azure-sdk/releases/latest/all/dotnet.html

## [Azure Portal](https://portal.azure.com/) 
### Nyelvi beállítások
A jobb felső részen fogaskerék ikonra bökve. Érdemes angolra állítani.

### Költségfigyelés
https://docs.microsoft.com/en-us/azure/billing/billing-check-free-service-usage (Student előfieztésen nem működik a free usage monitor)
Ebben laborban:
 - Storage -> 10 GB LRS blob hallgatóknak ingyenes 12 hónapig
 - Computer Vision -> ha free tier-t választod, akkor ingyenes (kvóta van)
 
 Ingyenes szolgáltatások: https://azure.microsoft.com/en-us/free/
 Azure sponsorship portál: https://www.microsoftazuresponsorships.com/ 
 
**Tehát az egész labort ingyenes erőforrásokkal végig lehet csinálni.**

### Névválasztás
Bizonyos erőforrásoknak globálisan vagy a régióban egyedi neve kell legyen. Így könnyen előfordulhat, hogy a név már foglalt. Érdemes ilyenkor valamilyen személyre egyedi prefixet/postfixet alkalmazni pl. neptun kód vagy monogram.

## Ex. 1.
- új Storage fiók létrehozása
- hogy ingyenes legyen (LRS) és _hot_ tier
- Advanced fül: engedélyezzük az anonim hozzáférést
- resourcegroup: IntellipixResources
- két konténert hozzunk létre Storage Browser-ben: photos, thumbnails
  - mindkettőben hozzá lehessen férni publikusan a blobokhoz

## Ex. 2.
- Connection String: Access Key menüpont -> felül Show Keys gomb

## Ex. 3.
1. ASP.NET Core MVC projekt (`Intellipix`)

- Új könyvtár létrehozása `mkdir intellipix`
- Új projekt

```powershell
dotnet new webapp
```

2. Próba

VSCode-ban a könyvtár megnyitása. Dotnet assetek generáltatása.

3. NuGet csomagok

```powershell
dotnet add package SixLabors.ImageSharp
dotnet add package Azure.Storage.Blobs
dotnet add package System.Interactive.Async
dotnet add package Microsoft.Extensions.Azure
dotnet add package Flurl
```

4. Connection string => User Secrets.  A teljes connection string legyen benne ne csak az access key!

```bash
dotnet user-secrets init
dotnet user-secrets set "AzStore:connectionString" "connstring"
```

5. Blob client regisztrálás a DI-ba a a Program.cs-ben a többi `builder.Services` sor alá

```csharp
builder.Services.AddAzureClients(azb =>
{
    azb.AddBlobServiceClient(builder.Configuration.GetSection("AzStore"));
});
```

6. `IndexModel`-ben elkérjük a klienst

```csharp
private readonly BlobServiceClient _blobSvc;
public IndexModel(ILogger<IndexModel> logger, BlobServiceClient blobSvc)
{
    _logger = logger;
    _blobSvc = blobSvc;
}
```


7. `BlobInfo` egy új `Models` alkönyvtárba

```csharp
public class BlobInfo
{
    public string ImageUri { get; set; }
    public string ThumbnailUri { get; set; }
    public string? Caption { get; set; }

    public BlobInfo(string imageUri, string thumbnailUri, string? caption=default)
    {
        ImageUri = imageUri;
        ThumbnailUri = thumbnailUri;
        Caption = caption;
    }
}
```


8. Blob adatok listázása az `IndexModel`-be

Az `IndexModel` tetejére:

```csharp
using Flurl;
```

Cseréljük az eredeti `OnGet`-et erre:

```csharp
public IEnumerable<BlobInfo> Blobs { get; set; } = Enumerable.Empty<BlobInfo>();

public async Task OnGet()
{
    BlobContainerClient blobccP = _blobSvc.GetBlobContainerClient("photos");
    BlobContainerClient blobccT = _blobSvc.GetBlobContainerClient("thumbnails");
    Blobs = await blobccP.GetBlobsAsync()
        .Select(b => new BlobInfo(
                        blobccP.Uri.AppendPathSegment(b.Name)
                        ,blobccT.Uri.AppendPathSegment(b.Name))
               )
    .ToListAsync();
}
```

9. Felület az Index.cshtml-be

```html
<div class="container" style="padding-top: 24px">
    <div class="row">
        <div class="col-sm-8">
           <form method="post" enctype="multipart/form-data">
                <input type="file" asp-for="Upload" id="upload" style="display: none" onchange="$('#submit').click();"/>
                <input type="button" value="Upload a Photo" class="btn btn-primary btn-lg" onclick="$('#upload').click();" />
                <input type="submit" id="submit" style="display: none" asp-page-handler="Upload"/>
            </form>
        </div>
        <div class="col-sm-4 float-right">
        </div>
    </div>
    <hr />
    <div class="row">
        <div class="col-sm-12">
            @foreach (BlobInfo blob in Model.Blobs ?? Enumerable.Empty<BlobInfo>())
            {
                <img src="@blob.ThumbnailUri" width="192" title="@blob.Caption" style="padding-right: 16px; padding-bottom: 16px" />
            }
        </div>
    </div>
</div>
```

10. Feltöltés az `IndexModel`-be

```csharp
[BindProperty]
public IFormFile? Upload { get; set; }

public async Task<IActionResult> OnPostUploadAsync()
{
    if (Upload != null)
    {
        BlobContainerClient blobccP = _blobSvc.GetBlobContainerClient("photos");
        BlobClient blobc = blobccP.GetBlobClient(Upload.FileName);
        using Stream stream = Upload.OpenReadStream();
        var resp = await blobc.UploadAsync(stream);
        /*ide jön majd a computer vision logika*/
        stream.Seek(0, SeekOrigin.Begin);
        using Image image = Image.Load(stream);
        image.Mutate(x => x.Resize(192, 0));
        BlobContainerClient blobccT = _blobSvc.GetBlobContainerClient("thumbnails");
        using MemoryStream memoryStream = new MemoryStream();
        image.Save(memoryStream, image.Metadata.DecodedImageFormat);
        memoryStream.Seek(0, SeekOrigin.Begin);
        await blobccT.UploadBlobAsync(Upload.FileName, memoryStream);
    }
    return RedirectToAction("Index");
}
```

11. Példaképek [letöltése](/assets/cs-storage-resources.zip)

12. Nézzük meg mit műveltünk Azure Storage Explorer-ben és a weboldal forrásában is. Ha átírjuk a thumbnail URI-ban a /thumbnail/-t /photos/-ra, megkapjuk az eredeti képet.

## Ex. 4.
- Kihagyható

## Ex. 5.
1. Computer Vision szolgáltatás létrehozása
 - F0 plan
 - ugyanabba a resource group-ba és régióba, mint ahol a storage account van

2. Új secret-ek a Keys & Endpoint lapról

```bash
dotnet user-secrets set "AzVision:Endpoint" "https://valami.cognitiveservices.azure.com/"
dotnet user-secrets set "AzVision:Key" "titok"
```

3. NuGet csomag hozzáadása

```bash
dotnet add package Microsoft.Azure.CognitiveServices.Vision.ComputerVision
```

Ez a csomag az API 3.x-es verzióját hívja, a legújabb 4-es API verzióval kompatibilis [csomag](https://learn.microsoft.com/en-us/azure/ai-services/computer-vision/sdk/install-sdk?tabs=windows%2Cubuntu%2Cdotnetcli%2Cterminal%2Cmaven&pivots=programming-language-csharp) jelenleg még beta állapotban van.

4. Vision client regisztrálás a DI-ba a `Startup.ConfigureServices`-ben

```csharp
builder.Services.AddSingleton(provider => {
    return new ComputerVisionClient(new ApiKeyServiceClientCredentials(builder.Configuration["AzVision:Key"]))
        {Endpoint = builder.Configuration["AzVision:Endpoint"]};
});
```

5. A kliens elkérése az `IndexModel` konstruktorban


```csharp
private readonly ComputerVisionClient _visionClient;

public IndexModel(ILogger<IndexModel> logger, BlobServiceClient blobSvc, ComputerVisionClient visionClient)
{
    _logger = logger;
    _blobSvc = blobSvc;
    _visionClient = visionClient;
}
```

5. Feltöltés okosítása

Az `OnPostUploadAsync` elejére:

```csharp
VisualFeatureTypes?[] features = new VisualFeatureTypes?[] { VisualFeatureTypes.Description };
```

Ugyanezen függvényben a kommenttel jelzett helyre:

```csharp
var analResult = await _visionClient.AnalyzeImageAsync(blobc.Uri.ToString(), features);
var blobMetaDict = analResult.Description.Tags
   .Select((t, i) => new KeyValuePair<string, string>(nameof(analResult.Description.Tags) + i, t))
   .Concat(new Dictionary<string, string> { { nameof(analResult.Description.Captions), analResult.Description.Captions[0].Text } })
   .ToDictionary(kvp => kvp.Key, kvp => kvp.Value);
await blobc.SetMetadataAsync(blobMetaDict);
```

6. Listázás okosítása
```csharp
public async Task OnGet()
{
    BlobContainerClient blobccP = _blobSvc.GetBlobContainerClient("photos");
    BlobContainerClient blobccT = _blobSvc.GetBlobContainerClient("thumbnails");
    Blobs = await blobccP.GetBlobsAsync(BlobTraits.Metadata)
        .Select(b => new BlobInfo(
                        blobccP.Uri.AppendPathSegment(b.Name)
                        ,blobccT.Uri.AppendPathSegment(b.Name)
                        ,b.Metadata.ContainsKey("Captions")? b.Metadata["Captions"]:b.Name)
               )
    .ToListAsync();
}
```

7. Próba

## Ex. 6.

1. Új form az eddigi üres div-be

```html
<div class="col-sm-4 float-right">
   <form method="post" enctype="multipart/form-data" class="form-inline">
     <div class="input-group">
        <input type="text" class="form-control" placeholder="Search photos" asp-for="SearchTerm" style="max-width: 800px">
        <span class="input-group-append">
            <button class="btn btn-primary" type="submit" asp-page-handler="Search">Go</button>
        </span>
    </div>
  </form>                
</div>
```

2. Kezelőfv az `IndexModel`-be, átirányítjuk a lekérdező műveletre.

```csharp
[BindProperty]
public string? SearchTerm {get; set;}

public ActionResult OnPostSearchAsync()
{
    return RedirectToAction("Index", new { term = SearchTerm });
}
```

3. Lekérdező művelet okosítása

```csharp
    public async Task OnGet(string? term)
/**/{
/**/    BlobContainerClient blobccP = _blobSvc.GetBlobContainerClient("photos");
/**/    BlobContainerClient blobccT = _blobSvc.GetBlobContainerClient("thumbnails");
/**/    Blobs = await blobccP.GetBlobsAsync(BlobTraits.Metadata)
            .Where(b=>string.IsNullOrEmpty(term) || 
                      b.Metadata.Any(m=>m.Key.StartsWith("Tags") 
                      && m.Value.Equals(term, StringComparison.InvariantCultureIgnoreCase))
                   )
/**/       .Select(b => new BlobInfo(
/**/                        blobccP.Uri.AppendPathSegment(b.Name)
/**/                        ,blobccT.Uri.AppendPathSegment(b.Name)
/**/                       ,b.Metadata.ContainsKey("Captions")? b.Metadata["Captions"]:b.Name)
/**/              )
/**/    .ToListAsync();
        SearchTerm = term;
/**/}
```

Ezzel így lekérdezzük az összes blob összes metaadatát és memóriában szűrünk. Alternatív lehetőségnek tűnhet a [blob index tags](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blob-index-how-to?tabs=azure-portal) töltése, amivel már Azure oldalon tudnánk szűrni. Sajnos a fenti szűrést nem lehet egy az egyben átfordítani szűrőkifejezéssé. A kulcsokat explicit meg kell adni, nem lehet a kulcsokra kifejezést megadni.

4. Próba





