""" 
Ce script permet d'importer un fichier .sql à mysql.
Il a l'avantage d'afficher l'avancement au fur à mesure de l'importation et 
de régler tout ce qui est limite de taille de fichier de temps d'importation
"""
from sqlalchemy import create_engine,text

USER = 'root'
PASSWORD = ''
HOST = 'localhost'
PORT = ''
DATABASE = 'bdpdcv'

if PORT != '':
    PORT = ':'+PORT
engine = 'mysql+pymysql://'+USER+'@'+HOST+PORT + '/'+DATABASE
sqlEngine = create_engine(engine,pool_recycle=3600)

def Avancement(x,nb):
    return round(x/nb*100,1)

def Importation(fichiersql):
    dbConection = sqlEngine.connect()           #Connexion sgbd
    fichiersqlr = open(fichiersql,'r')           #Ouverture fichier sql
    nbrow = sum(1 for row in open(fichiersql,'r')) #Nombre de lignes dans le .sql
    fichiersql = fichiersqlr.readlines()        #Liste de toutes les lignes .sql
    requete = ''                                #Initialisation requête
    Av = 0                                      #Initialisation de l'avancement
    for i,line in enumerate(fichiersql):        #Iteration de chaque ligne du fichier sql
        line = line.replace('\n','')            #Supprime les sauts de ligne
        if not line.startswith('--'):            #Supprime les commentaires
            requete += line                     #Ajoute la ligne à la requête
        if requete.endswith(';'):               #Si ; execute la requete
            dbConection.execute(text(requete))
            requete = ''                        #Remet à 0 la requete
        AvTemp = round((i+1)/nbrow*100,1) 
        if AvTemp != Av:        #Affiche l'avancement seulement tous les 0.01%
            Av = AvTemp
            print (Av,'%')
    
    fichiersqlr.close()                          #Deconnexion sgbd
    dbConection.close()                         #Fermeture fichier
    
    
# Importation(r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\sql\bdpdcv.sql')