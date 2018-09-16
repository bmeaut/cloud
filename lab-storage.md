# Azure Storage Hands-On Lab
https://github.com/bmeaut/computerscience/blob/master/Labs/Azure%20Services/Azure%20Storage/Azure%20Storage%20and%20Cognitive%20Services%20(MVC).md

## Azure Portal 
### Nyelvi beállítások
A jobb felső részen fogaskerék ikonra bökve. Érdemes angolra állítani.

### Költségfigyelés
https://docs.microsoft.com/en-us/azure/billing/billing-check-free-service-usage
Ebben laborban:
 - Storage -> 5 GB LRS blob hallgatóknak ingyenes 12 hónapig
 - Computer Vision -> ha free tier-t választood, akkor ingyenes (kvóta van)
 - App Service -> az App Service Plan-ért kellene fizetni, de van ingyenes változat (kvóta van)
 
**Tehát az egész labort ingyenes erőforrásokkal végig lehet csinálni.**

### Névválasztás
Bizonyos erőforrásoknak globálisan vagy a régióban egyedi neve kell legyen. Így könnyen előfordulhat, hogy a név már foglalt. Érdemes ilyenkor valamilyen személyre egyedi prefixet/postfixet alkalmazni pl. neptun kód vagy monogram.

## Ex. 1.
- Az egyes beállítások fölötti tooltip-eket érdemes elolvasni, értelmezni.
- Mit jelentenek az alábbi beállítások?
  - Storage V1 vs V2
  - Resource Manager (Deployment Model)
  - Replikációs modellek (Replication) - LRS legyen!
  - Teljesítményszint (Standard vs. Premium)
  - Secure Transfer
  - Resource Group
- Hogyan választjuk a régiót (Location)?

## Ex. 2.
- Ha nincs feltelepítve a Storage Explorer, akkor ezt a feladatot hagyjuk ki. (Nincs jogunk admin módban telepíteni). Helyette az Azure Portal-on a storage oldalán (blade-jén) a Blobs menüpontot használjuk a blob-ok nézegetésére/kezelésére.

## Ex. 3.
- Érdemes a rengeteg using blokk bemásolása helyett a következő pontban lévő kódot bemásolni és megkérni a Visual Studio-t, hogy rakja be a hiányzó using-okat

## Ex. 4.
- Opcionális, a végére is hagyható

## Ex. 9.
- Application Insights nem kell
- App Service Plan - **Free (F) méretű legyen!**


