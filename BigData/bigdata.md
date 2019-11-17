# Big Data eszközök
Shameful önreklám: https://blog.autsoft.hu/tag/wikidataonazure/

## Azure Data Factory - HTTP -> Blob sima másolás
1. Storage létrehozása, ha nincs még
    - Name: egyedi legyen (pl. neptunkód)
    - Performance - Standard (a Prémium csak VM-ekkel használható)
    - Location - North Europe
    - Acc. kind - V2
    - Replication - LRS (a Student előfizetésben ez az ingyenes)
    - Access tier - Hot (a Student előfizetésben ez az ingyenes)
2. Data Factory létrehozása
    - Name: egyedi legyen (pl. neptunkód)
    - Version: V2
    - díjszabás nem egyszerű, de legalább olcsó: https://docs.microsoft.com/en-us/azure/data-factory/pricing-concepts
3. Copy Data Wizard
    - A Data Factory oldalán "Author & Monitor", majd az ADF management oldalán válasszuk a Copy Data csempét
    - Vegyünk fel új HTTP kapcsolatot
        - Base URL: https://github.com
        - Auth Type: Anonymous
        - a többi default, illetve értelemszerű
    - Forrás
        - Relative URL: bmeaut/azure-cosmosdb-dotnet/raw/master/samples/searchable-todo/data/items.combined.json.gz
        - megnézhetjük a github-on, hogy mi van gz-ben (spoiler: a 100 elem az előző laborról, 1 sor = 1 JSON)
        - Binary Copy: check
    - Vegyünk fel új Blob kapcsolatot, kiválasztva az előbb létrehozott Storage-ot (From Subscription)
    - Cél
        - Path: todoitems   
4. Monitorozzuk, majd ha lefutott a Blob blade-jén ellenőrizzük, hogy létrejött-e a fájl
5. Ha kell, másoljuk át a todoitems mappába és a todoitems almappáját töröljük

## Azure Data Factory - Blob -> CosmosDB másolás séma alapján + kicsomagolás
1. Cosmos DB létrehozása, ha nincs még (ezt labor elején érdemes, mert sokáig tarthat)
    - database és collection (újra)létrehozása
2. Author eszköz felfedezése
    - Klónozzuk meg az előbb létrehozott pipeline-t
    - Hozassunk létre egy új Blob típusú forrást
        - a kapcsolata legyen a már korábban létrehozott blob kapcsolat
        - de most töltsük ki a könyvtárat és a fájlnevet is, adjuk meg a blob-ban lévő gzip-et
        - Compression Type: gzip
        - Binary Copy: uncheck
        - File format: JSON, de ne engedjüük, hogy a sémát felfedezze a tömörítés beállítása előtt (`Import schema`: `None`)
    - Hozassunk létre egy új Cosmos DB típusú célt
        - új kapcsolat is kell, tallózzuk ki a Cosmos DB-nket
        - Adjuk meg a collection nevet
    - Pipeline szerkesztőjében fent az eszköztáron Trigger -> Trigger Now
3. Ellenőrizzük a monitorozó oldalon (figyeljünk a szűrő ikonocska mögötti szűrőkre is!) és a Comos DB  Data Explorer-ben








    
