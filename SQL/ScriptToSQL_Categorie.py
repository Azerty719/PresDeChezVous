## Ce script sert à récupérer les données csv pour les transformer en sql. On en aura plus besoin une fois tout transformé

#Lecture et mise en forme fichier csv
def LectureFichier(fichier,separateur):
    with open(fichier,'r') as fichiercsv:
        lignes = fichiercsv.readlines()
        ligneslist = []
        for ligne in lignes:
            ligneslist.append(ligne.replace('\n','').replace("'",'_').replace('2A','210').replace('2B','211').split(separateur))  
            #Supprime les \n inutiles + caractères problématiques (' pour sql, 2A 2B pour corse)
        ligneslist = ligneslist[1:] #Supprime la première ligne inutile
        # => On a grande liste (lignes) contient petites listes (colonnes)
    #for i in ligneslist:
        #print(i)
    return ligneslist
def EcritureSQLLigne(table,attributs): #Les attributs sont sous forme de liste
    resultat = 'INSERT INTO ' + table + ' ('
    for attribut in attributs:
        resultat += attribut+','
    resultat = resultat[:-1] + ') \n VALUES \n'
    return resultat


def EcritureCategorie():
    ResultCat = EcritureSQLLigne('Categorie',['LibCategorie'])
    ResultSCat = EcritureSQLLigne('SousCategorie',['LibSousCategorie','IdCategorie'])
    ResultType = EcritureSQLLigne('Type',['LibType','IdSousCategorie'])

    ListDejaFait = []   #On met dans cette liste toutes les catégories déjà faites pour ne pas avoir de doublons (avec des not in cette liste)
    ListDejaFaitS = []
    ligneslist = LectureFichier('SQL\BPE20_table_passage.csv',';')
    for ligne in ligneslist:
        if ligne[-1] not in ListDejaFait :
            ListDejaFait.append(ligne[-1])
            ResultCat += "\t( \'" + ligne[-1] + "\' ),\n" #On prend la dernière colonne de chaque ligne qui correspond à la catégorie

        if ligne[3] not in ListDejaFaitS :
            ListDejaFaitS.append(ligne[3])
            ResultSCat += "\t( \'" + ligne[3] + "\' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie=\'" +ligne[-1]+"\') ),\n"
                #3ème colonne = SousCategorie et on prend le même identifiant qui vient d'être donné avec l'auto_increment pour jointure

        ResultType += "\t( \'" + ligne[1] + "\' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie=\'" +ligne[3]+"\') ),\n"

    #Ecriture fichier sql
    with open('BPE20_table_passage.sql','w') as fichiersql:
        fichiersql.write(ResultCat[:-2] + '; \n\n' + ResultSCat[:-2] + ';\n\n' + ResultType[:-2] + ';\n\n')

#Règle le problème du code de la Corse qui contient des A et B 
def corse(str):
    if '2A' in str:
        return str.replace('2A','210')
    else:
        return str.replace('2B',211)

def Commune():
    ResultRegion = EcritureSQLLigne('Region',['CodeRegion','LibRegion'])
    ResultDep = EcritureSQLLigne('Departement',['CodeDepartement','LibDepartement','CodeRegion'])
    ResultCommune = EcritureSQLLigne('Commune',['CodeCommune','LibCommune','CodeDepartement'])
    sep = ','
    ligneslistRegion = LectureFichier(r'SQL\region_2022.csv',sep)                                       
    ligneslistDep = LectureFichier('SQL\departement_2022.csv',sep)
    ligneslistCommune = LectureFichier('SQL\commune_2022.csv',sep)
    
    for ligne in ligneslistRegion:
        ligne = corse(ligne)
        ResultRegion += "\t( " + str(ligne[0]) +" , '"+ligne[-1]+"' ), \n"
    for ligne in ligneslistDep:
        ligne = corse(ligne)
        ResultDep += "\t( " + str(ligne[0]) + " , '"+ligne[-1]+"' , "+str(ligne[1]) + ' ), \n'
    for ligne in ligneslistCommune:
        ligne = corse(ligne)
        if ligne[-1] == '':                         #Si pas égal alors c'est une ancienne ville qui a fusionné => même clé primaire que la commune fusion donc on enlève 
            ResultCommune += "\t( " + str(ligne[1]) + " , '"+ligne[-3] +"' , " + str(ligne[3]) + ' ), \n'
    with open('CommuneDepRegion.sql','w') as fichiersql:
        fichiersql.write(ResultRegion[:-2] + ';\n\n' + ResultDep[:-2] + ';\n\n' + ResultCommune[:-2] + ';\n\n')