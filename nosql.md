# Azure adatkezelés - NoSQL
https://azure.microsoft.com/en-us/overview/data-platform/

https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/data-store-overview

## Cosmos DB
Multimodális NoSQL adatbázis: https://docs.microsoft.com/en-us/azure/cosmos-db/introduction

1. Cosmos DB létrehozása az Azure portálon
    - most nem ezt fogjuk használni, de most már van 30 napos trial is (elvileg újrakezdhető)
    - https://azure.microsoft.com/en-us/try/cosmosdb/
    - https://azure.microsoft.com/en-us/blog/try-azure-cosmosdb-for-30-days-free-no-commitment-or-sign-up/  
    - van emulátor is: https://docs.microsoft.com/en-us/azure/cosmos-db/local-emulator  
    - Storage Explorer támogatás   

2. Database és collection létrehozása az Azure portálon, a 400 RU-t az adatbázishoz rendeljük. Partition key-t kell beállítani (isComplete?).
    - 5 GB, 400 RU a hallgatói keret, így csak unpartitioned kollekciónk lehet
    - https://azure.microsoft.com/en-us/pricing/details/cosmos-db/
    - Költségkalkulátor: https://cosmos.azure.com/capacitycalculator/
    - Belső szerkezet: https://docs.microsoft.com/en-us/azure/cosmos-db/sql-api-resources
    - Modellezés: https://docs.microsoft.com/en-us/azure/cosmos-db/modeling-data    
    
3. Import Tool letöltése
    - https://docs.microsoft.com/hu-hu/azure/cosmos-db/import-data
    - https://aka.ms/csdmtool

4. Adatok beszerzése és kicsomagolása
    - https://github.com/bmeaut/azure-cosmosdb-dotnet/tree/master/samples/searchable-todo
    - https://github.com/bmeaut/azure-cosmosdb-dotnet/tree/master/samples/searchable-todo/data
    - https://github.com/bmeaut/azure-cosmosdb-dotnet/raw/master/samples/searchable-todo/data/items.zip

5. Adatok importja Import Tool-lal
    - connection string --> Azure Portal Keys blade, hozzáfűzni a Database=<adatbázis neve>
    - partition key, id field kitöltése, ne legyen id generálás
    - Ellenőrzés Data Explorer-rel
    - technikai mezők: https://docs.microsoft.com/en-us/azure/cosmos-db/databases-containers-items#properties-of-an-item

6. SQL lekérdezések
    - Nyelvi referencia https://docs.microsoft.com/en-us/azure/cosmos-db/sql-api-sql-query
    - Playground: https://www.documentdb.com/sql/demo


7. Searchable Todo projekt letöltése, megnyitása, konfigurálása
    - zip-ként: https://github.com/bmeaut/azure-cosmosdb-dotnet
    - vagy Visual Studio git clone
    - web.config-ba írjuk be a doc db kapcsolódási adatait
    - Global.asax-ban az utolsó két sort kommentezzük ki (ItemSearchRepository kezdetű sorok)
    - LAUNCH!
    - nézzük végig a kezdőlap betöltést és egy módosítást

## Azure Search
https://db-engines.com/en/ranking/search%2Bengine

1. Search létrehozása a portálon
    - https://docs.microsoft.com/en-us/azure/search/search-lucene-query-architecture
    - https://azure.microsoft.com/en-us/pricing/details/search/
    - Free tier-es legyen!

2. Cosmos DB collection indexelése indexerrel
    - A Cosmos DB blade-jére menjünk és ott válasszuk az Azure Search Blade-et
    - Milyen indexbeállítások vannak? https://docs.microsoft.com/en-us/rest/api/searchservice/create-index#request   
    - *todo* legyen az index neve
    - *sg* legyen az Suggester neve
    - *todoixr* legyen az indexer neve
    - mindegyik lenti legyen retrievable
    - id: key
    - title: searchable + suggester
    - desc: searchable
    - dueDate: facetable, filterable, sortable
    - isComplete: [semmi]
    - tags: facetable, filterable, searchable + suggester
    - az indexer monitorozása a Search blade-jén az Indexers csempével

3. Azure Search Query-k
    - Search Explorer blade-en: *, részszöveg, SearchAsync függvény keresése, facet-ek/count az eredményben
    - *facet*: http://mek.oszk.hu/~mekdl/keresok2012/index2.htm
    - https://docs.microsoft.com/hu-hu/azure/search/search-faceted-navigation

4. Projekt konfigurálása Search-höz
    - web.config-ba írjuk be a Search kapcsolódási adatait
    - ha csak query key-t írunk be, akkor nem fogunk tudni alkalmazásból reindexelni
    - LAUNCH

5. Search SDK beépítése
    - .NET FW verzió emelése
    - Microsoft.Azure.Search.Data NuGet csomag hozzáadása
    - *Item.cs*-ben minden *int* legyen *long*
    - átírás Search API-ra - lásd ItemSearchRepository.md
    - ellenőrizzük, hogy minden ugyanolyan jól működik-e (oldResult vs newResult változók)

6. Reindex, módosítás kezelése
    - Próbáljuk ki a módosítás hatását a keresésre, frissen módosított adatokon is működik-e a keresés
    - Használjuk a reindex funkciót
    - Jelenleg nincs beépített támogatás a real-time, azonali indexelésre, a legközelebb álló megoldás az 5 percenkénti indexer futtatás

## Epilógus
Egyéb, frissebb sample: https://github.com/Azure-Samples/search-dotnet-getting-started
