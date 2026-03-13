# Azure Storage Hands-On Lab
Ennek a logikáját követjük: https://github.com/microsoft/AcademicContent/blob/5a77cd0fcb18137f39a2c0f95c7b91bd30edb603/Labs/Azure%20Services/Azure%20Storage/Azure%20Storage%20and%20Cognitive%20Services%20(MVC).md

Sajnos már teljesen elavult a leírás :disappointed:

Újabb laborfeladatok: https://docs.microsoft.com/en-us/learn/paths/store-data-in-azure/

Azure SDK for .NET csomagok: https://azure.github.io/azure-sdk/releases/latest/all/dotnet.html

## [Azure Portal](https://portal.azure.com/) 
### Nyelvi beállítások
A jobb felső részen fogaskerék ikonra bökve. Érdemes angolra állítani.

### Költségek
Ingyenes szolgáltatások: https://azure.microsoft.com/en-us/pricing/free-services

Ellenőrzés: https://docs.microsoft.com/en-us/azure/billing/billing-check-free-service-usage

Költségfigyelés: https://learn.microsoft.com/en-us/azure/cost-management-billing/benefits/credits/mca-check-azure-credits-balance?tabs=portal

Ebben laborban:
 - Storage -> 5 GB LRS blob 12 hónapig ingyenes
 - Azure AI Search -> 50 MB tárhely, 10k dokumentum és 3 index ingyenes
  
**Tehát az egész labort ingyenes erőforrásokkal végig lehet csinálni.**

### Névválasztás
Bizonyos erőforrásoknak globálisan vagy a régióban egyedi neve kell legyen. Így könnyen előfordulhat, hogy a név már foglalt. Érdemes ilyenkor valamilyen személyre egyedi prefixet/postfixet alkalmazni pl. neptun kód vagy monogram.

## Storage account létrehozás
- új Storage fiók létrehozása
- hogy ingyenes legyen (LRS) és _hot_ tier
- Advanced fül: ne engedélyezzük a hozzáférési kulcsokat (access keys), az Azure portal is Entra auth-ot használjon
- resourcegroup: IntellipixResources
- két konténert hozzunk létre Storage Browser-ben: photos, thumbnails
- adjunk magunknak jogot, Scope: Storage account; Role: Blob Data Contributor; Subject: saját magunk
- Azure portal logout-loginra
- töltsünk fel pár képet

## Azure AI Search létrehozás
- Ingyenes csomagot válasszuk

## Azure AI Search => Storage integráció
- AI Search: kapcsoljuk be a System assigned identity-t (_Identity_ menüpont)
- Storage: RBAC role assignment - Scope: Storage account; Role: Blob Data Reader; Subject: Search Service managed identity
- AI Search: data source-ként vegyük fel a _Storage account/photos_ konténert _ipixds_ néven

## Azure AI Search indexelés
https://learn.microsoft.com/en-us/azure/search/cognitive-search-skill-image-analysis
- Index létrehozás: importáljuk az index JSON-t
- Skillset létrehozás: importáljuk a skillset JSON-t
- Indexer létrehozás: importáljuk az indexer JSON-t
- Indexer lefutás ellenőrzés

## Opcionális: indexer debug session
- Storage: RBAC role assignment - Scope: Storage account; Role: Blob Data Contributor; Subject: Search Service managed identity
- Új Debug session felvétele

## ASP.NET Core projekt létrehozás
1. ASP.NET Core Razor Pages projekt (`Intellipix`)

- Új könyvtár létrehozása `mkdir intellipix`
- Új projekt

```powershell
dotnet new webapp
```

2. Próba

VSCode-ban a könyvtár megnyitása (Solution Explorer-ben). Indítási projekt beállítása.

3. NuGet csomagok

```powershell
dotnet add package Azure.Storage.Blobs
dotnet add package Microsoft.Extensions.Azure
dotnet add package SixLabors.ImageSharp
```

5. Blob client regisztrálás a DI-ba a a Program.cs-ben a többi `builder.Services` sor alá

```csharp
using Microsoft.Extensions.Azure;
//builder.Services.
builder.Services.AddAzureClients(azb =>
{
    azb.AddBlobServiceClient(new Uri("https://ipix.blob.core.windows.net"));
});
```

6. `IndexModel`-ben elkérjük a klienst

```csharp
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Sas;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.Processing;

//class definíció átírva
public class IndexModel(BlobServiceClient blobSvc): PageModel
```

7. `BlobInfo` record típus

```csharp
public record BlobInfo(string ImageUri, string ThumbnailUri, string? Caption = default);
```

8. Blob adatok listázása az `IndexModel`-be

Az `IndexModel`-be:

```csharp
private const string PhotosContainerName = "photos";
private const string ThumbnailsContainerName = "thumbnails";
private const int ThumbnailWidthPx = 192;
public IEnumerable<BlobInfo> Blobs { get; set; } = [];

private static BlobSasQueryParameters CreateContainerSas(
    BlobContainerClient containerClient,
    UserDelegationKey delegationKey,
    string accountName)
{
    var sasBuilder = new BlobSasBuilder
    {
        BlobContainerName = containerClient.Name,
        Resource = "c",
        StartsOn = DateTimeOffset.UtcNow.AddMinutes(-5),
        ExpiresOn = DateTimeOffset.UtcNow.AddMinutes(30),
        CacheControl = "max-age=1800"
    };
    sasBuilder.SetPermissions(BlobContainerSasPermissions.Read);
    return sasBuilder.ToSasQueryParameters(delegationKey, accountName);
}
```

Cseréljük az eredeti `OnGet`-et erre:

```csharp
public async Task OnGetAsync()
{
    var photosClient = blobSvc.GetBlobContainerClient(PhotosContainerName);
    var thumbnailsClient = blobSvc.GetBlobContainerClient(ThumbnailsContainerName);
    var delegationKey = await blobSvc.GetUserDelegationKeyAsync(
        startsOn: DateTimeOffset.UtcNow.AddMinutes(-5),
        expiresOn: DateTimeOffset.UtcNow.AddDays(1));
    var photosSas = CreateContainerSas(photosClient, delegationKey, blobSvc.AccountName);
    var thumbnailsSas = CreateContainerSas(thumbnailsClient, delegationKey, blobSvc.AccountName);
    Blobs = await photosClient.GetBlobsAsync()
        .Select(b => new BlobInfo(
                        new BlobUriBuilder(photosClient.Uri) 
                            { BlobName = b.Name, Sas = photosSas }.ToUri().ToString()
                        , new BlobUriBuilder(thumbnailsClient.Uri) 
                            { BlobName = b.Name, Sas = thumbnailsSas }.ToUri().ToString()
               ))
    .ToListAsync();
}
```

9. Felület az Index.cshtml-be

```html
<div class="pt-4">
    <div class="row">
        <div class="col-sm-8">
           <form method="post" enctype="multipart/form-data" asp-page-handler="Upload">
                <input type="file" asp-for="Upload" id="upload" class="d-none" onchange="this.form.requestSubmit();" />
                <button type="button" class="btn btn-primary btn-lg" onclick="document.getElementById('upload').click();">
                    Upload
                </button>
            </form>
        </div>
    </div>
    <hr />
    <div class="row">
        <div class="col-sm-12">
            @foreach (var blob in Model.Blobs)
            {
                <img src="@blob.ThumbnailUri" width="192" title="@blob.Caption" alt="" loading="lazy" class="me-3 mb-3" />
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
    if (Upload is { Length: > 0 })
    {
        // Demo only: in a real app, do NOT trust user-provided filenames; sanitize and/or generate your own blob names.
        var fileName = Upload.FileName;
        var photosContainer = blobSvc.GetBlobContainerClient(PhotosContainerName);
        var thumbnailsContainer = blobSvc.GetBlobContainerClient(ThumbnailsContainerName);
        var photoBlob = photosContainer.GetBlobClient(fileName);
        await using (var uploadStream = Upload.OpenReadStream())
        {
            await photoBlob.UploadAsync(uploadStream, overwrite: true, cancellationToken: HttpContext.RequestAborted);
        }
        await using var imageStream = Upload.OpenReadStream();
        using var image = await Image.LoadAsync(imageStream, cancellationToken: HttpContext.RequestAborted);
        image.Mutate(x => x.Resize(ThumbnailWidthPx, 0));
        using var thumbnailStream = new MemoryStream();
        var format = image.Metadata.DecodedImageFormat ?? PngFormat.Instance;
        await image.SaveAsync(thumbnailStream, format, cancellationToken: HttpContext.RequestAborted);
        thumbnailStream.Position = 0;
        var thumbnailBlob = thumbnailsContainer.GetBlobClient(fileName);
        await thumbnailBlob.UploadAsync(thumbnailStream, overwrite: true, cancellationToken: HttpContext.RequestAborted);
    }
    return RedirectToPage();
}
```

11. Példaképek [letöltése](/assets/cs-storage-resources.zip)

12. Nézzük meg a kép URL-eket a weboldal forrásában.

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





