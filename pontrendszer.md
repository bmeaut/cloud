# Pontrendszer - NINCS VÉGLEGESÍTVE 2018. őszi félévre (Release Candidate)
## Általános megfontolások
- Minimum 20 pont szükséges a jegyszerzéshez
- Maximum 55 pont szerezhető
- Egy jogcímen csak egyszer szerezhető pont, kivéve, ahol ezt külön jelezzük
- Meglévő (pl. Microsoft-os) demók, mintaalkalmazások (elemei) felhasználhatók, de ezt külön jelezni kell bemutatáskor. A nem jelzett, de átvett részletek plágiumnak számítanak. Az eredeti demóban vagy mintaalkalmazásban megvalósított funckiókért pont nem adható. *Tipp:* jó házi lehet egy nem Azure-os webes/mobilos példaalkalmazás átalakítása Azure-osra.
- Egy egységes alkalmazásnak vagy egy egységes szolgáltatáshalmaznak kell készülnie, nem pedig több egymástól független demónak. Az alkalmazás funckiójától teljesen független, nem kapcsolódó funkciókért nem jár pont.
- Véglegesítés után csak a következő változások lehetnek
    - hallgatóknak kedvező változások (pl. új jogcímek)
    - elírások, megfogalmazásbeli pontosítások javítása
- A jogcímek kiírása során a felmerülő költségeket **nem vesszük figyelembe**, bár általában elérhetőek (hallgatóknak) ingyenes kvóták. A költségek megtervezése, figyelése is a feladat része. Ha a kredit elfogy, az előfizetés befagyasztásra kerül. A bemutatás során szinte biztosan nem tudunk befagyott előfizetéssel dolgozni. A befagyás elkerülése is a feladat része. Bővebb infó az elérhető felhős erőforrásokról elérhető a tárgyhonlapon.
- Emulátorok használhatók, az emulátorral megvalósított funckiókért is jár pont

## Kötelező elemek
- Frontend, ami lehet web, mobil vagy vastagkliens. Az Azure portál és a fejlesztőeszközök felülete nem számít ide.
- Az alkalmazásmodell részből kötelező legalább pontosan egy jogcímet választani.
- Az adattárolás részből kötelező legalább egy jogcímet választani
- Dokumentáció:
    - 1 db architektúra ábra a hozzátartozó nyílfeliratokkal
    - Példák: https://docs.microsoft.com/en-us/azure/architecture/example-scenario/
    - készíthető pl. Microsoft Visio-val (MS Imagine programban ingyenes hallgatóknak)
    
## Pontot érő funkciók
### Adattárolás (legalább egy választandó)
- Cosmos DB Document SQL mód használata (5-15 pont)
 - 5 pont: egy típusú entitás egy kollekcióban, egyszerű írás-olvasás
 - 10 pont: több típusú entitás egy kollekcióban, egyszerű írás-olvasás
 - +5 pont: Change Feed használata
- Cosmos DB Gráf/Cassandra/Mongo mód használata (10 pont)
- Table storage vagy Cosmos DB tábla mód használata (5-10 pont) 
  - 5 pont: írás, olvasás, módosítás, használata, partíciós kulcsok helyes megválasztása 
  - 10 pont: az előzőeken túl a storage speciális jellemzőinek kihasználása, pl. különböző típusú adatok egy táblában, több tábla használata,     
- Blob store (5-15 pont)
  - 5 pont: írás, olvasás, módosítás  
  - 10 pont: az előzőeken túl metaadatok használata, lapozásos lekérdezés 
  - 15 pont: az előzőeken túl a block blob/page blob speciális tulajdonságainak kihasználása, jogosultságkezelés (ideiglenes írási/olvasási engedélyek kiadása) 
- File storage használata (5 pont)
- Queue storage használata (10 pont) 
  - feladatkiosztás queue segítségével, legalább két olvasóval és egy íróval
- SQL Azure használata (5 pont)
- Azure Search használata (7 - 15 pont)
    - 7 pont: indexer működtetése, keresés szövegekben
    - 12 pont: indexer működtetése, keresés szövegekben és geo adatokban
    - +3 pont: adatok dúsítása Cognitive Services-szel az indexerben
- Azure Redis cache használata (5 pont)
- Azure CDN használata (5 pont)

### Alkalmazásmodell (pontosan egy választandó)
- Azure App Service (API, Web, Mobil, Logic) használata (0 - 11 pont)
    - slot-ok használata (5 pont)
    - App Insights bekötése (3 pont)
    - AutoScale (3 pont)
    - a fentiek közül egyik sem (0 pont)
- Microservice architektúra megvalósítása Azure Kubernetes Services-szel (7 pont)
- Microservice architektúra megvalósítása Azure Service Fabric vagy Service Fabric Mesh szolgáltatással (7 pont)

### Számítás
- Azure Functions használata (7 pont)
- Azure Batch használata (5 pont)
- Azure Data Lake Analytics használata (7 pont) - **KÖLTSÉGES lehet!**
    - legalább 10 GB bemenő adat átalakítása vagy analitikai lekérdezése U-SQL-lel. Az előállt eredményt fel kell használni az alkalmazásban.
- Azure HDInsights használata (7 pont) - **KÖLTSÉGES lehet!**

### Messaging, kommunikáció
- Azure SignalR Service használata (7 pont)
- Azure üzenetkezelő szolgáltatás használata (Service Bus, Event Hub, Event Grid) (7 pont szolgáltatásonként, max. 14 pont)
    - legfeljebb kétszer szerezhető meg
- Azure Stream Analytics használata (7 pont)

### Telepítés, automatizálás, DevOps
- A teljes Azure-beli infrastruktúra konfigurálása és telepítése ARM sablonnal. Be is kell mutatni! (10 pont)
- CI/CD Azure DevOps-szal (7 - 15 pont)
    - az alkalmazás fordítása időzítve vagy minden commit-ra (7 pont)
    - az előzőeken túl a lefordított alkalmazás telepítése (10 pont)
    - konténertechnológia alkalmazása +5 pont
- Azure Automation használata (5 pont)
- Visual Studio App Center használata mobilos vagy Unity-s alkalmazás esetén (5 pont)

### AI
- Cognitive Services (5 pont szolgáltatásonként, max. 10 pont)
    - legfeljebb kétszer szerezhető meg
    - Intelligens bot írása Azure Bot Service-szel (5 pont)
- Azure Machine Learning modell készítése és meghívása REST API-n keresztül (7 pont)       

### IoT - IoT hardver szükséges hozzá (pl. Raspberry Pi), tisztán szimulációért nem jár pont
- Legalább egy fizikai IoT eszköz monitorozása vagy kezelése IoT Hub használatával (5 - 7 pont)
    - csak monitorozás (5 pont)
    - vezérlés is (7 pont)
- IoT Edge használata (7 pont)

### Egyéb
- Mobilspecifikus funkciók használata - Azure Notification Hub (7 pont)
    - legalább 1 platformra (Android vagy iOS)
- Mobilspecifikus funkciók használata - Azure Mobile Offline Sync (7 pont)
- Azure AD használatata felhasználókezelésre, authentikációra (10 - 15 pont)
    - belső céges funkciókra a sima Azure AD
    - külső, sima felhasználók funckióira az Azure AD B2C
- Azure Media Services használata (10 pont)
- Azure Key Vault használata (3 pont)
- Azure Data Factory (5 - 10 pont)
    - 5 pont: Copy activity használata
    - 10 pont: bonyolultabb vezérlési szerkezetek, a Copy activityn kívül még legalább 2 további activity használata
- A véglegesített pontrendszer javítása, bővítése, módosítása pull request-tel (0-2 pont, összesen max. 5 pont)
    - Helyesírási hiba is lehet, de az oktatók döntenek, hogy hány pontot ér a módosítás
    - Többször is megszerezhető
