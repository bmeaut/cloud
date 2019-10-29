# Összetettebb Azure PaaS alkalmazás

A labor célja, hogy egy összetettebb cloud-native webalkalmazást készítsünk az Azure Platform-as-a-Service (PaaS) és egyéb szolgáltatásait felhasználva.

A labor alapjául [Szabó Márk](https://github.com/mark-szabo) Tech Summit Budapest 2019-es [előadása](https://github.com/mark-szabo/techsummit-demo) szolgált, amely átdolgozásra került erre a tárgyra.

## Feladat

Feladatunk a következőek: 
* Funkcionálus követelmények:
  * Készítsünk webalkalmazást, ahova kutyusokat és cicákat lehet feltölteni, hogy új gazdira találhassanak.
  * A user tudja böngészni az állaptokat
  * A user tud feltölteni új képet a gazdát kereső állatról
  * Az alkalmazás döntse el automatikusan, hogy a képen milyen állat szerepel (kutya, vagy macska), és ez alapján adjon egy előzetes kategória javaslatot.
  * A képről vágja le a nem releváns részeket
* Technológiai követelmények:
  * Perzisztáljuk az állatok adatait és a képeket
  * Optimalizáluk a statikus fájlok kiszolgálását
  * Legyen a kitelepített alkalmazás működése jól nyomonkövethetőm debuggolható
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
  * A képek kivágását szintén egy **Congnitive Service** fogja végezni
  * Az állatok nem jelennek meg addig a felületen, amíg ez a háttérművelet be nem fejeződött. Ezt egy flaggel jelezzük a DB-ben. Ha végzett a feladatával a function, akkor publikáltra állítja az állat rekorját és frissíti azt az új képpel.
* A statikus fájlok kiszolgálásának optimalizációjára használjuk az **Azure CDN** szolgáltatását
  * Esetünkben most az állatok képeit tároljuk itt
* A kitelepített környezet szolgáltatásainak kulcsait tároljuk **Azure Key Vault**-ban
* A kitelepített alkalmazás monitorozásához integráljuk az **Application Insights** szolgáltatást

## Megvalósítás

### Kiinduló projekt

🛠 Klónozzuk le a kiinduló projektet a C:\work\\[neptun]\ mappánkon bekük egy új mappába.

```cmd
TODO
```

🛠 Nyissuk meg a MyNewHome.sln solutiont és tekintsük át azt. 

**TODO**

Sok minden előre elkészítve van már nekünk. Most nem kódolni szeretnénk, hanem összerakni azt a felhő architektúrát, amit az előző fejezetben megálmodtunk.

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

A kiinduló projektet publikáljuk ki az App Setvice-be. Ezt otthon legegyszerűbben úgy tudjuk megtenni, hogy a Visual Studioba bejelentkezünk a fiókunkkal, ami után a webes projekten jobb gomb / Publish varázslóval könnyedén tudunk deployolni. Mivel labor gépen nem szeretnénk bejelentkezni, használjuk inkább az  előre elkészített konfigurációs állományt (publish profile), ami lényegében egy XML fájl.

🛠 Töltsük le a **Get publish profile** gombbal az állományt 

🛠 Publikáljuk ki a projektet a VS-ből:
* projekten jobb gomb / Publish
* import profile, majd tallózzuk ki a letöltött configot
* Publish indítása

### Key Vault

Sajnos még nem működik a web appunk. Ha kipróbáljuk lokálisan is, akkor megfigyelhetjük, hogy az alkalmazás indulása elszáll, mivel nem találja az Azure Key Vault base urljét.

> **Tipp: startup dignosztika TODO **

🛠 Hozzunk létre egy új Azure Key Vault-ot az aktuális resource groupunkba `MyNewHome-[neptun]-KeyVault` néven
* Region: West EU
* Pricing Tier: Standard

🛠 Kapcsoljuk be az App Service / Identity menüben a *system assigned managed identity* beállítást

Ilyenkor létrejön egy user, akinek a nevében fog futni az App Service-ünk. Erre azért lesz szükség, hogy be tudjuk állítani a Key Vaultban a hozzáférési jogosultásgokat.

🛠 Állítsuk be a jogosultságokat a Key Vault-ban
* Key Vault / Access policies / Add Access Policy
  * Configure from template: Key and Secret management
  * Key permissions: nekünk elég most csak a *Get* és a *List*
  * Secret permissions: nekünk elég most csak a *Get* és a *List*
  * Select principal: újonnan létrehozott managed identity (tipikusan az app service neve)
  * Add gomb

🛠 Adjuk meg a Web Appban, a használandó Key Vault url-jét, amit a Key Vault áttekintő nézetéről tudunk kimásolni. Megadni az App Service / Configuration / Application Settings / New application setting opcióval tudjuk. Kulcs: (kiinduló projekt `Program.cs` alapján) `KeyVault`, érték: a kimásolt Key Vault url.

> **Megj.:** ASP․NET Core esetben a konfigurációt az alkalmazás több helyről olvassa fel: konzol argumentumok, környezeti változók, application.json, (lokális debug esetben client secrets). A fenti megoldás környezeti változóként kezeli az app beállításait.  
> Mi a `Program.cs`-ben annyit látunk, hogy ezeket egészítjük még ki Production környezetben a Key Vaulttal.

🛠 Indítsuk újra a Web Appot és próbáljuk ki.

A Key Vaultunkban még nincs semmi, de nem is használja most az alkalmazás semmire.



