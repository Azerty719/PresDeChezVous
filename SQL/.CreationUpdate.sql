CREATE DATABASE BDpdcv;
USE BDpdcv;

#!   CREATION TABLE
#------------------------------------------------------------
# Table: Coordonnees
#------------------------------------------------------------

CREATE TABLE Coordonnees(
        IdLocalisation Int  Auto_increment  NOT NULL ,
        Latitude       Float NOT NULL ,
        Longitude      Float NOT NULL ,
        UTMX           Float NOT NULL ,
        UTMY           Float NOT NULL ,
        QualiteXY      Int NOT NULL
	,CONSTRAINT Coordonnees_PK PRIMARY KEY (IdLocalisation)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Adresse
#------------------------------------------------------------

CREATE TABLE Adresse(
        idAdresse      Int  Auto_increment  NOT NULL ,
        LibAdresse     Varchar (256) NOT NULL ,
        IdLocalisation Int NOT NULL
	,CONSTRAINT Adresse_PK PRIMARY KEY (idAdresse)

	,CONSTRAINT Adresse_Coordonnees_FK FOREIGN KEY (IdLocalisation) REFERENCES Coordonnees(IdLocalisation)
	,CONSTRAINT Adresse_Coordonnees_AK UNIQUE (IdLocalisation)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Region
#------------------------------------------------------------

CREATE TABLE Region(
        CodeRegion Int NOT NULL ,
        LibRegion  Varchar (32) NOT NULL
	,CONSTRAINT Region_PK PRIMARY KEY (CodeRegion)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Departement
#------------------------------------------------------------

CREATE TABLE Departement(
        CodeDepartement Int NOT NULL ,
        LibDepartement  Varchar (32) NOT NULL ,
        CodeRegion      Int NOT NULL
	,CONSTRAINT Departement_PK PRIMARY KEY (CodeDepartement)

	,CONSTRAINT Departement_Region_FK FOREIGN KEY (CodeRegion) REFERENCES Region(CodeRegion)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Commune
#------------------------------------------------------------

CREATE TABLE Commune(
        CodeCommune     Int NOT NULL ,
        LibCommune      Varchar (32) NOT NULL ,
        CodeDepartement Int NOT NULL
	,CONSTRAINT Commune_PK PRIMARY KEY (CodeCommune)

	,CONSTRAINT Commune_Departement_FK FOREIGN KEY (CodeDepartement) REFERENCES Departement(CodeDepartement)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Table: Categorie
#------------------------------------------------------------

CREATE TABLE Categorie(
        IdCategorie  Int  Auto_increment  NOT NULL ,
        LibCategorie Varchar (256) NOT NULL
	,CONSTRAINT Categorie_PK PRIMARY KEY (IdCategorie)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: SousCategorie
#------------------------------------------------------------

CREATE TABLE SousCategorie(
        IdSousCategorie Int  Auto_increment  NOT NULL ,
        LibSousCategorie    Varchar (256) NOT NULL ,
        IdCategorie     Int NOT NULL
	,CONSTRAINT SousCategorie_PK PRIMARY KEY (IdSousCategorie)

	,CONSTRAINT SousCategorie_Categorie_FK FOREIGN KEY (IdCategorie) REFERENCES Categorie(IdCategorie)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Type
#------------------------------------------------------------

CREATE TABLE Type(
        IdType          Int  Auto_increment  NOT NULL ,
        LibType       Varchar (256) NOT NULL ,
        IdSousCategorie Int NOT NULL
	,CONSTRAINT Type_PK PRIMARY KEY (IdType)

	,CONSTRAINT Type_SousCategorie_FK FOREIGN KEY (IdSousCategorie) REFERENCES SousCategorie(IdSousCategorie)
)ENGINE=InnoDB;



#------------------------------------------------------------
# Table: Utilisateur
#------------------------------------------------------------

CREATE TABLE Utilisateur(
        IdUtilisateur Int  Auto_increment  NOT NULL ,
        MDP           Varchar (32) NOT NULL ,
        Mail          Varchar (256) NOT NULL ,
        Nom           Varchar (32) NOT NULL
	,CONSTRAINT Utilisateur_PK PRIMARY KEY (IdUtilisateur)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Contributeur
#------------------------------------------------------------

CREATE TABLE Contributeur(
        IdUtilisateur  Int NOT NULL ,
        IdContributeur Int NOT NULL ,
        MDP            Varchar (32) NOT NULL ,
        Mail           Varchar (256) NOT NULL ,
        Nom            Varchar (32) NOT NULL
	,CONSTRAINT Contributeur_PK PRIMARY KEY (IdUtilisateur,IdContributeur)

	,CONSTRAINT Contributeur_Utilisateur_FK FOREIGN KEY (IdUtilisateur) REFERENCES Utilisateur(IdUtilisateur)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Moderateur
#------------------------------------------------------------

CREATE TABLE Moderateur(
        IdUtilisateur Int NOT NULL ,
        IdModerateur  Int NOT NULL ,
        MDP           Varchar (32) NOT NULL ,
        Mail          Varchar (256) NOT NULL ,
        Nom           Varchar (32) NOT NULL
	,CONSTRAINT Moderateur_PK PRIMARY KEY (IdUtilisateur,IdModerateur)

	,CONSTRAINT Moderateur_Utilisateur_FK FOREIGN KEY (IdUtilisateur) REFERENCES Utilisateur(IdUtilisateur)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Equipement
#------------------------------------------------------------

CREATE TABLE Equipement(
        IdEquipement             Int  Auto_increment  NOT NULL ,
        Cantine                  Bool ,
        MaternellePrimaire       Bool ,
        LyceeCPGE                Bool ,
        EducPrio                 Bool ,
        Internat                 Bool ,
        RPIC                     Bool ,
        Secteur                  Varchar (6) ,
        Couvert                  Bool ,
        Eclaire                  Bool ,
        NbAireJeu                Int ,
        NbSalles                 Int ,
        IdUtilisateur            Int NOT NULL ,
        IdModerateur             Int NOT NULL ,
        IdUtilisateur_Moderateur Int ,
        IdModerateur_Supprimer   Int ,
        IdType                   Int NOT NULL ,
        CodeCommune              Int NOT NULL ,
        IdLocalisation           Int
	,CONSTRAINT Equipement_PK PRIMARY KEY (IdEquipement)

	,CONSTRAINT Equipement_Moderateur_FK FOREIGN KEY (IdUtilisateur,IdModerateur) REFERENCES Moderateur(IdUtilisateur,IdModerateur)
	,CONSTRAINT Equipement_Moderateur0_FK FOREIGN KEY (IdUtilisateur_Moderateur,IdModerateur_Supprimer) REFERENCES Moderateur(IdUtilisateur,IdModerateur)
	,CONSTRAINT Equipement_Type1_FK FOREIGN KEY (IdType) REFERENCES Type(IdType)
	,CONSTRAINT Equipement_Commune2_FK FOREIGN KEY (CodeCommune) REFERENCES Commune(CodeCommune)
	,CONSTRAINT Equipement_Coordonnees3_FK FOREIGN KEY (IdLocalisation) REFERENCES Coordonnees(IdLocalisation)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Proposition
#------------------------------------------------------------

CREATE TABLE Proposition(
        IdModification             Int  Auto_increment  NOT NULL ,
        DateProposition            Date NOT NULL ,
        TypeProposition            Varchar (32) NOT NULL ,
        LibProposition             Text ,
        DateValidation             Date NOT NULL ,
        IdUtilisateur              Int ,
        IdModerateur               Int ,
        IdUtilisateur_Contributeur Int NOT NULL ,
        IdContributeur             Int NOT NULL
	,CONSTRAINT Proposition_PK PRIMARY KEY (IdModification)

	,CONSTRAINT Proposition_Moderateur_FK FOREIGN KEY (IdUtilisateur,IdModerateur) REFERENCES Moderateur(IdUtilisateur,IdModerateur)
	,CONSTRAINT Proposition_Contributeur0_FK FOREIGN KEY (IdUtilisateur_Contributeur,IdContributeur) REFERENCES Contributeur(IdUtilisateur,IdContributeur)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Modifier
#------------------------------------------------------------

CREATE TABLE Modifier(
        IdEquipement  Int NOT NULL ,
        IdUtilisateur Int NOT NULL ,
        IdModerateur  Int NOT NULL ,
        TypeModif     Varchar (32) NOT NULL
	,CONSTRAINT Modifier_PK PRIMARY KEY (IdEquipement,IdUtilisateur,IdModerateur)

	,CONSTRAINT Modifier_Equipement_FK FOREIGN KEY (IdEquipement) REFERENCES Equipement(IdEquipement)
	,CONSTRAINT Modifier_Moderateur0_FK FOREIGN KEY (IdUtilisateur,IdModerateur) REFERENCES Moderateur(IdUtilisateur,IdModerateur)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Sanctionner
#------------------------------------------------------------

CREATE TABLE Sanctionner(
        IdUtilisateur            Int NOT NULL ,
        IdContributeur           Int NOT NULL ,
        IdUtilisateur_Moderateur Int NOT NULL ,
        IdModerateur             Int NOT NULL ,
        TypeSanction             Varchar (32) NOT NULL ,
        RaisonSanction           Text NOT NULL
	,CONSTRAINT Sanctionner_PK PRIMARY KEY (IdUtilisateur,IdContributeur,IdUtilisateur_Moderateur,IdModerateur)

	,CONSTRAINT Sanctionner_Contributeur_FK FOREIGN KEY (IdUtilisateur,IdContributeur) REFERENCES Contributeur(IdUtilisateur,IdContributeur)
	,CONSTRAINT Sanctionner_Moderateur0_FK FOREIGN KEY (IdUtilisateur_Moderateur,IdModerateur) REFERENCES Moderateur(IdUtilisateur,IdModerateur)
)ENGINE=InnoDB;


#! CREATION CATEGORIES

INSERT INTO Categorie (LibCategorie) 
 VALUES 
	( 'Services aux particuliers' ),
	( 'Commerces' ),
	( 'Enseignement' ),
	( 'Santé et action sociale' ),
	( 'Transports et déplacements' ),
	( 'Sports, loisirs et culture' ),
	( 'Tourisme' ); 

INSERT INTO SousCategorie (LibSousCategorie,IdCategorie) 
 VALUES 
	( 'Services publics' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Services aux particuliers') ),
	( 'Services généraux' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Services aux particuliers') ),
	( 'Services automobiles' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Services aux particuliers') ),
	( 'Artisanat du bâtiment' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Services aux particuliers') ),
	( 'Autres services à la population' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Services aux particuliers') ),
	( 'Grandes surfaces' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Commerces') ),
	( 'Commerces alimentaires' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Commerces') ),
	( 'Commerces spécialisés non alimentaires' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Commerces') ),
	( 'Enseignement du premier degré' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Enseignement') ),
	( 'Enseignement du second degré premier cycle' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Enseignement') ),
	( 'Enseignement du second degré second cycle' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Enseignement') ),
	( 'Enseignement supérieur non universitaire' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Enseignement') ),
	( 'Enseignement supérieur universitaire' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Enseignement') ),
	( 'Formation continue' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Enseignement') ),
	( 'Autres services de l_éducation' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Enseignement') ),
	( 'Etablissements et services de santé' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Santé et action sociale') ),
	( 'Fonctions médicales et para-médicales (à titre libéral)' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Santé et action sociale') ),
	( 'Autres établissements et services à caractère sanitaire' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Santé et action sociale') ),
	( 'Action sociale pour personnes âgées' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Santé et action sociale') ),
	( 'Action sociale pour enfants en bas-âge' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Santé et action sociale') ),
	( 'Action sociale pour handicapés' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Santé et action sociale') ),
	( 'Autres services d_action sociale' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Santé et action sociale') ),
	( 'Infrastructures de transports' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Transports et déplacements') ),
	( 'Equipements sportifs' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Sports, loisirs et culture') ),
	( 'Equipements de loisirs' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Sports, loisirs et culture') ),
	( 'Equipements culturels et socioculturels' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Sports, loisirs et culture') ),
	( 'Tourisme' , (SELECT IdCategorie FROM Categorie WHERE LibCategorie='Tourisme') );

INSERT INTO Type (LibType,IdSousCategorie) 
 VALUES 
	( 'Police' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Gendarmerie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Cour d_appel' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Tribunal de grande instance (TGI)' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Tribunal d_instance (TI)' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Conseil de prud_hommes (CPH)' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Tribunal de commerce (TCO)' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'DRFIP' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'DDFIP' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Réseau de proximité Pôle Emploi' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Réseau partenarial Pôle Emploi' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Maison de Justice et du Droit (MJD)' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Antenne de Justice (AJ)' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Conseil départemental d_accés au droit (CDAD)' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Maisons de services au public ou Implantations France Services' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services publics') ),
	( 'Banque Caisse d_épargne' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services généraux') ),
	( 'Services funéraires' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services généraux') ),
	( 'Bureau de poste' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services généraux') ),
	( 'Relais poste' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services généraux') ),
	( 'Agence postale' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services généraux') ),
	( 'Réparation auto-matériel agricole' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services automobiles') ),
	( 'Contrôle technique automobile' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services automobiles') ),
	( 'Location auto-utilitaires légers' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services automobiles') ),
	( 'Ecoles de conduite' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Services automobiles') ),
	( 'Maçon' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Artisanat du bâtiment') ),
	( 'Platrier peintre' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Artisanat du bâtiment') ),
	( 'Menuisier charpentier serrurier' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Artisanat du bâtiment') ),
	( 'Plombier couvreur chauffagiste' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Artisanat du bâtiment') ),
	( 'Electricien' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Artisanat du bâtiment') ),
	( 'Entreprise générale bâtiment' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Artisanat du bâtiment') ),
	( 'Coiffure' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services à la population') ),
	( 'Vétérinaire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services à la population') ),
	( 'Agence travail temporaire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services à la population') ),
	( 'Restaurant - Restauration rapide' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services à la population') ),
	( 'Agence immobilière' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services à la population') ),
	( 'Pressing-Laverie automatique' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services à la population') ),
	( 'Institut de beauté-Onglerie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services à la population') ),
	( 'Hypermarché' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Grandes surfaces') ),
	( 'Supermarché' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Grandes surfaces') ),
	( 'Grande surface bricolage' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Grandes surfaces') ),
	( 'Supérette' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces alimentaires') ),
	( 'Epicerie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces alimentaires') ),
	( 'Boulangerie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces alimentaires') ),
	( 'Boucherie charcuterie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces alimentaires') ),
	( 'Produits surgelés' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces alimentaires') ),
	( 'Poissonnerie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces alimentaires') ),
	( 'Librairie papeterie journaux' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Magasin vêtements' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Magasin équipements du foyer' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Magasin chaussures' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Magasin électroménager - matériel audio/video' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Magasin meubles' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Magasin articles de sports - loisirs' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Magasin revêtements murs et sols' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Droguerie quincaillerie bricolage' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Parfumerie-Cosmétique' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Horlogerie Bijouterie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Fleuriste-Jardinerie-Animalerie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Magasin d_optique' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Magasin de matériel médical et orthopédique' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Station service' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Commerces spécialisés non alimentaires') ),
	( 'Ecole maternelle' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du premier degré') ),
	( 'RPI dispersé maternelle' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du premier degré') ),
	( 'Ecole élémentaire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du premier degré') ),
	( 'RPI dispersé élémentaire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du premier degré') ),
	( 'Collège' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du second degré premier cycle') ),
	( 'Lycée enseignement général - technologique' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du second degré second cycle') ),
	( 'Lycée enseignement professionnel' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du second degré second cycle') ),
	( 'Lycée enseignement technologique / professionnel agricole' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du second degré second cycle') ),
	( 'SGT Section d_enseignement général et technologique' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du second degré second cycle') ),
	( 'SEP Section d_enseignement professionnel' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement du second degré second cycle') ),
	( 'STS CPGE' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur non universitaire') ),
	( 'Formation santé' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur non universitaire') ),
	( 'Formation Commerce' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur non universitaire') ),
	( 'Autre formation post bac non universitaire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur non universitaire') ),
	( 'UFR' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur universitaire') ),
	( 'Institut universitaire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur universitaire') ),
	( 'Ecole d_ingénieurs' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur universitaire') ),
	( 'Enseignement général supérieur privé' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur universitaire') ),
	( 'Ecole d_enseignement supérieur agricole' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur universitaire') ),
	( 'Autre enseignement supérieur' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Enseignement supérieur universitaire') ),
	( 'Centre formation d_apprentis (hors agriculture)' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Formation continue') ),
	( 'GRETA' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Formation continue') ),
	( 'Centre dispensant de la formation continue agricole' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Formation continue') ),
	( 'Formation métiers du sport' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Formation continue') ),
	( 'Centre dispensant des formations d_apprentissage agricole' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Formation continue') ),
	( 'Autre formation continue' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Formation continue') ),
	( 'Résidence universitaire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services de l_éducation') ),
	( 'Restaurant universitaire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services de l_éducation') ),
	( 'Etablissement santé court séjour' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Etablissement santé moyen séjour' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Etablissement santé long séjour' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Etablissement psychiatrique avec hébergement' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Centre lutte cancer' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Urgence' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Maternité' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Centre de santé' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Structure psychiatrique en ambulatoire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Centre médecine préventive' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Dialyse' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Hospitalisation à domicile' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Maison de santé pluridisciplinaire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Etablissements et services de santé') ),
	( 'Médecin généraliste' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Cardiologie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Dermatologie Vénéréologie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Gastro-entérologie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Psychiatrie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Ophtalmologie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Oto-rhino-laryngologie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Pédiatrie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Pneumologie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Radio diagnostic Imagerie médicale' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste Stomatologie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Spécialiste en gynécologie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Chirurgien dentiste' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Sage-femme' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Infirmier' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Masseur kinésithérapeute' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Orthophoniste' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Orthoptiste' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Pedicure-podologue' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Audio prothésiste' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Ergothérapeute' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Psychomotricien' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Manipulateur ERM' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Diététicien' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Psychologue' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Fonctions médicales et para-médicales (à titre libéral)') ),
	( 'Laboratoire d_analyses médicales' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres établissements et services à caractère sanitaire') ),
	( 'Ambulance' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres établissements et services à caractère sanitaire') ),
	( 'Transfusion sanguine' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres établissements et services à caractère sanitaire') ),
	( 'Etablissement thermal' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres établissements et services à caractère sanitaire') ),
	( 'Pharmacie' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres établissements et services à caractère sanitaire') ),
	( 'Personnes âgées - hébergement' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour personnes âgées') ),
	( 'Personnes âgées - soins à domicile' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour personnes âgées') ),
	( 'Personnes âgées - service d aide' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour personnes âgées') ),
	( 'Foyer restaurant' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour personnes âgées') ),
	( 'Crèche' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour enfants en bas-âge') ),
	( 'Enfants handicapés - hébergement' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour handicapés') ),
	( 'Enfants handicapés - services à domicile ou ambulatoire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour handicapés') ),
	( 'Adultes handicapés - accueil/hébergement' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour handicapés') ),
	( 'Adultes handicapés - services d_aide' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour handicapés') ),
	( 'Travail protégé' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour handicapés') ),
	( 'Adultes handicapés - services de soins à domicile' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Action sociale pour handicapés') ),
	( 'Aide sociale à l_enfance - hébergement' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services d_action sociale') ),
	( 'Aide sociale à l_enfance - action éducative' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services d_action sociale') ),
	( 'Centre d’hébergement et de réinsertion sociale' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services d_action sociale') ),
	( 'Centre provisoire d_hébergement' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services d_action sociale') ),
	( 'Centre accueil demandeur d_asile' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services d_action sociale') ),
	( 'Autre établissement pour adultes et familles en difficulté' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Autres services d_action sociale') ),
	( 'Taxi-VTC' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Infrastructures de transports') ),
	( 'Aéroport' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Infrastructures de transports') ),
	( 'Gare de voyageurs d_intérêt national' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Infrastructures de transports') ),
	( 'Gare de voyageurs d_intérêt régional' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Infrastructures de transports') ),
	( 'Gare de voyageurs d_intérêt local' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Infrastructures de transports') ),
	( 'Bassin de natation' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Boulodrome' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Tennis' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Equipement de cyclisme' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Domaine skiable' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Centre équestre' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Athlétisme' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Terrain de golf' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Parcours sportif/santé' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Sports de glace' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Plateaux et terrains de jeux extérieurs' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Salles spécialisées' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Terrains de grands jeux' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Salles de combat' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Salles non spécialisées' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Roller-Skate-Vélo bicross ou freestyle' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Sports nautiques' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Bowling' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Salles de remise en forme' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Salles multisports (gymnases)' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements sportifs') ),
	( 'Baignade aménagée' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements de loisirs') ),
	( 'Port de plaisance - Mouillage' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements de loisirs') ),
	( 'Boucle de randonnée' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements de loisirs') ),
	( 'Cinéma' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements culturels et socioculturels') ),
	( 'Conservatoire' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements culturels et socioculturels') ),
	( 'Théâtre-Arts de rue-Pôle cirque' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements culturels et socioculturels') ),
	( 'Bibliothèque' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements culturels et socioculturels') ),
	( 'Musique et danse' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements culturels et socioculturels') ),
	( 'Lieu d_exposition et patrimoine' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements culturels et socioculturels') ),
	( 'Jardin remarquable' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Equipements culturels et socioculturels') ),
	( 'Agence de voyages' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Tourisme') ),
	( 'Hôtel' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Tourisme') ),
	( 'Camping' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Tourisme') ),
	( 'Information touristique' , (SELECT IdSousCategorie FROM SousCategorie WHERE LibSousCategorie='Tourisme') );




