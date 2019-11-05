# CI/CD Azure DevOps-szal

1. https://azuredevopslabs.com/ -> Kék gomb "Sign up for free now"
2. https://azuredevopslabs.com/labs/azuredevops/prereq/
  A VS solution megnyitással, futtatással lehetnek gondok:
    - .modelproj fájlt nem lehet megnyitni -> nem baj, az a projekt most nem lényeges (otthon ki lehet próbálni: https://stackoverflow.com/questions/42727430/visual-studio-2017-not-opening-modelproj)
    - a LocalDB adatbázist nem tudja létrehozni ("CREATE FILE encountered operating system error 5...")
3. CI: https://azuredevopslabs.com/labs/azuredevops/continuousintegration/
    - Task 1 harmadik lépése előtt érdemes a meglévő build-et kitörölni vagy a continous trigger-ét kikapcsolni
4. CD: https://azuredevopslabs.com/labs/azuredevops/continuousdeployment/
    - Az utolsó részt a slot-okkal nem kell megcsinálni, mivel **a slot-ok nem elérhetők az ingyenes App Service Plan-ben**
