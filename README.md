# Près de chez vous

"Près de chez vous" est un site web qui permet de connaître tous les équipements (commerce, services, santé...) ou seulement certains (maternelle,salon de coiffure...) qui se trouvent autour d'un endroit donné en France.

Les paramètres de connexion au sgbd (mysql) se font via le fichier "Settings.txt".

Tous les fichiers du site sont contenues dans le dossier "Pages".

Tous les scripts sql sont contenus dans "Base de donnees/sql". "CreationTables" contient seulement les tables. "DATABASE_PresDeChezVous.sql" contient toute la base de données (y compris les tables), "DATABASE_PresDeChezVous" en est sa version compressée.

Le fichier "ScriptSQLToBDD" importe "DATABASE_PresDeChezVous.sql" lorsqu'il est executé. Il a l'avantage d'afficher l'avancement au fur et à mesure de l'importation et de s'affranchir de tout ce qui est problèmes de réglages d'importation, par exemple de limite de tailles de fichier ou de limite de temps d'importation.

Le dossier "csv" et le fichier "ScriptToSQL" sont inutiles. Ils ont seulement servi à la création de la base de données.

Certains fichiers peuvent contenir "version https://git-lfs.github.com/spec/v1 (...)" au lieu de leur contenu attendu.
Ce sont des fichiers avec une taille importante qu'il est possible de télécharger indépendamment via ce lien : <https://filesender.renater.fr/?s=download&token=8d8e2295-256a-44cc-b4a3-17b4f73a5185>

<https://github.com/Anomaaaa/PresDeChezVous>
