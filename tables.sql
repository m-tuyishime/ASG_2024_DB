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

CREATE TABLE Ligue (
    LigueID SMALLINT,
    NomLigue VARCHAR(50) NOT NULL,
    Description VARCHAR(255),
    CONSTRAINT pk_ligue PRIMARY KEY(LigueID),
);

CREATE TABLE Programme (
    ProgrammeID TINYINT,
    LigueID SMALLINT NOT NULL,
    Niveau VARCHAR(10), -- Local, Competitif
    Saison VARCHAR(10) NOT NULL, -- Hiver, Ete, Automne, Printemps
    NomProgramme VARCHAR(50) NOT NULL, 
    AgeMin TINYINT NOT NULL, -- Age minimum pour le programme
    AgeMax TINYINT, -- Age maximum pour le programme (NULL pour senior)
    CONSTRAINT pk_programme PRIMARY KEY(ProgrammeID),
    CONSTRAINT fk_programme_ligue FOREIGN KEY (LigueID) REFERENCES Ligue(LigueID),
    CONSTRAINT uq_programme UNIQUE(Niveau, Saison, AgeMin, AgeMax, LigueID), -- Un programme ne peut pas avoir la meme combinaison de valeurs pour Niveau, Saison, AgeMin, AgeMax, et ligueID qu'un autre programme
    CONSTRAINT ck_age CHECK (AgeMin <= AgeMax), -- AgeMin doit etre inferieur ou egal a AgeMax
    CONSTRAINT ck_saison CHECK(Saison IN ('Hiver', 'Ete', 'Automne', 'Printemps')), -- Saison doit etre un des 4 choix possibles
    CONSTRAINT ck_niveau CHECK(Niveau IN ('Local', 'Competitif')) -- Niveau doit etre un des 2 choix possibles
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
    ProgrammeID TINYINT NOT NULL,
    Nom VARCHAR(50) NOT NULL,
    Classement TINYINT UNIQUE NOT NULL,
    CONSTRAINT pk_equipe PRIMARY KEY(EquipeID),
    CONSTRAINT fk_equipe_entraineur FOREIGN KEY (EntraineurID) REFERENCES Entraineur(EntraineurID),
    CONSTRAINT fk_equipe_programme FOREIGN KEY (programmeID) REFERENCES Programme(programmeID)
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
    CONSTRAINT fk_joueur_equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID),
    CONSTRAINT fk_joueur_tuteur FOREIGN KEY (TuteurID) REFERENCES Tuteur(TuteurID)
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
    CONSTRAINT fk_match_equipedomicile FOREIGN KEY (EquipeDomicileID) REFERENCES Equipe(EquipeID),
    CONSTRAINT fk_match_equipeexterieur FOREIGN KEY (EquipeExterieurID) REFERENCES Equipe(EquipeID),
    CONSTRAINT fk_match_arbitre FOREIGN KEY (ArbitreID) REFERENCES Arbitre(ArbitreID),
    CONSTRAINT fk_match_terrain FOREIGN KEY (TerrainID) REFERENCES Terrain(TerrainID),
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
    CONSTRAINT fk_pratique_equipe FOREIGN KEY (EquipeID) REFERENCES Equipe(EquipeID),
    CONSTRAINT fk_pratique_terrain FOREIGN KEY (TerrainID) REFERENCES Terrain(TerrainID),
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
    CONSTRAINT fk_but_butjoueur FOREIGN KEY (ButJoueurID) REFERENCES Joueur(JoueurID),
    CONSTRAINT fk_but_assistjoueur FOREIGN KEY (AssistJoueurID) REFERENCES Joueur(JoueurID),
    CONSTRAINT fk_but_match FOREIGN KEY (MatchID) REFERENCES Match(MatchID)
);

---------------------------------------------------------Creation des indexes---------------------------------------------------------
--Index Joueur--
Create index Joueur_INDEX on Joueur (Nom,Prenom);
--Index Terrain--
Create index Terrain_INDEX on Terrain (Adresse);
--Index Tuteur--
Create index Tuteur_INDEX on Tuteur (Nom, Prenom);
--Index BUT PAR JOUEUR QUI FAIT LE BUT--
Create index BUT_JOUEUR_INDEX on BUT (BUTJOUEURID);
--Index but par joueur qui assiste--
Create index ASSIST_JOUEUR_INDEX on BUT (AssistJoueurID);
---------------------------------------------------------Triggers---------------------------------------------------------
GO
/* Trigger pour verifier que la date de naissance du joueur le rend eligible pour le programme de l'equipe */
CREATE TRIGGER tr_joueur_date_naissance 
ON Joueur
FOR INSERT, UPDATE AS
BEGIN
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
        SELECT @ProgrammeID = ProgrammeID FROM Equipe WHERE EquipeID = @EquipeID;
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

--Verifie si une equipe a deja plus que 24 joueurs et decline l'ajout si oui --
CREATE TRIGGER Max_JOUEUR_Team_check
ON Joueur
AFTER INSERT
AS
BEGIN
    DECLARE @EquipeID TINYINT
    DECLARE @PlayerCount INT
    SELECT @EquipeID = i.EquipeID
    FROM inserted i
    SELECT @PlayerCount = COUNT(*)
    FROM Joueur
    WHERE EquipeID = @EquipeID 
    IF @PlayerCount > 12
    BEGIN    
        ROLLBACK TRANSACTION
    END
	end
go

/*
		Test du Trigger. L équipeID 10 a déjà 12 joueur. Essayons d'en ajouter un 13e.
*/

INSERT INTO Joueur (JoueurID, EquipeID, TuteurID, Nom, Prenom, DateDeNaissance, Position)
VALUES
(121, 10, 109, 'Lefebvre', 'Étienne', '2006-01-01', 'Milieu de terrain')


go
--Verifie si un programme a deja le maximum d'equipe et decline l'ajout si le cap est deja atteint --
CREATE TRIGGER Max_Team_Programme
ON Equipe
AFTER INSERT
AS 
BEGIN
    DECLARE @Programme_num SMALLINT
    SET @Programme_num = (SELECT ProgrammeID FROM inserted)
	print @programme_num
    DECLARE @NombreEquipeProgramme TINYINT
    SELECT @NombreEquipeProgramme = COUNT(*)
    FROM Equipe
    WHERE ProgrammeID = @Programme_num

    IF @NombreEquipeProgramme > 10
        ROLLBACK TRANSACTION
END
GO

drop trigger Max_Team_Programme
/*
		Test du Trigger. Le programmeID 86 a déjà 10 équipe. Essayons d'en ajouter un 11e.
*/

-- Team 11
INSERT INTO Equipe (EquipeID, EntraineurID, ProgrammeID, Nom, Classement)
VALUES (11, 10, 86, 'Team 11', 11);

---------------------------------------------------------Creation de procedures stockees---------------------------------------------------------
go
--Va montrer les 3 stars du match (joueurs ayant marque le plus me but) --
Create proc star_du_match (@Match INT) as

Begin
	Select TOP 3 JoueurID, Nom, Prenom
	From But
	Join Joueur ON ButJoueurID = JoueurID 
	Where MatchID = @Match
	GROUP BY JoueurID, Nom, Prenom
    
End
go

exec star_du_match 1

go
--Procedure qui selection les enfants d'un tuteur--
Create proc enfant_de_tuteur (@Tuteurid Smallint) as

Begin
	Select Joueur.Prenom, Joueur.Nom 
	from Joueur
	Where Joueur.TuteurID = @Tuteurid
End

Go
---------------------------------------------------------Troies vues de différent type---------------------------------------------------------\
--Create view pour les �quipes qui jouent en automne
Create view Equipe_automne as
select equipe.nom 
from equipe,Programme 
where Equipe.ProgrammeID = programme.ProgrammeID and programme.Saison = 'automne'
go

--Create view pour voir les joueurs qui peuvent jouer en comp�titif   

create view JoueursCompetitifs 
(id, equipeId, Tuteur, nom, prenom, datedeNaiss, Pos)  as
select JoueurID, EquipeID, TuteurId, nom, prenom, DateDeNaissance,Position from joueur
where DATEDIFF(yy, DateDeNaissance, GETDATE()) > 12
go


--Create view multitable pour voir quel joueur a fait un but

create view JoueurBut as 
select joueur.prenom, joueur.nom 
from joueur join But on joueurid = ButJoueurID
go
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

ALTER TABLE Equipe
ADD AnneeFondation INT NOT NULL; -- Ajout de la colonne AnneeFondation
GO

ALTER TABLE Equipe
ALTER COLUMN AnneeFondation CHAR(4); -- Changement du type de donnees de AnneeFondation
go

ALTER TABLE Equipe
ADD CONSTRAINT ck_equipe_anneefondation CHECK (AnneeFondation >= 0); -- Ajout de la contrainte de verification de AnneeFondation

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


ALTER TABLE Ligue
ALTER COLUMN Description TEXT NOT NULL; -- Changement du type de donnees de Description

ALTER TABLE Ligue
ALTER COLUMN NomLigue VARCHAR(100) NOT NULL; -- Changement du type de donnees de NomLigue

ALTER TABLE Ligue
ADD DateDebut DATE NOT NULL; -- Ajout de la colonne DateDebut

---------------------------------------------------------Modification de la base---------------------------------------------------------\
--Ajout Column DateNaissanceParents--
Alter table Tuteur
Add DateNaissanceParents date;
--Changement du nom column DateNaissanceParents--
exec sp_rename 'Tuteur.DateNaissanceParents', 'DateNaissance' , 'COLUMN'
--Changement du nom de la column Temps-
exec sp_rename 'but.temps' , 'tempsbut', 'column'

--Ajout column NomGoaler dans tableau But -- Alter table But add NomGoaler varchar(20);
Alter table But
add NomGoaler varchar(20);
--Retrait column NomGoaler du tableau But--
ALter table But
drop column NomGoaler;
--Rajout d'une Column Ville dans tableau Terrain--
ALter table Terrain
Add Ville varchar(10);
--Rajout d'une Column TempsTerminer dans tableau Match--
Alter table Match
Add TempsTerminer DateTime;

---------------------------------------------------------Selection des donnees (une table)---------------------------------------------------------
-- Montrer tous les joueurs dont le nom commence avec 'A'
Select prenom, nom from joueur
where nom like 'A%'

-- Montrer le classement de l'Equipe 1
select classement from equipe
where equipeId = 1 

-- Montrer toutes les adresses des terrains
select type, Adresse from terrain

---------------------------------------------------------Selection des donnees (jointure & condition)---------------------------------------------------------
/* Montre tout les joueurs d'une equipe qui sont des defenseurs */

Select Joueur.Prenom, Joueur.Nom, Joueur.Position, Equipe.Nom
from Equipe
Join Joueur on Joueur.EquipeID = Equipe.EquipeID
Where Joueur.EquipeID = Equipe.EquipeID and Joueur.Position = 'Défenseur'
go

/* Selectionne tout les joueurs qui compte plus que 3 buts */
/******************/
SELECT Joueur.Prenom, Joueur.Nom
FROM But
JOIN Joueur ON Joueur.JoueurID = But.ButJoueurID
GROUP BY Joueur.Prenom, Joueur.Nom
HAVING COUNT(But.ButID) > 3;
/*********************/
/* Fait une liste de tout les match jou� � l'�tranger par l'equipe avec l'id 110 et l'adresse de ceux-ci */
Select Match.MatchID, Terrain.Adresse
from Match
Join Terrain on Terrain.TerrainID = Match.TerrainID
Where Match.EquipeDomicileID = 10

---------------------------------------------------------Selection des donnees (deux jointures & conditions)---------------------------------------------------------
/* Selectionne les �quipes ayant marqu� plus de deux points quand une �quipe recevait une autre. */
Select Equipe.Nom , count(but.butID) as Nombre_de_but_marque
From Match
Join Equipe on Equipe.EquipeID = Match.EquipeExterieurID
Join But on But.MatchID = Match.MatchID
Group By Equipe.Nom
Having count(but.butID) > 2

-- Selection des attaquants de l'equipe 'Team 1' de la ligue 'Est'
SELECT J.Nom, J.Prenom, J.Position, E.Nom AS NomEquipe, L.NomLigue
FROM Joueur J
JOIN Equipe E ON J.EquipeID = E.EquipeID
JOIN Programme P ON E.ProgrammeID = P.ProgrammeID
JOIN Ligue L ON P.LigueID = L.LigueID
WHERE J.Position = 'Attaquant' AND E.Nom = 'Team 1' AND L.NomLigue = 'Est'
---------------------------------------------------------Group et Having---------------------------------------------------------
/* Selectionne tout les joueurs qui ont plus que 3 buts dans une saison */
Select Joueur.Prenom, Joueur.Nom, count(*) as NombreBut
From But
Join Joueur on Joueur.JoueurID = But.ButJoueurID
Group By Joueur.Prenom, Joueur.Nom
Having Count(*) > 3
go

/* Montre tout les terrains sous-utlis� (qui ont moins de 25 matchs par saison) */

Select Terrain.Adresse, count(*) as NombreMatch
From Match
Join Terrain on Terrain.TerrainID = Match.TerrainID
Group by Terrain.Adresse
Having Count(*) < 25
Order By NombreMatch ASC
go


---------------------------------------------------------Requêtes SQL avec sous-requêtes---------------------------------------------------------\
--Requête pour voir les équipes qui sont placés plus haut que la moyenne
select equipe.nom 
from equipe
where classement > (select avg(classement) from equipe)

--Requête pour voir les joueurs qui marquent plus que la moyenne
SELECT J.prenom, J.nom 
FROM Joueur J
JOIN But B ON J.JoueurID = B.ButJoueurID
GROUP BY J.prenom, J.nom
HAVING COUNT(B.ButID) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(ButID) as cnt
        FROM But
        GROUP BY ButJoueurID
    ) as subquery
);


-- Requête pour voir quelles equipes ont plus que la moyenne de joueurs 
SELECT E.Nom
FROM Equipe E
GROUP BY E.Nom
HAVING COUNT(EquipeID) > (
    SELECT AVG(cnt)
    FROM (
        SELECT COUNT(JoueurID) as cnt
        FROM Joueur
        GROUP BY EquipeID
    ) as subquery
);

---------------------------------------------------------Effacement de la base de donnees---------------------------------------------------------
USE master;
go
-- IF EXISTS (SELECT name FROM master..sysdatabases WHERE name = 'ASG_24')
--     DROP DATABASE ASG_24;

