
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