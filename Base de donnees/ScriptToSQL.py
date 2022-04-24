#Ce script sert à récupérer les données csv pour les mettre dans le sgbd sql. On n'en aura plus besoin une fois tout transformé
#! NE PAS EXECUTER PLUSIEURS FOIS SUR LA MEME BDD

import pandas as pd
from math import isnan
import numpy as np
from sqlalchemy import create_engine
import pymysql
import pyproj

#------------------------------------------------------------------------------------------------------
#Paramètres de connexion du sgbd 
#(forcément mysql ici, sinon changer ligne 9 et ligne 24 'pymysql' et 'mysql' par le module et le sgbd approprié)

USER = 'root'
PASSWORD = ''
HOST = 'localhost'
PORT = ''
DATABASE = 'bdpdcv'

if PORT != '':
    PORT = ':'+PORT
engine = 'mysql+pymysql://'+USER+'@'+HOST+PORT + '/'+DATABASE
sqlEngine = create_engine(engine,pool_recycle=3600)

#Plus le chiffre est grand plus l'execution est rapide mais risque de surcharge de mémoire 
tailleMorceau = 60000 #!Pas prévu pour en dessous de 1000


#------------------------------------------------------------------------------------------------------

def Categorie(fichier):
    table = pd.read_csv(fichier,sep=';',encoding = 'utf8')
    table = table.rename(columns = {'TYPEQU':'CodeType','LIB_EQUIP':'LibType','SDOM':'IdSousCategorie','LIB_SDOM':'LibSousCategorie','DOM':'IdCategorie','LIB_DOM':'LibCategorie'})
    #print(table)
                        #On garde CodeType et IdType (str et int)
    table['IdType'] = table['CodeType'].apply(lambda x: int(x,32))                    #Transforme l'Id str en int (base 32 à 10)            
    table['IdSousCategorie'] = table['IdSousCategorie'].apply(lambda x: int(x,32))
    table['IdCategorie'] = table['IdCategorie'].apply(lambda x: int(x,32))

    tableCat = table.reindex(columns=['IdCategorie','LibCategorie']) #Bonne colonnes
    tableCat = tableCat.drop_duplicates(subset=['IdCategorie']) #Supprime lignes identiques
    tableSousCat = table.reindex(columns=['IdSousCategorie','LibSousCategorie','IdCategorie'])
    tableSousCat = tableSousCat.drop_duplicates(subset=['IdSousCategorie'])
    tableType = table.reindex(columns=['IdType','LibType','IdSousCategorie','CodeType'])
    print(tableCat,'\n\n',tableSousCat,'\n\n',tableType)
    
    dbConnection  = sqlEngine.connect() #Ouvre la connexion au sgbd
    tableCat.to_sql('categorie', dbConnection, if_exists='append',index=False)
    tableSousCat.to_sql('souscategorie', dbConnection, if_exists='append',index=False)
    tableType.to_sql('type', dbConnection, if_exists='append',index=False)
    dbConnection.close() #Ferme la connexion au sgbd
    
#------------------------------------------------------------------------------------------------------

def CommuneDepRegion(fichierRegion,fichierDep,fichierCommune):
    
    print(fichierCommune + '\n \n Chargement... \n')
    
    tableRegion = pd.read_csv(fichierRegion,sep=',',encoding = 'utf8') 
    tableRegion = tableRegion.rename(columns={'REG':'CodeRegion','LIBELLE':'LibRegion'}) 
    tableRegion = tableRegion.reindex(columns=['CodeRegion','LibRegion']) #On a les colonnes : CodeRegion ; LibRegion
    print(tableRegion)
    
    tableDep = pd.read_csv(fichierDep,sep=',',encoding = 'utf8') 
    tableDep = tableDep.rename(columns={'REG':'CodeRegion','LIBELLE':'LibDepartement','DEP':'CodeDepartement'}) 
    tableDep = tableDep.reindex(columns=['CodeDepartement','LibDepartement','CodeRegion']) #On a les colonnes : CodeRegion ; LibRegion
    tableDep['CodeDepartement'] = tableDep['CodeDepartement'].replace('2A','210').replace('2B','211') #Corse dep en int 
    print(tableDep)
    
    dbConnection  = sqlEngine.connect() #Ouvre la connexion au sgbd
    
    #Exporte les 2 tables dans le sgbd
    tableRegion.to_sql('region', dbConnection, if_exists='append',index=False)
    tableDep.to_sql('departement', dbConnection, if_exists='append',index=False)
    
    tablesCommune = pd.read_csv(fichierCommune,sep=',',encoding = 'utf8' , chunksize=tailleMorceau)
    for tableCommune in tablesCommune:
        tableCommune = tableCommune.query("TYPECOM != 'COMD' and TYPECOM != 'COMA'") #Supprime les anciennes communes qui ont fusionné
        tableCommune = tableCommune.rename(columns={'COM':'CodeCommune','DEP':'CodeDepartement','LIBELLE':'LibCommune'})
        tableCommune = tableCommune.reindex(columns=['CodeCommune','LibCommune','CodeDepartement']) #Supprime colonnes inutiles
        tableCommune = tableCommune.replace('2A','210',regex=True).replace('2B','211',regex=True) #Corse dep en int 
        print(tableCommune)
        tableCommune.to_sql('commune', dbConnection, if_exists='append',index=False) #Exporte dans le sgbd

    dbConnection.close() #Ferme la connexion au sgbd

#------------------------------------------------------------------------------------------------------

def Converter(coIn,coOut,x,y):
    transformer = pyproj.Transformer.from_crs(coIn, coOut)
    return transformer.transform(x,y)

def ConverterLonLat(epsg,x,y):
    return Converter('epsg:'+str(epsg),"+proj=lonlat",x,y)  #Renvoie le tuple (longitude,latitude)

def Equipement(fichier,separateur):
    print(fichier+ '\n \n Chargement... \n')
    #Pour lire gros fichiers : on le divise en tables de max n lignes pour ne pas saturer la mémoire
    tables = pd.read_csv(fichier,sep=separateur, chunksize=tailleMorceau, encoding='utf8')
    avancement = pd.read_csv(fichier,sep=separateur, chunksize=tailleMorceau, encoding='utf8') #Pour voir l'avancement dans la console
    nombreTables = len(list(avancement))
    print('Lecture',fichier)

    dbConnection  = sqlEngine.connect() #Ouvre la connexion au sgbd

    for Avancement,table in enumerate(tables):
        print(round((Avancement+1)/nombreTables*100,1),'%') #Affiche l'avancement dans la console à chaque passage de boucle
        table = table.dropna(subset=['LAMBERT_X','LAMBERT_Y'])  #Supprime les equipements non géolocalisés <=>  valeur nulle dans X ou Y
        table = table.rename(columns={'LAMBERT_X':'UTMX' , 'LAMBERT_Y':'UTMY' , 'QUALITE_XY':'QualiteXY'})          #Renomme les colonnes comme elles sont dans la BDD
        table = table.reindex(columns=['DEPCOM','UTMX','UTMY','QualiteXY']) #Il reste les colonnes DEPCOM ; LAMBERT_X ; LAMBERT_Y ; QUALITE_XY
        table['DEPCOM'] = table['DEPCOM'].replace('2A','210',regex=True).replace('2B','211',regex=True).astype(int) #Corse dep en int

    #Creation nouvelles colonnes longitude et latitude
        table['latitudegps'] = np.where(table['DEPCOM'].astype(str).str[:3] == '971', ConverterLonLat(5490,table.UTMX,table.UTMY)[0],  #Guadeloupe
                                np.where(table['DEPCOM'].astype(str).str[:3] == '972', ConverterLonLat(5490,table.UTMX,table.UTMY)[0],  #Martinique
                                np.where(table['DEPCOM'].astype(str).str[:3] == '973', ConverterLonLat(2972,table.UTMX,table.UTMY)[0],  #Guyane
                                np.where(table['DEPCOM'].astype(str).str[:3] == '974', ConverterLonLat(2975,table.UTMX,table.UTMY)[0],  #La Réunion
                                np.where(table['DEPCOM'].astype(str).str[:3] == '976', ConverterLonLat(5879,table.UTMX,table.UTMY)[0],  #Mayotte
                                                ConverterLonLat(2154,table.UTMX,table.UTMY)[0]))))) #France métropolitaine

        table['longitudegps'] = np.where(table['DEPCOM'].astype(str).str[:3] == '971', ConverterLonLat(5490,table.UTMX,table.UTMY)[1],  #Guadeloupe
                                np.where(table['DEPCOM'].astype(str).str[:3] == '972', ConverterLonLat(5490,table.UTMX,table.UTMY)[1],  #Martinique
                                np.where(table['DEPCOM'].astype(str).str[:3] == '973', ConverterLonLat(2972,table.UTMX,table.UTMY)[1],  #Guyane
                                np.where(table['DEPCOM'].astype(str).str[:3] == '974', ConverterLonLat(2975,table.UTMX,table.UTMY)[1],  #La Réunion
                                np.where(table['DEPCOM'].astype(str).str[:3] == '976', ConverterLonLat(5879,table.UTMX,table.UTMY)[1],  #Mayotte
                                                ConverterLonLat(2154,table.UTMX,table.UTMY)[1]))))) #France métropolitaine

        table = table.reindex(columns=['latitudegps','longitudegps','utmx','utmy','qualitexy'])
        print(table)
        table.to_sql('coordonnees', dbConnection, if_exists='append',index=False)
    dbConnection.close() #Ferme la connexion au sgbd

#------------------------------------------------------------------------------------------------------

Categorie(r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\BPE20_table_passage.csv')

CommuneDepRegion(r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\region_2022.csv'
                 ,r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\departement_2022.csv'
                 ,r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\commune_2022.csv')
#Equipement(r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\bpe20_ensemble_xy.csv','a','a',';')
