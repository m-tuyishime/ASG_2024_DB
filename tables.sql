use master;
GO
-------------------------------Creation de la base de donnees-------------------------------
IF EXISTS (SELECT name FROM master..sysdatabases WHERE name = 'ASG_24')
    DROP DATABASE ASG_24;
go

CREATE DATABASE ASG_24;
go

USE ASG_24;
go
-------------------------------Creation des tables-------------------------------
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


CREATE TABLE Programme (
    ProgrammeID TINYINT,
    Niveau VARCHAR(10), -- Local, Competitif
    Saison VARCHAR(10) NOT NULL, -- Hiver, Ete, Automne, Printemps
    NomProgramme VARCHAR(50) NOT NULL, 
    AgeMin TINYINT NOT NULL, -- Age minimum pour le programme
    AgeMax TINYINT, -- Age maximum pour le programme (NULL pour senior)
    CONSTRAINT pk_programme PRIMARY KEY(ProgrammeID),
    CONSTRAINT uq_programme UNIQUE(Niveau, Saison, AgeMin, AgeMax), -- Un programme ne peut pas avoir la meme combinaison de valeurs pour Niveau, Saison, AgeMin et AgeMax qu'un autre programme
    CONSTRAINT ck_age CHECK (AgeMin <= AgeMax), -- AgeMin doit etre inferieur ou egal a AgeMax
    CONSTRAINT ck_saison CHECK(Saison IN ('Hiver', 'Ete', 'Automne', 'Printemps')), -- Saison doit etre un des 4 choix possibles
    CONSTRAINT ck_niveau CHECK(Niveau IN ('Local', 'Competitif')) -- Niveau doit etre un des 2 choix possibles
);

CREATE TABLE Ligue (
    LigueID SMALLINT,
    ProgrammeID TINYINT NOT NULL,
    NomLigue VARCHAR(50) NOT NULL,
    Description VARCHAR(255),
    CONSTRAINT pk_ligue PRIMARY KEY(LigueID),
    CONSTRAINT fk_ligue_programme FOREIGN KEY (ProgrammeID) REFERENCES Programme(ProgrammeID) ON DELETE CASCADE
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
    CONSTRAINT fk_equipe_entraineur FOREIGN KEY (EntraineurID) REFERENCES Entraineur(EntraineurID) ON DELETE CASCADE,
    CONSTRAINT fk_equipe_ligue FOREIGN KEY (LigueID) REFERENCES Ligue(LigueID) ON DELETE CASCADE
);

ALTER TABLE Entraineur
ADD CONSTRAINT fk_entraineur_equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID); -- Ajout de la contrainte de cle etrangere (probleme de dependance circulaire)

CREATE TABLE Joueur (
    JoueurID SMALLINT,
    EquipeID TINYINT NOT NULL,
    TuteurID SMALLINT NOT NULL,
    Nom VARCHAR(50) NOT NULL,
    Prenom VARCHAR(50) NOT NULL,
    DateDeNaissance DATE NOT NULL,
    Position VARCHAR(50),
    CONSTRAINT pk_joueur PRIMARY KEY(JoueurID),
    CONSTRAINT fk_joueur_equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID) ON DELETE CASCADE,
    CONSTRAINT fk_joueur_tuteur FOREIGN KEY (TuteurID) REFERENCES Tuteur(TuteurID) ON DELETE CASCADE
);


CREATE TABLE Terrain (
    TerrainID TINYINT,
    Type VARCHAR(50) NOT NULL,
    Adresse VARCHAR(100) NOT NULL,
    CONSTRAINT pk_terrain PRIMARY KEY(TerrainID)
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

CREATE TABLE Match (
    MatchID INT UNIQUE,
    EquipeDomicileID TINYINT NOT NULL,
    EquipeExterieurID TINYINT NOT NULL,
    ArbitreID TINYINT NOT NULL,
    TerrainID TINYINT NOT NULL,
    TempsDebut DateTime NOT NULL,
    Statut VARCHAR(10) NOT NULL, -- Planifie, EnCours, Termine, Annule
    CONSTRAINT pk_match PRIMARY KEY(MatchID), 
    CONSTRAINT fk_match_equipedomicile FOREIGN KEY (EquipeDomicileID) REFERENCES Equipe(EquipeID) ON DELETE CASCADE,
    CONSTRAINT fk_match_equipeexterieur FOREIGN KEY (EquipeExterieurID) REFERENCES Equipe(EquipeID),
    CONSTRAINT fk_match_arbitre FOREIGN KEY (ArbitreID) REFERENCES Arbitre(ArbitreID) ON DELETE CASCADE,
    CONSTRAINT fk_match_terrain FOREIGN KEY (TerrainID) REFERENCES Terrain(TerrainID) ON DELETE CASCADE,
    CONSTRAINT uq_match_equipes_temps UNIQUE(EquipeDomicileID, EquipeExterieurID, TempsDebut), -- Un match ne peut pas avoir les memes equipes et le meme temps de debut qu'un autre match
    CONSTRAINT uq_match_arbitre_temps UNIQUE(ArbitreID, TempsDebut), -- Un arbitre ne peut pas etre assigne a deux matchs en meme temps
    CONSTRAINT uq_match_terrain_temps UNIQUE(TerrainID, TempsDebut), -- Un terrain ne peut pas etre utilise pour deux matchs en meme temps
    CONSTRAINT ck_match_statut CHECK(Statut IN ('Planifie', 'EnCours', 'Termine', 'Annule')), -- Statut doit etre un des 4 choix possibles
    CONSTRAINT ck_match_equipes CHECK(EquipeDomicileID != EquipeExterieurID), -- Equipe domicile et equipe exterieur doivent etre differentes
    CONSTRAINT ck_match_temps CHECK (
    (Statut = 'Planifie' AND TempsDebut > GETDATE()) OR 
    (Statut = 'EnCours' AND TempsDebut <= GETDATE()) OR 
    (Statut <> 'Planifie' AND Statut <> 'EnCours')) -- TempsDebut doit etre dans le futur si le match est planifie, dans le passe si le match est en cours, et n'importe quand si le match est termine ou annule

);

CREATE TABLE Pratique (
    PratiqueID INT,
    EquipeID TINYINT NOT NULL,
    TerrainID TINYINT NOT NULL,
    Statut VARCHAR(10) NOT NULL, -- Planifie, EnCours, Termine, Annule
    TempsDebut DateTime,
    CONSTRAINT pk_pratique PRIMARY KEY(PratiqueID),
    CONSTRAINT fk_pratique_equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID) ON DELETE CASCADE,
    CONSTRAINT fk_pratique_terrain FOREIGN KEY (TerrainID) REFERENCES Terrain(TerrainID) ON DELETE CASCADE,
    CONSTRAINT ck_pratique_statut CHECK(Statut IN ('Planifie', 'EnCours', 'Termine', 'Annule')), -- Statut doit etre un des 4 choix possibles
    CONSTRAINT ck_pratique_temps CHECK (
    (Statut = 'Planifie' AND TempsDebut > GETDATE()) OR 
    (Statut = 'EnCours' AND TempsDebut <= GETDATE()) OR 
    (Statut = 'Termine' AND TempsDebut < GETDATE()) OR 
    (Statut = 'Annule' AND TempsDebut < GETDATE())) -- TempsDebut doit etre dans le futur si la pratique est planifiee, dans le passe si la pratique est en cours, et n'importe quand si la pratique est terminee ou annulee
);

CREATE TABLE But (
    ButID INT,
    ButJoueurID SMALLINT NOT NULL,
    AssistJoueurID SMALLINT NULL DEFAULT NULL,
    MatchID INT NOT NULL,
    Temps DATETIME NOT NULL,
    CONSTRAINT pk_but PRIMARY KEY(ButID),
    CONSTRAINT fk_but_butjoueur FOREIGN KEY (ButJoueurID) REFERENCES Joueur(JoueurID) ON DELETE CASCADE,
    CONSTRAINT fk_but_assistjoueur FOREIGN KEY (AssistJoueurID) REFERENCES Joueur(JoueurID),
    CONSTRAINT fk_but_match FOREIGN KEY (MatchID) REFERENCES Match(MatchID) 
);

---------------------------------------------------------Creation des indexes---------------------------------------------------------

---------------------------------------------------------Triggers---------------------------------------------------------
GO
/* Trigger pour verifier que la date de naissance du joueur le rend eligible pour le programme de l'equipe */
CREATE TRIGGER tr_joueur_date_naissance 
ON Joueur
FOR INSERT, UPDATE AS
BEGIN
    DECLARE @LigueID SMALLINT;
    DECLARE @JoueurDateNaissance DATE;
    DECLARE @JoueurID SMALLINT;
    DECLARE @EquipeID TINYINT;
    DECLARE @AgeMin TINYINT;
    DECLARE @AgeMax TINYINT;
    DECLARE @ProgrammeID TINYINT;
    DECLARE @Age INT;

    DECLARE cur CURSOR FOR SELECT JoueurID, EquipeID, DateDeNaissance FROM inserted;
    OPEN cur;

    FETCH NEXT FROM cur INTO @JoueurID, @EquipeID, @JoueurDateNaissance;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @LigueID = LigueID FROM Equipe WHERE EquipeID = @EquipeID;
        SELECT @ProgrammeID = ProgrammeID FROM Ligue WHERE LigueID = @LigueID;
        SELECT @AgeMin = AgeMin, @AgeMax = AgeMax FROM Programme WHERE ProgrammeID = @ProgrammeID;

        SELECT @Age = DATEDIFF(YEAR, @JoueurDateNaissance, GETDATE());

        IF @Age < @AgeMin OR (@AgeMax IS NOT NULL AND @Age > @AgeMax)
        BEGIN
            RAISERROR('Le joueur ne respecte pas les criteres d''age du programme', 16, 1);
            ROLLBACK TRANSACTION;
        END

        FETCH NEXT FROM cur INTO @JoueurID, @EquipeID, @JoueurDateNaissance;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO
---------------------------------------------------------Creation de procedures stockees---------------------------------------------------------
GO
/* Procedure stockee pour obtenir le meilleur buteur d'un programme */
CREATE PROCEDURE sp_meilleur_buteur_programme
    @ProgrammeID TINYINT
AS
BEGIN
    SELECT TOP 1 J.Nom, J.Prenom, COUNT(B.ButID) AS NbButs
    FROM Joueur J
    JOIN But B ON J.JoueurID = B.ButJoueurID
    JOIN Equipe E ON J.EquipeID = E.EquipeID
    JOIN Ligue L ON E.LigueID = L.LigueID
    WHERE L.ProgrammeID = @ProgrammeID
    GROUP BY J.Nom, J.Prenom
    ORDER BY NbButs DESC;
END;
GO
/* Procedure stockee pour obtenir la moyenne de buts par match d'une equipe */
CREATE PROCEDURE sp_moyenne_buts_equipe
    @EquipeID TINYINT
AS
BEGIN
    SELECT AVG(NbButs) AS MoyenneButs
    FROM (
        SELECT COUNT(ButID) AS NbButs
        FROM But
        WHERE ButJoueurID IN (SELECT JoueurID FROM Joueur WHERE EquipeID = @EquipeID)
        GROUP BY MatchID
    ) AS ButsParMatch;
END;
GO

---------------------------------------------------------Creation de vues---------------------------------------------------------
GO 
/* Vue de tous les defenseurs */
CREATE VIEW vue_defenseurs AS
SELECT J.Nom, J.Prenom, J.Position
FROM Joueur J
WHERE J.Position = 'Defenseur';
GO

/* Vue pour obtenir les buteurs d'un programme en haut de la moyenne de buts par match */
CREATE VIEW vue_buteurs_programme AS
SELECT J.Nom, J.Prenom, COUNT(B.ButID) AS NbButs
FROM Joueur J
JOIN But B ON J.JoueurID = B.ButJoueurID
JOIN Equipe E ON J.EquipeID = E.EquipeID
JOIN Ligue L ON E.LigueID = L.LigueID
GROUP BY J.JoueurID, J.Nom, J.Prenom
HAVING COUNT(B.ButID) > (SELECT AVG(NbButs) FROM (
    SELECT COUNT(ButID) AS NbButs
    FROM But
    WHERE ButJoueurID = J.JoueurID
    GROUP BY MatchID
) AS ButsParMatch);
GO

/* Vue pour obtenir les entraineurs sans equipe */
CREATE VIEW vue_entraineurs_sans_equipe AS
SELECT E.Nom, E.Prenom, E.Email
FROM Entraineur E
WHERE E.EquipeID IS NULL;
GO

---------------------------------------------------------Mis à jour des données---------------------------------------------------------
UPDATE Joueur SET Position = 'Centre' WHERE Position = 'Midfielder';

Update Programme SET Saison = 'Ete' where Saison = 'Printemps' 

DELETE FROM Arbitre WHERE Email Not LIKE '%@%'

DELETE FROM Joueur WHERE DateDeNaissance < '2000-01-01';

DELETE FROM But WHERE Temps < GETDATE();

DELETE FROM Terrain WHERE Type not In ('Intérieur' , 'Extérieur')

Delete From Joueur Where Prenom = Nom

Update But set AssistJoueurID = null where AssistJoueurID = ButJoueurID

---------------------------------------------------------Alteration des tables---------------------------------------------------------
ALTER TABLE Joueur
ADD Adresse VARCHAR(100) NOT NULL; -- Ajout de la colonne Adresse

ALTER TABLE Tuteur
DROP COLUMN Adresse; -- Suppression de la colonne Adresse

ALTER TABLE Tuteur
ADD Ville VARCHAR(50) NOT NULL; -- Ajout de la colonne Ville

ALTER TABLE Joueur
ADD CONSTRAINT ck_joueur_position CHECK (Position IN ('Attaquant', 'Défenseur', 'Gardien')); -- Ajout de la contrainte de verification de la position

ALTER TABLE Joueur
DROP CONSTRAINT ck_joueur_position; -- Suppression de la contrainte de verification de la position
ALTER TABLE Joueur
ADD CONSTRAINT ck_joueur_position CHECK (Position IN ('Attaquant', 'Défenseur', 'Gardien', 'Milieu')); -- Ajout de la contrainte de verification de la position

-- ALTER TABLE Equipe
-- DROP COLUMN Classement;

ALTER TABLE Equipe
ADD AnneeFondation INT NOT NULL; -- Ajout de la colonne AnneeFondation
GO

ALTER TABLE Equipe
ALTER COLUMN AnneeFondation CHAR(4); -- Changement du type de donnees de AnneeFondation

ALTER TABLE Equipe
ADD CONSTRAINT ck_equipe_anneefondation CHECK (AnneeFondation >= 0); -- Ajout de la contrainte de verification de AnneeFondation

-- ALTER TABLE Match
-- ADD CONSTRAINT ck_match_niveau CHECK (Niveau IN ('Amical', 'Ligue', 'Tournoi'));

ALTER TABLE Match
DROP CONSTRAINT ck_match_statut;
ALTER TABLE Match
ADD CONSTRAINT ck_match_statut CHECK (Statut IN ('Planifié', 'EnCours', 'Terminé', 'Annulé')); -- Changement de la contrainte de verification de Statut

ALTER TABLE But
ADD Commentaire VARCHAR(255); -- Ajout de la colonne Commentaire

-- pour supprimer la contrainte de cle etrangere fk_but_assistjoueur
DECLARE @ConstraintName nvarchar(200)
SELECT @ConstraintName = Name FROM SYS.DEFAULT_CONSTRAINTS WHERE PARENT_OBJECT_ID = OBJECT_ID('But') AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns WHERE NAME = N'AssistJoueurID' AND object_id = OBJECT_ID('But'))
IF @ConstraintName IS NOT NULL
    EXEC('ALTER TABLE But DROP CONSTRAINT ' + @ConstraintName)
-- pour supprimer la colonne AssistJoueurID
ALTER TABLE But
DROP CONSTRAINT fk_but_assistjoueur;

ALTER TABLE But
DROP COLUMN AssistJoueurID; -- Suppression de la colonne AssistJoueurID

ALTER TABLE Ligue
ALTER COLUMN Description TEXT NOT NULL; -- Changement du type de donnees de Description

ALTER TABLE Ligue
ALTER COLUMN NomLigue VARCHAR(100) NOT NULL; -- Changement du type de donnees de NomLigue

ALTER TABLE Ligue
ADD DateDebut DATE NOT NULL; -- Ajout de la colonne DateDebut




--- delete from Entraineur where DateNaissance <= DATEADD(Year, -18, getdate())

-- Delete from tuteur where DateNaissance <= DATEADD(Year, -18, getdate())

---------------------------------------------------------Selection des donnees (une table)---------------------------------------------------------
SELECT * FROM Joueur
SELECT * FROM Tuteur
SELECT * FROM Programme

---------------------------------------------------------Selection des donnees (jointure & condition)---------------------------------------------------------
SELECT J.Nom, J.Prenom, J.Position, E.Nom AS NomEquipe
FROM Joueur J
JOIN Equipe E ON J.EquipeID = E.EquipeID
WHERE E.Nom = 'Equipe1' -- Selection des joueurs de l'equipe 'Equipe1'

SELECT J.Nom, J.Prenom, J.Position, E.Nom AS NomEquipe
FROM Joueur J
JOIN Equipe E ON J.EquipeID = E.EquipeID
WHERE J.Position = 'Attaquant' -- Selection des attaquants


SELECT J.Nom, J.Prenom, J.Position, E.Nom AS NomEquipe
FROM Joueur J
JOIN Equipe E ON J.EquipeID = E.EquipeID
WHERE J.Position = 'Attaquant' AND E.Nom = 'Equipe1' -- Selection des attaquants de l'equipe 'Equipe1'

---------------------------------------------------------Selection des donnees (deux jointures & conditions)---------------------------------------------------------
SELECT J.Nom, J.Prenom, J.Position, E.Nom AS NomEquipe, L.NomLigue
FROM Joueur J
JOIN Equipe E ON J.EquipeID = E.EquipeID
JOIN Ligue L ON E.LigueID = L.LigueID
WHERE J.Position = 'Attaquant' AND L.NomLigue = 'Ligue1' -- Selection des ataquants de la ligue 'Ligue1'

SELECT J.Nom, J.Prenom, J.Position, E.Nom AS NomEquipe, L.NomLigue
FROM Joueur J
JOIN Equipe E ON J.EquipeID = E.EquipeID
JOIN Ligue L ON E.LigueID = L.LigueID
WHERE J.Position = 'Attaquant' AND L.NomLigue = 'Ligue1' AND E.Nom = 'Equipe1' -- Selection des attaquants de l'equipe 'Equipe1' de la ligue 'Ligue1'


---------------------------------------------------------Effacement de la base de donnees---------------------------------------------------------
USE master;
go
-- IF EXISTS (SELECT name FROM master..sysdatabases WHERE name = 'ASG_24')
--     DROP DATABASE ASG_24;

