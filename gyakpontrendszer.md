# Házi feladat feltételrendszer - 2019 - Még nincs véglegesítve!

A 2019/20-as őszi félévben házi feladatként hivatalos Microsoft-os gyakorlatok elvégzését fogadjuk el. A gyakorlatok csak a lentebb megadott halmazból kerülhetnek ki, de ezeken belül szabadon válogathattok. Minden gyakorlathoz egy időtartamot adott meg a készítője, a gyakorlat elvégzésével ezt az időtartamot beszámítjuk a jegyszerzéshez. 

Az alábbi képzési terv a képzési terveknél lentebb írt szabályok szerinti elvégzése mindenki számára kötelező  (kivéve megajánlott jegyesek): [Azure fundamentals](https://docs.microsoft.com/en-us/learn/paths/azure-fundamentals/). Ezen gyakorlat ideje is beszámít a jegyszerzéshez.

### Védésről általában
A házi feladatot védeni kell. A védés során az önálló elvégzést ellenőrizzük.

Védés ideje és helye: az utolsó gyakorlat helye és ideje.

## Azure Learn Képzési Tervek (Learning Paths)
Az Azure Learn oldalon találtok gyakorlatmodulokat, amik képzési tervekbe vannak összefogva. Házi feladatként az alábbi szűrés által kijelölt képzési tervek számítanak be: [szűrés](https://docs.microsoft.com/en-us/learn/browse/?products=azure&resource_type=learning%20path&roles=business-analyst%2Cdata-scientist%2Cai-engineer%2Cdeveloper%2Cdevops-engineer%2Csolution-architect%2Cadministrator%2Cdata-engineer).

Azaz a [tallózó oldalon](https://docs.microsoft.com/en-us/learn/browse/) azok jönnek szóba, melyek
- képzési terv típusúak (Type: Learning Path) és
- Azure-ra vonatkoznak (Products: Azure) és
- szerepkörük bármi lehet, kivéve üzleti felhasználó (Role: nem Business User)

Egyéb szabályok:
- az összes elvégzett képzési tervet ugyanazon személyes Microsoft account-otokkal belépve végezzétek el
- különálló modulok nem elfogadhatók
- részben teljesített képzési tervek nem elfogadhatók

Beszámított idő képzési tervenként: a képzési terv címe alatt látható időatartam.

### Védés
A személyes Microsoft account-otokkal belépve a MS Learn oldalra igazolnotok kell a képzési tervek elvégzését.
Ezen túlmenően szúrópróbaszerűen 
  - belekérdezünk az elméleti részbe (lásd a modulok végén a "knowledge check" részeket) 
  - vagy egy kisebb gyakorlati rész újraelvégzését kérjük (pl. tölts föl egy fájl Azure Data Lake Storage Gen1-be)
  - vagy ha megvannak még az Azure erőforrások, akkor azt kérjük, hogy mutasd be az elkészült alkalmazást
Ha valamelyik képzési terv bármely moduljánál a védés nem sikerül, a teljes képzési terv idejéből semmit sem lehet beszámítani.

## Microsoft Cloud Workshop

Bármelyik Hands-on lab ideje beszámítható a [Microsoft Cloud Workshop](https://microsoftcloudworkshop.com/) oldalról. Ezek általában komplexebb gyakorlatok a Microsoft Learn oldalhoz képest, több Azure erőforrást használnak. 

Egyéb szabályok:
- csak olyan labort végezzetek el, ahol a laborútmutatóban az egyes feladatoknál meg van adva időtartam (pl. Duration: 45 minutes)
- részben teljesített laborok nem elfogadhatók

Tippek:
- laborok egy github repo-ban vannak, a repo-n belül a *Hands-On lab* mappában vannak a legfontosabb leírások
- általában egy *Before the HOL - <labor címe>.md* fájl írja le, hogy milyen előfeltételei vannak a labornak. Ezt előzetesen érdemes átolvasni.
- általában egy *HOL step-by-step - <labor címe>.md* maga a laborútmutató

Beszámított idő laboronként: a feladatoknál megadott időtartamok összege

### Védés
Szúrópróbaszerűen 
  - egy kisebb gyakorlati rész újraelvégzését kérjük (pl. tölts döl egy fájl Azure Data Lake Storage Gen1-be)
  - vagy ha megvannak még az Azure erőforrások, akkor azt kérjük, hogy mutasd be az elkészült alkalmazást
Ha valamelyik labor bármely feladatánál a védés nem sikerül, a teljes labor idejéből semmit sem lehet beszámítani.

## Értékelés

A fenti feltételeknek megfelelő összes elvégzett és megvédett gyakorlat/labor beszámítható időtartamait összeadjuk és ezen összeg alapján alakul ki a félévközi jegy. A jegy számítása:

| Jegy          | Időtartam (perc)|
| ------------- | --------------- |
| 5             | 1261 - 1500     |
| 4             | 1051 - 1260     |
| 3             | 826 - 1050      |
| 2             | 600 - 825       |

## Azure erőforrások és költségek

A költségek megtervezése, figyelése is a feladat része. Ha a hallgatói előfizetésen a kredit elfogy, az előfizetés befagyasztásra kerül. Vannak erőforrástípusok, melyeknél a leállítás csökkenti vagy megszünteti a költséget (pl. virtuális gép), ugyanakkor vannak, melyeket nem lehet költségsprólás miatt "kikapcsolni" (tipikusan a tárolást végző erőforrások, adatbázisok). A kredit elfogyása megakadályozhatja, hogy elvégezzétek a házi feladatot!

Tipp: vannak olyan képzési tervek, ahol lehetőség van Azure Sandbox használatára (pl. https://docs.microsoft.com/en-us/learn/modules/create-cosmos-db-for-scale/2-create-an-account), ilyenkor ez még egy utolsó mentsvár lehet, hiszen ez egy olyan Azure környezet, amihez nem kell előfizetés. Az Azure Sandbox-ról bővebben [itt](https://docs.microsoft.com/en-us/learn/support/?pivots=sandbox).

Ha a házi feladat elvégzése **után** fogy el a kredit, az nem kizáró ok a védésre, de törekedjetek rá, hogy ez ne történjen meg. Nem kötelező a házi feladat elvégzése után az erőforrásokat megtartani, ha máskülönben elfogyott volna az előfizetésen a kredit.

## A szabályrendszer változása

Fenntartjuk a jogot
- az elvégezhető gyakorlatok halmazának bővítésére
- a jegyszámítási határok kedvezőbbé tételére
- pontosításra, helyesírási hibák javítására

Ezen változtatásokat hallgatók is kezdeményezhetik *pull request* küldésével.
A változásokat a github history-ban követhetitek.
