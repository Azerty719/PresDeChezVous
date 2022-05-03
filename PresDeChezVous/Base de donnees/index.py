#Ce script permet de récupérer les valeurs de .Database_connection sous forme de dictionnaire
import os

def AbsolutePath(FileName):
    absolutepath = os.path.abspath(__file__)
    fileDirectory = os.path.dirname(absolutepath)
    parentDirectory = os.path.dirname(fileDirectory) #On a le chemin jusqu'au dossier du projet
    for root, dirs, files in os.walk(parentDirectory):
        for name in files:
            if name == FileName:
                return (os.path.abspath(os.path.join(root, name)))
    

with open(AbsolutePath('Settings.txt'),encoding='utf8') as fichSett:
    Sett = dict()
    for line in fichSett:
        if ':' in line:
            line = line.replace('\n','').replace(' ','')
            sett = line.split(':')
            Sett[sett[0]] = sett[1]

print(Sett) #Print pour que le php le lise

def ConnectionRootMysql():
    HOST = Sett['HOST']
    PORT = Sett['PORT']
    PASSWORD = Sett['PASSWORD_ROOT']
    USER = Sett['ROOT']
    DATABASE = Sett['DATABASE']

    if PASSWORD != '':
        PASSWORD = ':'+PASSWORD
    if PORT != '':
        PORT = ':'+PORT
    return 'mysql+pymysql://'+USER+PASSWORD+'@'+HOST+PORT + '/'+DATABASE