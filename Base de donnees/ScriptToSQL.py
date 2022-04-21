#Ce script sert à récupérer les données csv pour les mettre dans la BD sql. On n'en aura plus besoin une fois tout transformé
import pandas as pd
from math import isnan

#Lecture et mise en forme fichier csv sous forme de liste
def LectureFichier(fichier,separateur):
    #Pour lire gros fichiers : on le divise en tables de max 50 000 lignes pour ne pas saturer la mémoire
    tables = pd.read_csv(fichier,sep=separateur,chunksize=50000, encoding='utf8')
    Resultat = []
    Avancement = 1
    for table in tables:
        print(Avancement)
        Avancement += 1
        #Supprime les \n inutiles + caractères problématiques (' pour sql, 2A 2B pour corse)
        Resultat.append(table.replace('\n','',regex=True).replace("'",'_',regex=True).replace('2A','210',regex=True).replace('2B','211',regex=True))         
    return Resultat

#Avoir les paramètre de chaque table pour des ajouts
def EcritureSQLLigne(table,attributs): #Les attributs sont sous forme de liste
    resultat = 'INSERT INTO ' + table + ' ('
    for attribut in attributs:
        resultat += attribut+','
    resultat = resultat[:-1] + ') \n VALUES \n'
    return resultat


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
    for table in tables :
        for ligne in table.values:
            if ligne[-1] not in ListDejaFait :
                ListDejaFait.append(ligne[-1])
                ResultCat += "\t( \'" + ligne[-1] + "\' ),\n" #On prend la dernière colonne de chaque ligne qui correspond à la catégorie

            if ligne[3] not in ListDejaFaitS :
                ListDejaFaitS.append(ligne[3])
                ResultSCat += "\t( \'" + ligne[3] + "\' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie=\'" +ligne[-1]+"\') ),\n"
                    #3ème colonne = SousCategorie et on prend le même identifiant qui vient d'être donné avec l'auto_increment pour jointure
            ResultType += "\t( \'" + ligne[1] + "\' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie=\'" +ligne[3]+ "\')" + " , \'" + ligne[0] +"\' ),\n"

        with open(r'Base de donnees\sql\Categorie.sql','w', encoding='utf8') as fichiersql:
            fichiersql.write(ResultCat[:-2] + '; \n\n' + ResultSCat[:-2] + ';\n\n' + ResultType[:-2] + ';\n\n')


def CommuneDepRegion(fichierRegion,fichierDep,fichierCommune,sep):
    ResultRegion = EcritureSQLLigne('Region',['CodeRegion','LibRegion'])
    ResultDep = EcritureSQLLigne('Departement',['CodeDepartement','LibDepartement','CodeRegion'])
    ResultCommune = EcritureSQLLigne('Commune',['CodeCommune','LibCommune','CodeDepartement'])
    sep = ','
    tablesRegion = LectureFichier(fichierRegion,sep)
    tablesDep = LectureFichier(fichierDep,sep)
    tablesCommune = LectureFichier(fichierCommune,sep)

    
    #*Ecrit Region et Departement + base commune
    for tableRegion in tablesRegion:
        for ligne in tableRegion.values:
            ResultRegion += "\t( " + str(ligne[0]) +" , '"+ligne[-1]+"' ), \n" #Mise en forme ligne
    for tableDep in tablesDep:
        for ligne in tableDep.values:
            ResultDep += "\t( " + str(ligne[0]) + " , '"+ligne[-1]+"' , "+str(ligne[1]) + ' ), \n' #Mise en forme ligne
    with open(r'Base de donnees\sql\CommuneDepRegion.sql','w',encoding='utf8') as fichiersql: #Ecriture
            fichiersql.write(ResultRegion[:-3] + ';\n\n' + ResultDep[:-3] + ';\n\n' + ResultCommune[:-3]) 
    
    #*Ecrit Commune par bout de 50 000 lignes      
    for tableCommune in tablesCommune:
        ResultCommune = '' #Initialise le resultat de Commune
        for ligne in tableCommune.values:
            if isnan(ligne[-1]):      #Si valeure non nulle alors c'est une ancienne ville qui a fusionné => même clé primaire que la commune fusion donc on enlève
                ResultCommune += "\t( " + str(ligne[1]) + " , '"+ligne[-3] +"' , " + str(ligne[3]) + ' ), \n'
        with open(r'Base de donnees\sql\CommuneDepRegion.sql','a',encoding='utf8') as fichiersql:
            fichiersql.write(ResultCommune) #Ecriture bloc 50 000 lignes
    with open(r'Base de donnees\sql\CommuneDepRegion.sql','a') as fichiersql:    
        fichiersql.write(';\n\n') #Ecriture petit bout fin

# CommuneDepRegion(r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\region_2022.csv'
#                  ,r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\departement_2022.csv'
#                  ,r'C:\Users\utilisateur\Desktop\Cours\Projet Info\Github\Base de donnees\csv\commune_2022.csv'
#                  , ',')