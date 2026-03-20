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
- Létrehozás után _Keys_ -> _Role-based access control_
- adjunk magunknak jogot, Scope: AI Search account; Role: Search Index Data Reader; Subject: saját magunk

## Azure AI Search => Storage integráció
- AI Search: kapcsoljuk be a System assigned identity-t (_Identity_ menüpont)
- Storage: RBAC role assignment - Scope: Storage account; Role: Blob Data Reader; Subject: Search Service managed identity
- AI Search: data source-ként vegyük fel a _Storage account/photos_ konténert _ipixds_ néven

## Azure AI Search indexelés

https://learn.microsoft.com/en-us/azure/search/search-region-support#europe

https://learn.microsoft.com/en-us/azure/search/cognitive-search-skill-image-analysis

https://learn.microsoft.com/en-us/azure/search/search-how-to-index-azure-blob-storage#indexing-blob-metadata

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

12. Töltsük fel újra az eddig feltöltött képeket (felülírás), és még néhányat. Ellenőrizzük a thumbnail-eket.

13. Nézzük meg a kép URL-eket a weboldal forrásában.

## Opcionális: GLightbox

1. A _Layout.cshtml-be a többi CSS, js mellé

```aspnetcorerazor
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/glightbox@3.3.1/dist/css/glightbox.min.css" />    
```

```aspnetcorerazor
<script src="https://cdn.jsdelivr.net/npm/glightbox@3.3.1/dist/js/glightbox.min.js"></script>
```

2. Az Index.cshtml-ben az img tag-et vegyük körbe egy <a> tag-gel

```aspnetcorerazor
<a href="@blob.ImageUri"
  class="glightbox"
  data-gallery="photos"
  data-title="@blob.Caption">
   <img src="..." />
</a>
```

3. A _wwwroot/js/site.js_-ben, inicializáljuk a GLightbox-ot

```javascript
document.addEventListener('DOMContentLoaded', () => {
	if (typeof GLightbox === 'undefined') {
		return;
	}

	GLightbox({
		selector: '.glightbox',
		loop: true,
		touchNavigation: true
	});
});
```

## AI Search szolgáltatás bekötése

1. NuGet csomag hozzáadása

```bash
dotnet add package Azure.Search.Documents
```

2. Search API config az appsettings.json-be

```javascript
"SearchService": {
  "Endpoint": "https://ipix2idx.search.windows.net",
  "IndexName": "ipix2idx"
},
```

3. Search client regisztrálás a DI-ba a Program.cs-ben

```csharp
//builder.Services.AddAzureClients(azb =>
//{
//    azb.AddBlobServiceClient(...);
      azb.AddSearchClient(builder.Configuration.GetSection("SearchService"));
//});
```

4. A kliens elkérése az `IndexModel` konstruktorban

```csharp
using Azure.Search.Documents;
//..
public class IndexModel(BlobServiceClient blobSvc, SearchClient searchClient) : PageModel
```

5. Az indexnek megfelelő modellosztály egy új _Models_ almappába:

```csharp
using System.Text.Json.Serialization;

//namespace xxx.Models;

public class PhotoDocument
{
    [JsonPropertyName("id")]
    public string Id { get; set; } = string.Empty;

    [JsonPropertyName("metadata_storage_path")]
    public string MetadataStoragePath { get; set; } = string.Empty;

    [JsonPropertyName("description")]
    public IReadOnlyList<PhotoDescription> Description { get; set; } = [];

    [JsonPropertyName("tags")]
    public IReadOnlyList<PhotoTag> Tags { get; set; } = [];
}

public class PhotoDescription
{
    [JsonPropertyName("tags")]
    public IReadOnlyList<string> Tags { get; set; } = [];

    [JsonPropertyName("captions")]
    public IReadOnlyList<PhotoCaption> Captions { get; set; } = [];
}

public class PhotoCaption
{
    [JsonPropertyName("text")]
    public string Text { get; init; } = string.Empty;

    [JsonPropertyName("confidence")]
    public double Confidence { get; init; }
}

public class PhotoTag
{
    [JsonPropertyName("name")]
    public string Name { get; init; } = string.Empty;

    [JsonPropertyName("hint")]
    public string Hint { get; init; } = string.Empty;

    [JsonPropertyName("confidence")]
    public double Confidence { get; init; }
}
```
6. Keresőfelület az Index.cshtml-be a `<hr />` fölötti `<div>` vége elé

```aspnetcorerazor
<div class="col-sm-4">
    <form method="post" asp-page-handler="Search">
        <div class="input-group">
            <input type="text" class="form-control" placeholder="Search photos" asp-for="SearchTerm" />
            <button class="btn btn-primary" type="submit">Go</button>
        </div>
    </form>
</div>
```

7. `Search` kezelőfüggvény az `IndexModel`-be

```csharp
[BindProperty(SupportsGet = true)]
public string? SearchTerm { get; set; }

public IActionResult OnPostSearch()
{
    return RedirectToPage(new { SearchTerm });
}
```

8. Listázás okosítása - Index.cshtml.cs `OnGetAsync()`

```csharp
// SAS tokenek legyártása
if (!string.IsNullOrWhiteSpace(SearchTerm))
{
    var searchResults = await searchClient.SearchAsync<PhotoDocument>(SearchTerm, new SearchOptions
    {
        Select = { "metadata_storage_path", "description" },
        Size = 100
    });
    var blobs = new List<BlobInfo>();
    await foreach (var result in searchResults.Value.GetResultsAsync())
    {
        var doc = result.Document;
        var blobName = new Uri(doc.MetadataStoragePath).Segments[^1];
        var caption = string.Join(", ", doc.Description
            .SelectMany(d => d.Captions)
            .OrderByDescending(c => c.Confidence)
            .Select(c => $"{c.Text} ({c.Confidence:P0})"));
        blobs.Add(new BlobInfo(
            new BlobUriBuilder(photosClient.Uri) { BlobName = blobName, Sas = photosSas }
						.ToUri().ToString(),
            new BlobUriBuilder(thumbnailsClient.Uri) { BlobName = blobName, Sas = thumbnailsSas }
						.ToUri().ToString(),
            caption
        ));
    }
    Blobs = blobs;
}
else
{
    //Blobs = await photosClient.GetBlobsAsync()
}
```

9. Próba
