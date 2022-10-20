# Házi feladat feltételrendszer - 2022/23 őszi félév

*Még nincs véglegesítve 2022. őszi félévre!*

A 2022/23-ss őszi félévben házi feladatként hivatalos Microsoft-os gyakorlatok elvégzését, oktatási anyagok feldolgozását fogadjuk el. A gyakorlatok, anyagok **csak a lentebb megadott halmazokból kerülhetnek ki**, de ezek között szabadon válogathattok. Minden gyakorlathoz, anyaghoz egy időtartamot adott meg a készítője, a gyakorlat, anyag elvégzésével ezt az időtartamot beszámítjuk a jegyszerzéshez. 

### Közös kötelező rész

**[A teljes Azure Fundamentals minősítéshez tartozó ingyenes online felkészítő anyag](https://docs.microsoft.com/en-us/learn/certifications/azure-fundamentals/)** képzési terv a képzési terveknél lentebb írt szabályok szerinti elvégzése **mindenki számára kötelező**  (kivéve megajánlott jegyesek). Az oldalon görgessetek le a *Two ways to prepare* részhez, az *Online - Free* fülön található az összesen 3 képzési terv kb. 6 órában. **Mind a 3 terv** elvégzése kötelező.

Ezen tervek ideje is beszámít a jegyszerzéshez.

### Védésről általában

A házi feladatot védeni kell. A védés során az önálló elvégzést ellenőrizzük.

Védés helye, ideje: az utolsó óra során.

## Azure Learn képzési tervek (Learning Paths)

A [Microsoft Learn oldalon](https://docs.microsoft.com/hu-hu/learn/) találtok gyakorlatmodulokat, amik **képzési tervekbe** vannak összefogva. Házi feladatként az alábbi szűrés által kijelölt **képzési tervek** számítanak be: [szűrés](https://docs.microsoft.com/en-us/learn/browse/?products=azure&resource_type=learning%20path&roles=administrator%2Cai-edge-engineer%2Cai-engineer%2Cmaker%2Cdata-analyst%2Cdata-engineer%2Cdata-scientist%2Cdatabase-administrator%2Cdeveloper%2Cdevops-engineer%2Cidentity-access-admin%2Cnetwork-engineer%2Cprivacy-manager%2Crisk-practitioner%2Csecurity-engineer%2Csecurity-operations-analyst%2Csolution-architect%2Cstudent%2Ctechnology-manager).

Azaz a [tallózó oldalon](https://docs.microsoft.com/en-us/learn/browse/) azok jönnek szóba, melyek
- képzési terv típusúak (Type: Learning Path) és
- Azure-ra vonatkoznak (Products: Azure) és
- szerepkörük bármi lehet, **kivéve** az alábbi angol megnevezésűek:
  - üzleti felhasználó (Business User, Owner, Analyst stb.)
  - Functional Consultant
  - Auditor
  - School Leader
  - Hirgher Education Educator

Számos képzési terv elérhető magyarul is.

Egyéb szabályok:

- az összes elvégzett képzési tervet ugyanazon egyetemi M365 (@edu.bme.hu) account-otokkal belépve végezzétek el
- részben elvégzett képzési tervek, illetve olyan modulok, ahol a tartalmazó képzési terv nincs elvégezve - nem elfogadhatók

Beszámított idő képzési tervenként: a képzési terv címe alatt látható időatartam.

### Védés

Az egyetemi M365 account-otokkal (@edu.bme.hu) belépve a [MS Learn oldalra](https://docs.microsoft.com/hu-hu/learn/) igazolnotok kell a képzési tervek elvégzését.
Ezen túlmenően szúrópróbaszerűen 
  - belekérdezünk az elméleti részbe (lásd a modulok végén a "knowledge check" részeket) 
  - vagy egy kisebb gyakorlati rész újraelvégzését kérjük (pl. tölts föl egy fájlt Azure Data Lake Storage Gen1-be)
  - vagy ha megvannak még az Azure erőforrások, akkor azt kérjük, hogy mutasd be az elkészült alkalmazást

Ha valamelyik képzési terv bármely moduljánál a védés nem sikerül, a teljes képzési terv idejéből semmit sem lehet beszámítani.

## Microsoft Cloud Workshop

Bármelyik *Hands-on lab* (továbbiakban:labor) ideje beszámítható a [Microsoft Cloud Workshop](https://microsoftcloudworkshop.com/) oldalról. Ezek általában komplexebb gyakorlatok a Microsoft Learn oldalhoz képest, több Azure erőforrást használnak. 

Egyéb szabályok:
- csak olyan labort végezzetek el, ahol a laborútmutatóban az egyes feladatoknál meg van adva időtartam (pl. Duration: 45 minutes) [Példa](assets/mcw_duration.png)
- részben teljesített laborok nem elfogadhatók

Tippek:
- laborok egy github repo-ban vannak, a repo-n belül a *Hands-On lab* mappában vannak a legfontosabb leírások
- általában egy *Before the HOL - <labor címe>.md* fájl írja le, hogy milyen előfeltételei vannak a labornak. Ezt előzetesen érdemes átolvasni.
- általában egy *HOL step-by-step - <labor címe>.md* maga a laborútmutató

Beszámított idő laboronként: a feladatoknál megadott időtartamok összege

### Védés
Szúrópróbaszerűen 
  - a laborútmutatóból egy kisebb rész újraelvégzését kérjük
  - vagy ha megvannak még az Azure erőforrások, akkor azt kérjük, hogy mutasd be az elkészült alkalmazást

Ha valamelyik labor bármely feladatánál a védés nem sikerül, a teljes labor idejéből semmit sem lehet beszámítani.

## Értékelés

A fenti feltételeknek megfelelő összes elvégzett és megvédett képzési terv/gyakorlat/labor beszámítható időtartamait összeadjuk és ezen összeg alapján alakul ki a félévközi jegy. A jegy számítása:

| Jegy          | Időtartam (perc)      |
| ------------- | ----------------------|
| 5             | 1261 - 1500 (= 25 óra)|
| 4             | 1051 - 1260           |
| 3             | 826 - 1050            |
| 2             | 600 - 825             |

## Azure erőforrások és költségek

A költségek megtervezése, figyelése is a feladat része. Ha a hallgatói előfizetésen a kredit elfogy, az előfizetés befagyasztásra kerül. Vannak erőforrástípusok, melyeknél a leállítás csökkenti vagy megszünteti a költséget (pl. virtuális gép), ugyanakkor vannak, melyeket nem lehet költségsprólás miatt "kikapcsolni" (tipikusan a tárolást végző erőforrások, adatbázisok). A kredit elfogyása megakadályozhatja, hogy elvégezzétek a házi feladatot!

*Tipp*: vannak olyan képzési tervek, ahol lehetőség van *Azure Sandbox* használatára (pl. [ebben a modulban](https://docs.microsoft.com/en-us/learn/modules/create-cosmos-db-for-scale/2-create-an-account)), ilyenkor ez még egy utolsó mentsvár lehet, hiszen ez egy olyan Azure környezet, amihez nem kell előfizetés. Az Azure Sandbox-ról bővebben [itt](https://docs.microsoft.com/en-us/learn/support/faq?pivots=sandbox).

Ha a házi feladat elvégzése **után** fogy el a kredit, az nem kizáró ok a védésre, de törekedjetek rá, hogy ez ne történjen meg. Nem kötelező a házi feladat elvégzése után az erőforrásokat megtartani, ha máskülönben elfogyott volna az előfizetésen a kredit. Az Azure Sandbox erőforrások legfeljebb 4 óráig élnek, így értelemszerűen nem kell (nem lehet) őket megtartani.

## A szabályrendszer változása

Véglegesítés után is fenntartjuk a jogot
- az elvégezhető gyakorlatok halmazának bővítésére
- a jegyszámítási határok kedvezőbbé tételére
- pontosításra, helyesírási hibák javítására
- egyéb változtatásra egyetemi szabályok változása miatt (pl. járványhelyzet miatt)

Ezen változtatásokat hallgatók is kezdeményezhetik *pull request* küldésével.
A változásokat a [github history-ban](https://github.com/bmeaut/cloud/commits/master/gyakpontrendszer.md) követhetitek.
