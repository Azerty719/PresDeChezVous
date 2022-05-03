# Près de chez vous

"Près de chez vous" est un site web qui permet de connaître tous les équipements (commerce, services, santé...) ou seulement certains (maternelle,salon de coiffure...) qui se trouvent autour d'un endroit donné en France.

Les paramètres de connexion au sgbd (mysql) se font via le fichier "Settings.txt".

Tous les fichiers du site sont contenues dans le dossier "templates". Le seul fichier php qui n'est pas issu du moteur de template est "index.php".

Tous les scripts sql sont contenus dans "Base de donnees/sql". "CreationTables" contient seulement les tables. "DATABASE_PresDeChezVous.sql" contient toute la base de données (y compris les tables), "DATABASE_PresDeChezVous" en est sa version compressée.

Le fichier "ScriptSQLToBDD" importe "DATABASE_PresDeChezVous.sql" lorsqu'il est executé. Il a l'avantage d'afficher l'avancement au fur et à mesure de l'importation et de s'affranchir de tout ce qui est problèmes de réglages d'importation, par exemple des limite de tailles de fichier ou des limites de temps d'importation.

Le dossier "csv" et le fichier "ScriptToSQL" sont inutiles. Ils ont seulement servi à la première création de la base de données.

<https://github.com/Anomaaaa/PresDeChezVous>
