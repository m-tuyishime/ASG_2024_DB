use master;
-------------------------------Creation de la base de donnees-------------------------------
IF EXISTS (SELECT name FROM master..sysdatabases WHERE name = 'ASG_24')
    DROP DATABASE ASG_24;

CREATE DATABASE ASG_24;

USE ASG_24;
-------------------------------Creation des tables-------------------------------
CREATE TABLE Joueur (
    JoueurID SMALLINT,
    EquipeID TINYINT NOT NULL,
    TuteurID SMALLINT NOT NULL,
    Nom VARCHAR(50) NOT NULL,
    Prenom VARCHAR(50) NOT NULL,
    DateDeNaissance DATE NOT NULL,
    Position VARCHAR(50),
    CONSTRAINT pk_joueur PRIMARY KEY(JoueurID),
    CONSTRAINT fk_joueur_equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID),
    CONSTRAINT fk_joueur_tuteur FOREIGN KEY (TuteurID) REFERENCES Tuteur(TuteurID)
);

CREATE TABLE Tuteur (
    TuteurID SMALLINT,
    Nom VARCHAR(50) NOT NULL,
    Prenom VARCHAR(50) NOT NULL,
    Telephone CHAR(20) NOT NULL, -- Numero de telephone fixe
    Adresse VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT pk_tuteur PRIMARY KEY(TuteurID),
    CONSTRAINT ck_tuteur_telephone CHECK(Telephone LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') -- Format du telephone
);

CREATE TABLE Entraineur (
    EntraineurID TINYINT,
    EquipeID TINYINT NULL,
    Nom VARCHAR(50) NOT NULL,
    Prenom VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telephone CHAR(20) NOT NULL, -- Numero de telephone fixe
    NAS CHAR(11) UNIQUE NOT NULL, -- Numero d'assurance sociale fixe
    CONSTRAINT pk_entraineur PRIMARY KEY(EntraineurID),
    CONSTRAINT fk_entraineur_equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID),
    CONSTRAINT ck_entraineur_nas CHECK(NAS LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]'), -- Format du NAS
    CONSTRAINT ck_entraineur_telephone CHECK(Telephone LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]') -- Format du telephone
);

CREATE TABLE Equipe (
    EquipeID TINYINT,
    EntraineurID TINYINT NOT NULL,
    LigueID SMALLINT NOT NULL,
    Nom VARCHAR(50) NOT NULL,
    Classement TINYINT UNIQUE NOT NULL,
    CONSTRAINT pk_equipe PRIMARY KEY(EquipeID),
    CONSTRAINT fk_equipe_entraineur FOREIGN KEY (EntraineurID) REFERENCES Entraineur(EntraineurID),
    CONSTRAINT fk_equipe_ligue FOREIGN KEY (LigueID) REFERENCES Ligue(LigueID)
);

CREATE TABLE Terrain (
    TerrainID TINYINT,
    Type VARCHAR(50) NOT NULL,
    Adresse VARCHAR(100) NOT NULL,
    CONSTRAINT pk_terrain PRIMARY KEY(TerrainID)
);

CREATE TABLE Programme (
    ProgrammeID TINYINT,
    Niveau VARCHAR(10), -- Local, Competitif
    Saison VARCHAR(10) NOT NULL, -- Hiver, Ete, Automne, Printemps
    NomProgramme VARCHAR(50) NOT NULL, 
    AgeMin TINYINT NOT NULL, -- Age minimum pour le programme
    AgeMax TINYINT, -- Age maximum pour le programme (NULL pour senior)
    CONSTRAINT pk_programme PRIMARY KEY(ProgrammeID),
    CONSTRAINT uq_programme UNIQUE(Niveau, Saison, AgeMin, AgeMax), -- Un programme ne peut pas avoir les memes valeurs pour Niveau, Saison, AgeMin et AgeMax qu'un autre programme
    CONSTRAINT ck_age CHECK (AgeMin <= AgeMax), -- AgeMin doit etre inferieur ou egal a AgeMax
    CONSTRAINT ck_saison CHECK(Saison IN ('Hiver', 'Ete', 'Automne', 'Printemps')), -- Saison doit etre un des 4 choix possibles
    CONSTRAINT ck_niveau CHECK(Niveau IN ('Local', 'Competitif')) -- Niveau doit etre un des 2 choix possibles
);

CREATE TABLE Match (
    MatchID INT UNIQUE,
    EquipeDomicileID TINYINT NOT NULL,
    EquipeExterieurID TINYINT NOT NULL,
    ArbitreID TINYINT NOT NULL,
    TerrainID TINYINT NOT NULL,
    TempsDebut DateTime NOT NULL,
    Statut VARCHAR(10) NOT NULL, -- Planifie, EnCours, Termine, Annule
    CONSTRAINT pk_match PRIMARY KEY(MatchID), 
    CONSTRAINT fk_match_equipedomicile FOREIGN KEY (EquipeDomicileID) REFERENCES Equipe(EquipeID),
    CONSTRAINT fk_match_equipeexterieur FOREIGN KEY (EquipeExterieurID) REFERENCES Equipe(EquipeID),
    CONSTRAINT fk_match_arbitre FOREIGN KEY (ArbitreID) REFERENCES Arbitre(ArbitreID),
    CONSTRAINT fk_match_terrain FOREIGN KEY (TerrainID) REFERENCES Terrain(TerrainID),
    CONSTRAINT uq_match_equipes_temps UNIQUE(EquipeDomicileID, EquipeExterieurID, TempsDebut), -- Un match ne peut pas avoir les memes equipes et le meme temps de debut qu'un autre match
    CONSTRAINT uq_match_arbitre_temps UNIQUE(ArbitreID, TempsDebut), -- Un arbitre ne peut pas etre assigne a deux matchs en meme temps
    CONSTRAINT uq_match_terrain_temps UNIQUE(TerrainID, TempsDebut), -- Un terrain ne peut pas etre utilise pour deux matchs en meme temps
    CONSTRAINT ck_match_statut CHECK(Statut IN ('Planifie', 'EnCours', 'Termine', 'Annule')), -- Statut doit etre un des 4 choix possibles
    CONSTRAINT ck_match_equipes CHECK(EquipeDomicileID != EquipeExterieurID), -- Equipe domicile et equipe exterieur doivent etre differentes
    CONSTRAINT ck_match_temps CHECK(IF Statut = 'Planifie' THEN TempsDebut > NOW() ELSE IF Statut = 'EnCours' THEN TempsDebut <= NOW() ELSE TRUE), -- TempsDebut doit etre dans le futur si le match est planifie, dans le passe si le match est en cours, et n'importe quand si le match est termine ou annule

);

CREATE TABLE Arbitre (
    ArbitreID TINYINT,
    Nom VARCHAR(50) NOT NULL,
    Prenom VARCHAR(50) NOT NULL,
    Telephone VARCHAR(20) NOT NULL,
    NAS CHAR(11) UNIQUE NOT NULL, -- Numero d'assurance sociale fixe
    Email VARCHAR(100) UNIQUE NOT NULL,
    CONSTRAINT pk_arbitre PRIMARY KEY(ArbitreID),
    CONSTRAINT ck_arbitre_nas CHECK(NAS LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]') -- Format du NAS
);

CREATE TABLE Pratique (
    PratiqueID INT,
    EquipeID TINYINT NOT NULL,
    TerrainID TINYINT NOT NULL,
    Statut VARCHAR(10) NOT NULL, -- Planifie, EnCours, Termine, Annule
    TempsDebut DateTime,
    CONSTRAINT pk_pratique PRIMARY KEY(PratiqueID),
    CONSTRAINT fk_pratique_equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID),
    CONSTRAINT fk_pratique_terrain FOREIGN KEY (TerrainID) REFERENCES Terrain(TerrainID),
    CONSTRAINT ck_pratique_statut CHECK(Statut IN ('Planifie', 'EnCours', 'Termine', 'Annule')), -- Statut doit etre un des 4 choix possibles
    CONSTRAINT ck_pratique_temps CHECK(IF Statut = 'Planifie' THEN TempsDebut > NOW() ELSE IF Statut = 'EnCours' THEN TempsDebut <= NOW() ELSE TRUE) -- TempsDebut doit etre dans le futur si la pratique est planifiee, dans le passe si la pratique est en cours, et n'importe quand si la pratique est terminee ou annulee
);

CREATE TABLE But (
    ButID INT,
    ButJoueurID SMALLINT NOT NULL,
    AssistJoueurID SMALLINT NULL DEFAULT NULL,
    MatchID INT NOT NULL,
    Temps DATETIME NOT NULL,
    CONSTRAINT pk_but PRIMARY KEY(ButID),
    CONSTRAINT fk_but_butjoueur FOREIGN KEY (ButJoueurID) REFERENCES Joueur(JoueurID),
    CONSTRAINT fk_but_assistjoueur FOREIGN KEY (AssistJoueurID) REFERENCES Joueur(JoueurID),
    CONSTRAINT fk_but_match FOREIGN KEY (MatchID) REFERENCES Match(MatchID)
);

CREATE TABLE Ligue (
    LigueID SMALLINT,
    ProgrammeID SMALLINT NOT NULL,
    NomLigue VARCHAR(50) NOT NULL,
    Description VARCHAR(255),
    CONSTRAINT pk_ligue PRIMARY KEY(LigueID),
    CONSTRAINT fk_ligue_programme FOREIGN KEY (ProgrammeID) REFERENCES Programme(ProgrammeID)
);

---------------------------------------------------------Creation des index---------------------------------------------------------

