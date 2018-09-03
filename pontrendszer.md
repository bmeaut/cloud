# Pontrendszer - NINCS VÉGLEGESÍTVE 2018. őszi félévre
## Kötelező elemek
- Webes frontend (pl. Azure web role/ Azure web app) használata (0 pont) 
- Háttérben működő feldolgozó (pl. Azure worker role, vagy VM role, vagy Azure Functions) használata (0 pont) 
- Storage (table,  blob, és/vagy queue) használata (pontszámok a lentiek szerint) 
    
## Pontot érő funkciók
- table storage használata (5-15 pont) 
  - 5 pont: írás, olvasás, módosítás, használata, partíciós kulcsok helyes megválasztása 
  - 10 pont: az előzőeken túl a storage speciális jellemzőinek kihasználása, pl. különböző típusú adatok egy táblában, több tábla használata,   
  - 15 pont: CosmosDB használata, szolgáltatásainak kihasználása 
- blob store (10-15 pont) 
  - 5 pont: írás, olvasás, módosítás,  
  - 10 pont: az előzőeken túl metaadatok használata, lapozásos lekérdezés 
  - 15 pont: az előzőeken túl a block blob/page blob speciális tulajdonságainak kihasználása, jogosultságkezelés (ideiglenes írási/olvasási engedélyek kiadása) 
- queue (10 pont) 
  - feladatkiosztás queue segítségével, legalább két olvasóval és egy íróval 
- Azure drive, Amazon EBS (7 pont) 
- Azure Redis Cache, Amazon ElastiCache alkalmazása (15 pont) 
- Sql Azure, Amazon RDS (10-20 pont) 
  - 10 pont: SQL Azure, Amazon RDS adatbázis (érdemi) használata az alkalmazásban (pl. felhasználó nyilvántartásra) 
  - 20 pont: pl. Sync Service használata 
- Service bus használata (5-15 pont) 
  - 5 pont: egyszerű remoting szkenárió 
  - 15 pont: tanúsítvány alapú kommunikáció 
- Access Control Service (5-10 pont) 

- Amazon Elastic MapReduce érdemi használata nagy mennyiségű adat feldolgozására (15 pont) 
- Amazon AutoScale használata, és terheléses teszt készítése (10 pont) 
- Amazon AWS webes console használatának kiváltása saját alkalmazással (5-10 pont) 
- AWS Cloud Formation használata (5-10 pont) 
