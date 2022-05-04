"""
Ce script permet d'importer un fichier .sql à mysql.
Il a l'avantage d'afficher l'avancement au fur à mesure de l'importation et
de régler tout ce qui est limite de taille de fichier de temps d'importation
"""
from sqlalchemy import create_engine, text
from sqlalchemy.engine.url import URL
from index import AbsolutePath,ConnectionRootMysql

#Importation des paramètres de connexion du sgbd (forcément mysql ici, sinon changer ligne 30 'mysql' par le sgbd approprié)
engine = ConnectionRootMysql()
sqlEngine = create_engine(engine,pool_recycle=3600)

def Avancement(x,nb):
    return round(x/nb*100,1)

def Importation(fichiersql):
    fichiersql = AbsolutePath(fichiersql)
    print('\n Chargement... \n')
    Funct = False #Initialise booléan si on est dans un bloc avec delimiter
    dbConection = sqlEngine.connect()           #Connexion sgbd
    fichiersqlr = open(fichiersql,'r',encoding='utf8')           #Ouverture fichier sql
    nbrow = sum(1 for row in open(fichiersql,'r')) #Nombre de lignes dans le .sql
    fichiersql = fichiersqlr.readlines()        #Liste de toutes les lignes .sql
    requete = ''                                #Initialisation requête
    Av = 0                                      #Initialisation de l'avancement
    for i,line in enumerate(fichiersql):        #Iteration de chaque ligne du fichier sql
        line = line.replace('\n','')            #Supprime les sauts de ligne
        if not line.startswith('--'):           #Supprime les commentaires
            requete += line                     #Ajoute la ligne à la requête
        if 'DELIMITER' in line: #On entre ou sort d'un bloc avec delimiter
            Funct = not Funct   #change valeur du booléen
            if not Funct:
                requete = requete.replace('DELIMITER ;','').replace('DELIMITER','').replace('$$',';') #Supprime delimiters
                requete = requete.split(';',2)[1:] #Liste des requetes sans delimiteur (en enlevant le premier qui est requete vide)
                for j in requete:
                    dbConection.execute(text(j)) #Execute chaque requete de la liste
                requete = ''                     #Init requete

        if requete.endswith(';') and not Funct:  #Si ; et pas un bloc delimiter execute la requete
            dbConection.execute(text(requete))
            requete = ''                         #Init requete

        AvTemp = round((i)/nbrow*100,1)
        if AvTemp != Av:        #Affiche l'avancement seulement tous les 0.01%
            Av = AvTemp
            if Av == 100:
                print('Ne pas quitter, la toute fin est assez longue... (quelques minutes)')
            else:
                print(Av,'%')
    print('100 %')

    fichiersqlr.close()   #Deconnexion sgbd
    dbConection.close()   #Fermeture fichier


Importation('DATABASE_PresDeChezVous.sql')