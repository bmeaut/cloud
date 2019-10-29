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

Klónozzuk le a kiinduló projektet a C:\work\\[neptun]\ mappánkon bekük egy új mappába.

```cmd
TODO
```

Nyissuk meg a MyNewHome.sln solutiont és tekintsük át azt. 

**TODO**

Sok minden előre elkészítve van már nekünk. Most nem kódolni szeretnénk, hanem összerakni azt a felhő architektúrát, amit az előző fejezetben megálmodtunk.