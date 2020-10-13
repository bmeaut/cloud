# Azure Storage Hands-On Lab
https://github.com/microsoft/AcademicContent/blob/master/Labs/Azure%20Services/Azure%20Storage/Azure%20Storage%20and%20Cognitive%20Services%20(MVC).md

Sajnos már nagyon elavult a leírás :disappointed:

## Azure Portal 
### Nyelvi beállítások
A jobb felső részen fogaskerék ikonra bökve. Érdemes angolra állítani.

### Költségfigyelés
https://docs.microsoft.com/en-us/azure/billing/billing-check-free-service-usage
Ebben laborban:
 - Storage -> 5 GB LRS blob hallgatóknak ingyenes 12 hónapig
 - Computer Vision -> ha free tier-t választod, akkor ingyenes (kvóta van)
 
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
                <input type="submit" id="submit" style="display: none" asp-page-handler="Upload"/>
            </form>
        </div>
        <div class="col-sm-4 float-right">
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

public async Task<IActionResult> OnPostUploadAsync()
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
    return new RedirectToAction("Index");            
}
```

10. Példaképek [letöltése](https://a4r.blob.core.windows.net/public/cs-storage-resources.zip)

11. Nézzük meg mit műveltünk Azure Storage Explorer-ben és a weboldal forrásában is. Ha átírjuk a thumbnail URI-ban a /thumbnail/-t /photos/-ra, megkapjuk az eredeti képet.

## Ex. 4.
- Kihagyható

## Ex. 5.
1. Vision szolgáltatás létrehozása
 - F0 plan
 - ugyanabba a resource group-ba és régióba, mint ahol a  storage account van

2. Új secret-ek a Keys & Endpoint lapról

```bash
dotnet user-secrets set "Az:VisionEndpoint" "https://valami.cognitiveservices.azure.com/"
dotnet user-secrets set "Az:VisionKey" "titok"
```

3. NuGet csomag hozzáadása

```bash
dotnet add package Microsoft.Azure.CognitiveServices.Vision.ComputerVision
```

4. Feltöltés okosítása

```csharp
/**/public async Task<IActionResult> OnPostUploadAsync()
/**/{
       ComputerVisionClient vc =  
           new ComputerVisionClient(new ApiKeyServiceClientCredentials(_config["Az:VisionKey"])){ Endpoint = _config["Az:VisionEndpoint"] };
       VisualFeatureTypes?[] features = new VisualFeatureTypes?[] { VisualFeatureTypes.Description };   
/**/
/**/    BlobServiceClient blobSvc = new BlobServiceClient(_config["Az:StoreConnString"]);
/**/    BlobContainerClient blobccP=blobSvc.GetBlobContainerClient("photos");
/**/    BlobClient blobc= blobccP.GetBlobClient(Upload.FileName);
/**/    
/**/    using(Stream stream= Upload.OpenReadStream())
/**/    {
/**/        var resp=await blobc.UploadAsync(stream);
            var analResult = await vc.AnalyzeImageAsync(blobc.Uri.ToString(), features);
            var blobMetaDict=analResult.Description.Tags
                .Select((t,i)=> new KeyValuePair<string,string>(nameof(analResult.Description.Tags)+i, t))
                .Concat(new Dictionary<string,string>{{nameof(analResult.Description.Captions),analResult.Description.Captions[0].Text}})
                .ToDictionary(kvp=>kvp.Key, kvp=>kvp.Value);
            await blobc.SetMetadataAsync(blobMetaDict);
/**/        stream.Seek(0,SeekOrigin.Begin);
/**/        /*...*/
/**/    }
/**/    return RedirectToAction("Index");
/**/}
```

5. Listázás okosítása
```csharp
 Blobs=await blobcc.GetBlobsAsync()
                .Select(b=>blobcc.GetBlobClient(b.Name))
                .SelectAwait(async bc=> new {(await bc.GetPropertiesAsync()).Value.Metadata, Uri=bc.Uri.ToString(), bc.Name})                
                .Select(x=>new BlobInfo{ImageUri=x.Uri
                            , ThumbnailUri=x.Uri.Replace("/photos/","/thumbnails/"), 
                            Caption=x.Metadata.ContainsKey("Captions")? x.Metadata["Captions"]:x.Name})                
                .ToListAsync();
```

6. Próba

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
public ActionResult OnPostSearchAsync()
{
    return RedirectToAction("Index", new { term = SearchTerm });
}
```

3. Lekérdező művelet okosítása

```csharp
    public async Task OnGet(string term)
/**/{
/**/    BlobServiceClient blobSvc = new BlobServiceClient(_config["Az:StoreConnString"]);
/**/    BlobContainerClient blobcc=blobSvc.GetBlobContainerClient("photos");
/**/    
/**/    Blobs=await blobcc.GetBlobsAsync()
/**/        .Select(b=>blobcc.GetBlobClient(b.Name))
/**/        .SelectAwait(async bc=> new {(await bc.GetPropertiesAsync()).Value.Metadata, Uri=bc.Uri.ToString(), bc.Name})  
            .Where(x=>string.IsNullOrEmpty(term) || 
                      x.Metadata.Any(m=>m.Key.StartsWith("Tags") && m.Value.Equals(term, StringComparison.InvariantCultureIgnoreCase)))
/**/        .Select(x=>new BlobInfo{ImageUri=x.Uri
/**/                    , ThumbnailUri=x.Uri.Replace("/photos/","/thumbnails/"), 
/**/                    Caption=x.Metadata.ContainsKey("Captions")? x.Metadata["Captions"]:x.Name})                
/**/        .ToListAsync();
         SearchTerm=term;
/**/                            
/**/}
```

4. Próba

