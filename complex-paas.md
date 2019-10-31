# Összetettebb Azure PaaS alkalmazás

A labor célja, hogy egy összetettebb cloud-native webalkalmazást készítsünk az Azure Platform-as-a-Service (PaaS) és egyéb szolgáltatásait felhasználva.

A labor alapjául [Szabó Márk](https://github.com/mark-szabo) Tech Summit Budapest 2019-es [előadása](https://github.com/mark-szabo/techsummit-demo) szolgált, amely átdolgozásra került erre a tárgyra.

## Feladat

Feladatunk a következők: 
* Funkcionális követelmények:
  * Készítsünk webalkalmazást, ahova kutyusokat és cicákat lehet feltölteni, hogy új gazdira találhassanak.
  * A user tudja böngészni az állapotokat
  * A user tud feltölteni új képet a gazdát kereső állatról
  * Az alkalmazás döntse el automatikusan, hogy a képen milyen állat szerepel (kutya, vagy macska), és ez alapján adjon egy előzetes kategória javaslatot.
  * A képről vágja le a nem releváns részeket
* Technológiai követelmények:
  * Perzisztáljuk az állatok adatait és a képeket
  * Optimalizáljunk a statikus fájlok kiszolgálását
  * Legyen a kitelepített alkalmazás működése jól nyomonkövethető, debuggolható
  * A fejlesztőkkel ne osszuk meg az érzékeny szolgáltatás kulcsokat


![Screenshot](https://github.com/totht91/techsummit-demo/raw/master/readme-images/ScreenshotShadow.png)

## Architektúra

![Architektúra](https://github.com/totht91/techsummit-demo/raw/master/readme-images/Architecture.png)

A megvalósításunk legyen a következő:
* A user egy **ASP․NET Core**-os REST API backendet és egy **React**-os frontend alkalmazást fog használni
  * Ez egy Azure **App Service**-be legyen kitelepítve
* A backend az adatok perzisztens tárolására használjon **Cosmos DB** NoSQL adatbázist
* A feltöltött képeket a backend egy **Blob Storage**-ba mentse el
* A képek klasszifikációjára használjunk az Azure **Cognitive Services** családból a **Custom Vision** gépi tanulás megoldását
  * Ezt közvetlenül a backendünk fogja hívni egy REST API-n keresztül
* A képek kivágását végezzük aszinkron módon
  * Az kivágandó képeket rakjuk be egy feldolgozási sorba
    * Ehhez most **Queue Storage**-et fogunk használni *(alternatíva lehetne még az **Azure Service Bus**)*
  * A sorban lévő feladatokat egy serverless **Azure Function** fogja feldolgozni
    * A feladatokhoz tartozó adatokat az adatbázisból, a képeket a blob tárhelyről veszi
  * A képek kivágását szintén egy **Cognitive Service** fogja végezni
  * Az állatok nem jelennek meg addig a felületen, amíg ez a háttérművelet be nem fejeződött. Ezt egy flaggel jelezzük a DB-ben. Ha végzett a feladatával a function, akkor publikáltra állítja az állat rekordját és frissíti azt az új képpel.
* A statikus fájlok kiszolgálásának optimalizációjára használjuk az **Azure CDN** szolgáltatását
  * Esetünkben most az állatok képeit tároljuk itt
* A kitelepített környezet szolgáltatásainak kulcsait tároljuk **Azure Key Vault**-ban
* A kitelepített alkalmazás monitorozásához integráljuk az **Application Insights** szolgáltatást

## Megvalósítás

### Kiinduló projekt

🛠 Klónozzuk le a kiinduló projektet a C:\work\\[neptun]\ mappánkon belül egy új mappába.

```cmd
TODO
```

🛠 Nyissuk meg a MyNewHome.sln solution-t és tekintsük át azt. 

**TODO**

Sok minden előre elkészítve van már nekünk. Most nem kódolni szeretnénk, hanem összerakni azt a felhő architektúrát, amit az előző fejezetben megálmodtunk. A további implementáció a laborútmutatóból másolhatók, egy egy kevés magyarázat is tartozik hozzájuk.

### App Service

🛠 Hozzunk létre az azure portálon egy új Resource Group-ot `MyNewHome` néven. Ebbe fogunk a mai órán dolgozni.

🛠 Hozzunk létre egy új Web App-ot a `MyNewHome` resource groupba `mynewhome-[neptun]` néven. Ilyenkor a `mynewhome-[neptun].azurewebsites.net` címen lesz majd elérhető a webalkalmazásunk.  

Beállítások
* Publish: code
* Runtime .NET Core 2.2
* OS: Windows
* Region: West EU
* App Service Plan:
  * Hozzunk létre egy új plant a Create New gombbal `MyNewHomePlan` néven
  * Az ingyenes F1 csomag elég lesz most nekünk
* Monitoring fülön kapcsoljuk be az App Insights-ot, egy új példány létrehozásával (default)

A kiinduló projektet publikáljuk ki az App Service-be. Ezt otthon legegyszerűbben úgy tudjuk megtenni, hogy a Visual Studioba bejelentkezünk a fiókunkkal, ami után a webes projekten jobb gomb / Publish varázslóval könnyedén tudunk deployolni. Mivel labor gépen nem szeretnénk bejelentkezni, használjuk inkább az  előre elkészített konfigurációs állományt (publish profile), ami lényegében egy XML fájl.

🛠 Töltsük le a **Get publish profile** gombbal az állományt 

🛠 Publikáljuk ki a projektet a VS-ből:
* projekten jobb gomb / Publish
* import profile, majd tallózzuk ki a letöltött configot
* Publish indítása

### Key Vault

ASP․NET Core esetben a konfigurációt az alkalmazás több helyről olvassa fel: konzol argumentumok, környezeti változók, application.json, (lokális debug esetben client secrets). Mi ezt szeretnénk most kiegészíteni azzal, hogy az Azure Key Vault-ból is olvassa fel a konfigurációt, ha élesbe telepítettük ki az alkalmazásunkat.

🛠 Hozzunk létre egy új Azure Key Vault-ot az aktuális resource groupunkba `MyNewHome-[neptun]-KeyVault` néven
* Region: West EU
* Pricing Tier: Standard

A Key Vaulthoz minden hozzáférés alapvetően le van tiltva. Most olyan authentikációs módszert választunk, ahol a web alkalmazást futtató service user (*system assigned managed identity*) nevében fogunk hozzáférni a biztonságos tárhoz.

🛠 Kapcsoljuk be az App Service / Identity menüben a *system assigned managed identity* beállítást

Ilyenkor létrejön egy user, akinek a nevében fog futni az App Service-ünk. Erre azért lesz szükség, hogy be tudjuk állítani a Key Vaultban a hozzáférési jogosultságokat.

🛠 Állítsuk be a jogosultságokat a Key Vault-ban
* Key Vault / Access policies / Add Access Policy
  * Configure from template: Key and Secret management
  * Key permissions: nekünk elég most csak a *Get* és a *List*
  * Secret permissions: nekünk elég most csak a *Get* és a *List*
  * Select principal: újonnan létrehozott managed identity (tipikusan az app service neve)
  * Add gomb

🛠 Vegyük fel az Azure Key Vault-hoz kapcsolódó NuGet csomagokat a `MyNewHome.Infrastructure` projektbe.

```xml
<PackageReference Include="Microsoft.Extensions.Configuration.Abstractions" Version="2.2.0" />
<PackageReference Include="Microsoft.Extensions.Configuration.AzureKeyVault" Version="2.2.0" />
```

🛠 Valósítsuk meg a `MyNewHome.Infrastructure` projektben lévő `ConfigurationBuilderExtensions.AddAzureKeyVault()` segédfüggvényt.

```C#
public static IConfigurationBuilder AddAzureKeyVault(this IConfigurationBuilder builder)
{
    var config = builder.Build();
    var keyVaultBaseUrl = config.GetValue<string>("KeyVault");

    var azureServiceTokenProvider = new AzureServiceTokenProvider();
    var keyVaultClient = new KeyVaultClient(
        new KeyVaultClient.AuthenticationCallback(
            azureServiceTokenProvider.KeyVaultTokenCallback));
    builder.AddAzureKeyVault(keyVaultBaseUrl, keyVaultClient, new DefaultKeyVaultSecretManager());

    return builder;
}
```

Az az oka annak, hogy külön projektben van ez a konfiguráció, hogy majd az Azure Function projektünk is tudja használni ezt a kódot.

Figyeljük meg, hogy az aktuális configból olvassuk ki az URL-t, `KeyVault` kulcsú beállításként. Ezt most környezeti változóként fogjuk kezelni a telepített alkalmazásban. A managed identity authentikációt a `KeyVaultClient` megoldja, ha a fenti beállításokat választjuk.

🛠 Adjuk meg a Web Appban, a használandó Key Vault URL-jét, amit a Key Vault áttekintő nézetéről tudunk kimásolni. Megadni az App Service / Configuration / Application Settings / New application setting opcióval tudjuk. Kulcs: `KeyVault`, érték: a kimásolt Key Vault URL.

🛠 Az API projekt `Program` osztályában használjuk az `AddAzureKeyVault` segédfüggvényünket, de csak akkor, ha éles környezetben vagyunk.

```C#
public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
    WebHost.CreateDefaultBuilder(args)
        .ConfigureAppConfiguration((context, builder) =>
        {
            if (context.HostingEnvironment.IsProduction())
            {
                builder.AddAzureKeyVault();
            }
        })
        .UseStartup<Startup>();
```

🛠 Indítsuk újra a Web Appot és próbáljuk ki.

A Key Vault-unkban még nincs semmi, de nem is használja most az alkalmazás semmire.

> **Megj.:** Most az `IConfiguration`-t közvetlenül használjuk mindenhol. Egy éles alkalmazásban érdemes lenne használni az Options mintát (`IOption<T>`), hogy erősen típusosan kezeljük a konfigurációinkat. https://docs.microsoft.com/en-us/aspnet/core/fundamentals/configuration/options?view=aspnetcore-3.0

## Cosmos DB és Storage

Az alkalmazásunk adatait egy Cosmos DB fogja tárolni. Most csak egy entitásunk lesz a `Pet`, így elég a legegyszerűbb konfiguráció. A képeket pedig kanonikus módon egy Blob Storage-ba fogjuk tenni.

🛠 Hozzunk létre a recource groupunkba egy Cosmos DB példányt
* Account name: `mynewhome-[neptun]-db`
* API: Core
* Apache Spark: None
* Location: West EU
* Geo redundancy: Disable
* Multi-region writes: Disable

Amíg ez teker térjünk át a Storage-ra.

🛠 Hozzunk létre egy Storage Accountot a resource groupunkba `mynewhome[neptun]storage` néven.

🛠 A Key Vault-ban adjuk meg a Cosmos DB és a Storage connection string-jeit Secret-ként az alábbi kulccsal és értékekkel
* `CosmosConnectionString`: Cosmos DB / Keys / PRIMARY CONNECTION STRING
* `StorageConnectionString`: Storage / Keys / Connection String

🛠 Tekintsük át hogyan használjuk a Cosmos DB-t a `PetService`-ben. Lényegében a CRUD műveleteket valósítottuk meg most az alacsony szintű API-n keresztül. Minimális ORM funkcionalitást kapunk, mert a `Pet` osztályt tudjuk használni a műveletek során, de például a lekérdezéseket már nem tudjuk LINQ-kel megvalósítani. Ha itt is ORM-et szeretnénk használni akkor érdemes megvizsgálni az Entity Framework Core 3.0 Cosmos DB támogatását.

🛠 Implementáljuk a `PetController` `UploadAndRecognizeImage` metódusában a Blob storage kezelését. 

```C#
[HttpPost("upload")]
public async Task<ActionResult> UploadAndRecognizeImage()
{
    var image = Request?.Form?.Files?[0];
    if (image == null) return BadRequest();

    // Retrieve a reference to a container
    var container = _storage.CreateCloudBlobClient().GetContainerReference("pets");

    // Create the container if it doesn't already exist
    await container.CreateIfNotExistsAsync();

    // Set container access level
    await container.SetPermissionsAsync(new BlobContainerPermissions { PublicAccess = BlobContainerPublicAccessType.Container });

    string ext = GetImageExtension(image.ContentType);
    if (ext == null) return BadRequest();

    // Upload image from stream with a generated filename
    var blob = container.GetBlockBlobReference(Guid.NewGuid().ToString() + "." + ext);
    await blob.UploadFromStreamAsync(image.OpenReadStream());

    var url = blob.Uri.AbsoluteUri;

    // TODO recognize pet type

    return Ok(new { url, type = "", probability = 0 });
}
```

A kód lényegében létrehoz egy klienst, amin keresztül létrehozunk egy konténert `pets` néven, publikus hozzáféréssel, majd ebbe a konténerbe feltöltjük a képet. A kliensnek leküldjük ezt az URL-t, hogy meg tudja jeleníteni a felületen. A `type` és a `probability` mezőket most csak mock értékekkel feltöltjük. Ezeket fogja majd a kognitív szolgáltatásunk tölteni.

> **Megj.:** Most nem töltjük az időt, hogy szépen kiszervezzük ezt a kódot. Egy éles alkalmazásban érdemes lenne ezeket külön service osztályokba szervezni.

🛠 Indítsuk újra a web appot! Próbáljuk ki! 
* Töltsünk fel egy új kutyust/cicát. 
* Nézzük meg, hogy a storage-ben megjelent-e a képe
  * Storage / Storage Explorer / Blobs
* Nézzük meg, hogy a DB-be is bekerültek-e az adatok.
  * Cosmos DB / Data Explorer / pets / items
  * Írjuk át a published tulajdonságot `true`-ra: megjelenik a felületen a kutyus.

## Cognitive Services

Az állatok klasszifikációjához és a kép kivágásához az Azure Cognitive Services szolgáltatásait fogjuk igénybe venni, amik mesterséges intelligencia alapú megoldásokat nyújt sok problémára nagyon egyszerű módon.

### Klasszifikáció - Cognitive Service Custom Vision

A klasszifikációhoz a Custom Vision komponenst fogjuk feltanítani egy betanító adathalmazzal, ami alapján majd becslést tud adni az újonnan kapott képeken látható állat fajáról.

🛠 Hozzunk létre egy új Custom Vision erőforrást a resource groupunkba `MyNewHome-CustomVision` néven.
* Training, Prediction Location: West EU
* Training, Prediction Pricing Tier: F0

Ez még csak az Azure-os erőforrás, ami esetünkben csak a számítási kapacitást és a számlázási egységet adja. Ebben még külön projekteket kell definiáljunk, ahol feltaníthatjuk a mesterséges intelligenciát.

🛠 Hozzunk létre egy új projektet és tanítsuk fel néhány tesztadattal a modellt
* Nyissuk meg a https://www.customvision.ai/projects oldalt
* Figyeljünk, hogy a jobb felső sarokban jó subscription legyen kiválasztva
* Hozzunk létre egy új projektet
  * Name: `CatOrDog`
  * Resource: `MyNewHome-CustomVision`
  * Project Type: Classification => csak címkézni akarjuk a képeket tartalmuk alapján
  * Classification Types: Multiclass => Egy képhez egy címket (tag) tartozhat
  * Domain: General
* A projektbe töltsük fel a macskás képeinket a kiinduló projekt `test-images/cat` mappájából és adjunk neki `cat` tag-et, majd ismételjük meg ezt a kutyákkal is a `test-images/dog` mappából `dog` taggel
* Kattintsunk a Train gombra, és válasszuk a Quick opciót
* A Quick test gombra kattintva próbáljuk ki a feltanított modellt egy internetről kitallózott képpel
* Figyeljük meg, hogy a Quick test eredményei megjelennek a Predictions fül alatt is, ahol ezekre is megadhatjuk a címkéket, amivel tovább taníthatjuk a modellt a Train gomb megnyomásával
* A használni kívánt iterációt publikáljuk a Performance fül alatt

**TODO kód**

Vegyük fel a Key Vaultba a Custom Vision-höz tartozó secreteket:
* `CustomVision--ApiKey` kulccsal az Azure portálon Custom Vision / Quick start / Api key1 értékét. 
  * Vigyázzunk mert van, hogy egy teljesen új erőforrást hoz létre a prediction-nek a custom vision. Ennek a kulcsát és URL-jét használjuk!
* `CustomVision--ProjectId` kulccsal a custom vision portálon a projekt guidját, amit az url-ben találunk

> **Megj.:** Figyeljük meg hogy a hierarchikus config kulcsokat az Azure Key Vaultban `:` helyett `--` karakterekkel kell elválasztani.

Publikáljuk a webes projektünket és próbáljuk ki a feltöltést. Fel kell ismernie, az állat típusát a képről.

### Kép kivágása

A kép okos kivágására az Azure Computer Vision szolgáltatását fogjuk használni.

Hozzunk létre az Azure portálon egy Computer Vision erőforrást `MyNewHome-ComputerVision` néven.

**TOOD Code**

**TODO Azure Function**

! TODO külön property kellett a projektbe, hogy működjön

## Azure CDN

**TODO csináljunk egyet a blob storage-ra**

**TODO code**

## Application Insights

### Track Exception

TODO snapshot debugging, publish profile

### Track Event

TODO