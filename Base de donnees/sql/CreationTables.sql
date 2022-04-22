DROP DATABASE if EXISTS BDpdcv;
CREATE DATABASE BDpdcv;
USE BDpdcv;

#------------------------------------------------------------
# Table: Coordonnees
#------------------------------------------------------------

CREATE TABLE Coordonnees(
        IdLocalisation Int  Auto_increment  NOT NULL ,
        LatitudeGPS       Float NOT NULL ,
        LongitudeGPS      Float NOT NULL ,
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
        IdSousCategorie Int NOT NULL ,
        CodeType Char (4) NOT NULL 
	,CONSTRAINT Type_PK PRIMARY KEY (IdType)

	,CONSTRAINT Type_SousCategorie_FK FOREIGN KEY (IdSousCategorie) REFERENCES SousCategorie(IdSousCategorie)
)ENGINE=InnoDB;

#------------------------------------------------------------
# Table: Utilisateur
#------------------------------------------------------------

CREATE TABLE Utilisateur(
        IdUtilisateur Int  Auto_increment  NOT NULL ,
        MDP           Varchar (256) NOT NULL ,
        Mail          Varchar (256) NOT NULL ,
        Nom           Varchar (256) NOT NULL
	,CONSTRAINT Utilisateur_PK PRIMARY KEY (IdUtilisateur)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Moderateur
#------------------------------------------------------------

CREATE TABLE Moderateur(
        IdModerateur Int  Auto_increment  NOT NULL ,
        MDP          Varchar (256) NOT NULL ,
        Mail         Varchar (256) NOT NULL ,
        Nom          Varchar (256) NOT NULL
	,CONSTRAINT Moderateur_PK PRIMARY KEY (IdModerateur)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Proposition
#------------------------------------------------------------

CREATE TABLE Proposition(
        IdModification  Int  Auto_increment  NOT NULL ,
        DateProposition Date NOT NULL ,
        TypeProposition Varchar (256) NOT NULL ,
        LibProposition  Text ,
        IdModerateur    Int ,
        IdUtilisateur   Int NOT NULL
	,CONSTRAINT Proposition_PK PRIMARY KEY (IdModification)

	,CONSTRAINT Proposition_Moderateur_FK FOREIGN KEY (IdModerateur) REFERENCES Moderateur(IdModerateur)
	,CONSTRAINT Proposition_Utilisateur0_FK FOREIGN KEY (IdUtilisateur) REFERENCES Utilisateur(IdUtilisateur)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Equipement
#------------------------------------------------------------

CREATE TABLE Equipement(
        IdEquipement           Int  Auto_increment  NOT NULL ,
        Cantine                Bool ,
        MaternellePrimaire     Bool ,
        LyceeCPGE              Bool ,
        EducPrio               Bool ,
        Internat               Bool ,
        RPIC                   Bool ,
        Secteur                Varchar (6) ,
        Couvert                Bool ,
        Eclaire                Bool ,
        NbAireJeu              Int ,
        NbSalles               Int ,
        IdType                 Int NOT NULL ,
        CodeCommune            Int ,
        IdLocalisation         Int
	,CONSTRAINT Equipement_PK PRIMARY KEY (IdEquipement)

        ,CONSTRAINT Equipement_Type1_FK FOREIGN KEY (IdType) REFERENCES Type(IdType)
	,CONSTRAINT Equipement_Commune2_FK FOREIGN KEY (CodeCommune) REFERENCES Commune(CodeCommune)
	,CONSTRAINT Equipement_Coordonnees3_FK FOREIGN KEY (IdLocalisation) REFERENCES Coordonnees(IdLocalisation)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Modifier
#------------------------------------------------------------

CREATE TABLE Modifier(
        IdEquipement  Int NOT NULL ,
        IdModerateur  Int NOT NULL ,
        DateModif     Date NOT NULL
	,CONSTRAINT Modifier_PK PRIMARY KEY (IdEquipement,IdModerateur)

	,CONSTRAINT Modifier_Equipement_FK FOREIGN KEY (IdEquipement) REFERENCES Equipement(IdEquipement)
	,CONSTRAINT Modifier_Moderateur_FK FOREIGN KEY (IdModerateur) REFERENCES Moderateur(IdModerateur)
)ENGINE=InnoDB;



#------------------------------------------------------------
# Table: TypeSanction
#------------------------------------------------------------
CREATE TABLE TypeSanction(
        IdTypeSanction INT AUTO_INCREMENT NOT NULL ,
        LibSanction VARCHAR (256) NOT NULL
        ,CONSTRAINT TypeSanction_PK PRIMARY KEY (IdTypeSanction)
)ENGINE=InnoDB;


#------------------------------------------------------------
# Table: Sanction
#------------------------------------------------------------

CREATE TABLE Sanction(
        IdSanction      Int AUTO_INCREMENT NOT NULL ,
        RaisonSanction Blob ,
        IdModerateur INT NOT NULL ,
        IdUtilisateur INT NOT NULL ,
        IdTypeSanction Int NOT NULL

        ,CONSTRAINT Sanction_PK PRIMARY KEY (IdSanction)

        ,CONSTRAINT Sanction_Moderateur0_FK FOREIGN KEY (IdModerateur) REFERENCES Moderateur(IdModerateur)
        ,CONSTRAINT Sanction_Utilisateur_FK FOREIGN KEY (IdUtilisateur) REFERENCES Utilisateur(IdUtilisateur)
        ,CONSTRAINT Sanction_TypeSanction_FK FOREIGN KEY (IdTypeSanction) REFERENCES TypeSanction(IdTypeSanction)
)ENGINE InnoDB;