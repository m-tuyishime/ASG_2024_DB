USE ASG_24;
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

---------------------------------------------------------Effacement de la base de donnees---------------------------------------------------------
go
USE master
go
-- IF EXISTS (SELECT name FROM master..sysdatabases WHERE name = 'ASG_24')
--     DROP DATABASE ASG_24;