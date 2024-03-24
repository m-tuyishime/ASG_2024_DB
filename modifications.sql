USE ASG_24;

---------------------------------------------------------Alteration des tables---------------------------------------------------------
ALTER TABLE Joueur
ADD COLUMN Adresse VARCHAR(100) NOT NULL AFTER Nom;

ALTER TABLE Tuteur
DROP COLUMN Adresse;

ALTER TABLE Tuteur
ADD COLUMN Ville VARCHAR(50) NOT NULL AFTER Nom;

ALTER TABLE Joueur
MODIFY COLUMN Position ENUM('Attaquant', 'Défenseur', 'Gardien') NOT NULL;

ALTER TABLE Joueur
CHANGE COLUMN Position Position ENUM('Attaquant', 'Défenseur', 'Gardien', 'Milieu') NOT NULL;

ALTER TABLE Equipe
DROP COLUMN Classement;

ALTER TABLE Equipe
ADD COLUMN AnneeFondation YEAR NOT NULL AFTER Nom;

ALTER TABLE Equipe
MODIFY COLUMN AnneeFondation INT UNSIGNED NOT NULL;

ALTER TABLE Match
ADD COLUMN Niveau ENUM('Amical', 'Ligue', 'Tournoi') NOT NULL AFTER Statut;

ALTER TABLE Match
MODIFY COLUMN Statut ENUM('Planifié', 'EnCours', 'Terminé', 'Annulé') NOT NULL;

ALTER TABLE But
ADD COLUMN Commentaire VARCHAR(255) AFTER Temps;

ALTER TABLE But
DROP COLUMN AssistJoueurID;

ALTER TABLE Ligue
MODIFY COLUMN Description TEXT NOT NULL;
ALTER TABLE Ligue
MODIFY COLUMN NomLigue VARCHAR(100) NOT NULL;
ALTER TABLE Ligue
ADD COLUMN DateDebut DATE NOT NULL AFTER ProgrammeID;
---------------------------------------------------------Mis à jour des données---------------------------------------------------------
UPDATE Joueur SET Position = 'Milieu' WHERE Position = 'Midfielder';

UPDATE Equipe SET AnneeFondation = 2000 WHERE EquipeID = 1;

DELETE FROM Joueur WHERE DateDeNaissance < '2000-01-01';

DELETE FROM But WHERE Temps < NOW();