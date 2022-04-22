#Ce script sert à récupérer les données csv pour les mettre dans la BD sql. On n'en aura plus besoin une fois tout transformé
from re import I
import pandas as pd
from math import isnan
import pyproj

#------------------------------------------------------------------------------------------------------
tailleMorceau = 1000 #! Ne pas descendre en dessous de (même 1000 pour les performances)

#Lecture et mise en forme fichier csv sous forme de liste
def LectureFichier(fichier,separateur):
    print(fichier+ '\n \n Chargement... \n')
    #Pour lire gros fichiers : on le divise en tables de max 50 000 lignes pour ne pas saturer la mémoire
    tables = pd.read_csv(fichier,sep=separateur,chunksize=tailleMorceau, encoding='utf8')
    Resultat = []
    nombreTables = len(list(pd.read_csv(fichier,sep=separateur,chunksize=tailleMorceau, encoding='utf8'))) #ça casse tout d'utiliser la variable table
    for Avancement,table in enumerate(tables):
        print('Lecture',fichier,Avancement+1,'/',nombreTables,'(',round((Avancement+1)/nombreTables*100,1),'% )')
        #Supprime les \n inutiles + caractères problématiques (' pour sql, 2A 2B pour corse)
        Resultat.append(table.replace('\n','',regex=True).replace("'",'_',regex=True).replace('2A','210',regex=True).replace('2B','211',regex=True))         
    return Resultat,nombreTables

#Avoir les paramètre de chaque table pour des ajouts
def EcritureSQLLigne(table,attributs): #Les attributs sont sous forme de liste
    resultat = 'INSERT INTO ' + table + ' ('
    for attribut in attributs:
        resultat += attribut+','
    resultat = resultat[:-1] + ') \n VALUES \n'
    return resultat

#------------------------------------------------------------------------------------------------------

def Categorie(fichierCategorie,sep):
    #Ecrit les parametres pour chaque table
    ResultCat = EcritureSQLLigne('Categorie',['LibCategorie'])
    ResultSCat = EcritureSQLLigne('SousCategorie',['LibSousCategorie','IdCategorie'])
    ResultType = EcritureSQLLigne('Type',['LibType','IdSousCategorie','CodeType'])
    ListDejaFait = []   #On met dans cette liste toutes les catégories déjà faites pour ne pas avoir de doublons (avec des not in cette liste)
    ListDejaFaitS = []
    
    #Initialise le fichier 
    fichiersql = open(r'Base de donnees\sql\Categorie.sql','w')
    fichiersql.close()
        
    #Ecrit le fichier
    tables = LectureFichier(fichierCategorie,sep)
    for table in tables[0] :
        for ligne in table.values:
            if ligne[-1] not in ListDejaFait :
                ListDejaFait.append(ligne[-1])
                ResultCat += "\t( \'" + ligne[-1] + "\' ), \n" #On prend la dernière colonne de chaque ligne qui correspond à la catégorie

            if ligne[3] not in ListDejaFaitS :
                ListDejaFaitS.append(ligne[3])
                ResultSCat += "\t( \'" + ligne[3] + "\' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie=\'" +ligne[-1]+"\') ), \n"
                    #3ème colonne = SousCategorie et on prend le même identifiant qui vient d'être donné avec l'auto_increment pour jointure
            ResultType += "\t( \'" + ligne[1] + "\' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie=\'" +ligne[3]+ "\')" + " , \'" + ligne[0] +"\' ), \n"

        with open(r'Base de donnees\sql\Categorie.sql','w', encoding='utf8') as fichiersql:
            fichiersql.write(ResultCat[:-3] + '; \n\n' + ResultSCat[:-3] + ';\n\n' + ResultType[:-3] + ';\n\n')

#Categorie(r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\BPE20_table_passage.csv',';')
#------------------------------------------------------------------------------------------------------

def CommuneDepRegion(fichierRegion,fichierDep,fichierCommune,sep):
    ResultRegion = EcritureSQLLigne('Region',['CodeRegion','LibRegion'])
    ResultDep = EcritureSQLLigne('Departement',['CodeDepartement','LibDepartement','CodeRegion'])
    ResultCommune = EcritureSQLLigne('Commune',['CodeCommune','LibCommune','CodeDepartement'])
    sep = ','
    tablesRegion = LectureFichier(fichierRegion,sep)
    tablesDep = LectureFichier(fichierDep,sep)
    tablesCommune = LectureFichier(fichierCommune,sep)
    nombreTablesCommune = tablesCommune[1]
    
    #*Ecrit Region et Departement + base commune
    for tableRegion in tablesRegion[0]:
        for ligne in tableRegion.values:
            ResultRegion += "\t( " + str(ligne[0]) +" , '"+ligne[-1]+"' ), \n" #Mise en forme ligne
    for tableDep in tablesDep[0]:
        for ligne in tableDep.values:
            ResultDep += "\t( " + str(int(ligne[0])) + " , '"+ligne[-1]+"' , "+str(ligne[1]) + ' ), \n' #Mise en forme ligne
    with open(r'Base de donnees\sql\CommuneDepRegion.sql','w',encoding='utf8') as fichiersql: #Ecriture
            fichiersql.write(ResultRegion[:-3] + ';\n\n' + ResultDep[:-3] + ';\n\n' + ResultCommune[:-3]) 
    
    #*Ecrit Commune par bout de n lignes
    av = 0      
    for numeroTable,tableCommune in enumerate(tablesCommune[0]):
        ResultCommune = '' #Initialise le resultat de Commune
        for ligne in tableCommune.values:
            av += 1
            print('Ecriture Commune :',av,'=>',round(av/37601*100,1),'%' ) #Affiche l'avancement dans la console
            if isnan(ligne[-1]):      #Si valeure non nulle alors c'est une ancienne ville qui a fusionné => même clé primaire que la commune fusion donc on enlève
                ResultCommune += "\t( " + str(ligne[1]) + " , '"+ligne[-3] +"' , " + str(int(ligne[3])) + ' ), \n'
        with open(r'Base de donnees\sql\CommuneDepRegion.sql','a',encoding='utf8') as fichiersql:
            if numeroTable+1 == nombreTablesCommune: #Pour dernière table => on ferme la requête 
                fichiersql.write(ResultCommune[:-3] + ';\n\n')
            else:
                fichiersql.write(ResultCommune) #Ecriture bloc 
        print('Ecriture Commune :',av,'=> 100 %' )

CommuneDepRegion(r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\region_2022.csv'
                 ,r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\departement_2022.csv'
                 ,r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\commune_2022.csv'
                 , ',')

#------------------------------------------------------------------------------------------------------

#Les departements d'outre-mer avec leurs zone de 
epsgTableOutreMer = {971:'epsg:5490' , 972:'epsg:5490' , 973:'epsg:3972' , 974:'epsg:2975' , 976:'epsg:5879'} 

#Supprimer des colonnes récurrentes qui ne nous servent pas
def SuppColonnes(df):
    if 'LABEL' in df:
        return df.drop(columns=['AAV2020','AN','BV2012','DCIRIS','DEP','EPCI','REG','UU2020','LABEL'])
    else:
        return df.drop(columns=['AAV2020','AN','BV2012','DCIRIS','DEP','EPCI','REG','UU2020'])


def Equipement(fichierEnsemble,fichierEnseignement,fichierSportLoisir,sep):
     
    #Ecriture base pour sql
    BaseCoo = EcritureSQLLigne('Coordonnees',['LatitudeGPS','longitudeGPS','UTMX','UTMY','QualiteXY'])      
    BaseEqu = EcritureSQLLigne('Equipement',['IdEquipement','Cantine','MaternellePrimaire','LyceeCPGE','EducPrio','Internat','RPIC','Secteur','Couvert',
                                            'Eclaire','NbAireJeu','NbSalles',
                                            'IdType','CodeCommune','IdLocalisation'])

    #Les variables en sortie sont des listes de tableaux    
    # tablesEnseignement = LectureFichier(fichierEnseignement)
    # tablesSportLoisir = LectureFichier(fichierSportLoisir)
    tablesEnsemble = LectureFichier(fichierEnsemble,sep)
    # nombreTablesEnseignement = tablesEnseignement[1]
    # nombreTablesSportLoisir = tablesSportLoisir[1] 
    nombreTablesEnsemble = tablesEnsemble[1]
    
    with open(r'Base de donnees\sql\Equipement.sql','w') as fichiersql : #En 'w' pour réinitialiser le fichier
        fichiersql.write(BaseCoo)
    
    #Ecriture Table Coordonnees
    av = 0
    total = 2706354
    for numeroTable,table in enumerate(tablesEnsemble[0]):
        ResultCoo = '' #Initialise le résultat
        table = SuppColonnes(table).drop(columns=['TYPEQU']) #Il reste les colonnes DEPCOM ; LAMBERT_X ; LAMBERT_Y ; QUALITE_XY
        for ligne in table.values:
            av += 1
            print('Ecriture Coordonnees :',av,'=>',round(av/2706354*100,3),'%' ) #Affiche l'avancement dans la console
            if not isnan(ligne[1]): #On ne prend pas les equipements non géolocalisé
                if str(ligne[0])[:3] in list(epsgTableOutreMer.keys()): #Si un departement d'Outre-mer
                    epsg = epsgTableOutreMer[str(ligne[0])[:3]]
                    transformer = pyproj.Transformer.from_crs(epsg, "+proj=lonlat")
                else:
                    epsg = transformer = pyproj.Transformer.from_crs('epsg:2154' , "+proj=lonlat") #France métropolitaine
                utmx = ligne[1]
                utmy = ligne[2]
                lonlat = transformer.transform(utmx,utmy) #variable tuple (longitude,latitude)
                ResultCoo += "\t( " + str(lonlat[1]) + ' , ' + str(lonlat[0]) + ' , ' + str(utmx) + ' , ' + str(utmy) + " , '" + ligne[-1] + "' ), \n"
                #                     latitudegps        longitudegps         utmx           utmy            qualite_XY
        with open(r'Base de donnees\sql\Equipement.sql','a') as fichiersql:
            if numeroTable+1 == nombreTablesEnsemble: #Pour dernière table => on ferme la requête 
                fichiersql.write(ResultCoo[-3] + ';\n\n')
            else:
                fichiersql.write(ResultCoo) #Ecriture bloc 50 000 lignes 
        
        
        
#     for table in tablesEnsemble:
#         table = SuppColonnes(table).drop['LAMBERT_X','LAMBERT_Y','QUALITE_XY'] #Il reste les colonnes DEPCOM ; LAMBERT_X ; LAMBERT_Y ; QUALITE_XY ; TYPEQU
#         for ligne in table.values:
#             if 'C' not in ligne[-1] and 'F' not in ligne[-1]:
#                 Result = "\t( "+ 'NULL , '*12 + " (SELECT IdType FROM Type WHERE CodeType='" + ligne[-1] + "' , " + ligne[0] 
# #ResultSCat += "\t( \'" + ligne[3] + "\' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie=\'" +ligne[-1]+"\') ),\n"

#     for table in tablesSportLoisir:
#         table = SuppColonnes(table)
#         for ligne in table.values:
#             ()
    
#     for table in tablesEnseignement:
#         table = SuppColonnes(table)
#     for ligne in table.values:
#         ()

#Equipement(r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\bpe20_ensemble_xy.csv','a','a',';')
