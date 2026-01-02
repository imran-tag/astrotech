-- PostgreSQL Schema for astro_tech
-- Converted from MySQL
-- Database: astro_tech

-- Drop tables if they exist (in correct order to respect foreign keys)
DROP TABLE IF EXISTS fichier CASCADE;
DROP TABLE IF EXISTS intervention_technicien CASCADE;
DROP TABLE IF EXISTS intervention_referent CASCADE;
DROP TABLE IF EXISTS intervention_planning CASCADE;
DROP TABLE IF EXISTS intervention CASCADE;
DROP TABLE IF EXISTS affaire_referent CASCADE;
DROP TABLE IF EXISTS affaire CASCADE;
DROP TABLE IF EXISTS technicien_equipe CASCADE;
DROP TABLE IF EXISTS equipe_technicien CASCADE;
DROP TABLE IF EXISTS technicien CASCADE;
DROP TABLE IF EXISTS referent CASCADE;
DROP TABLE IF EXISTS contact CASCADE;
DROP TABLE IF EXISTS num_tel CASCADE;
DROP TABLE IF EXISTS adresse_email CASCADE;
DROP TABLE IF EXISTS habitation CASCADE;
DROP TABLE IF EXISTS particulier CASCADE;
DROP TABLE IF EXISTS organisation CASCADE;
DROP TABLE IF EXISTS agence CASCADE;
DROP TABLE IF EXISTS secteur CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS adresse CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Function to update modification timestamp
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.date_modification = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- Table: users
-- ========================================
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(150),
  role VARCHAR(50) DEFAULT 'user',
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_users_modtime BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: adresse
-- ========================================
CREATE TABLE adresse (
  id SERIAL PRIMARY KEY,
  adresse VARCHAR(150),
  code_postal VARCHAR(10),
  ville VARCHAR(100),
  province VARCHAR(100),
  pays VARCHAR(100),
  etage VARCHAR(10),
  appartement_local VARCHAR(50),
  batiment VARCHAR(50),
  interphone_digicode VARCHAR(50),
  escalier VARCHAR(50),
  porte_entree VARCHAR(50),
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_adresse_modtime BEFORE UPDATE ON adresse
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: adresse_email
-- ========================================
CREATE TABLE adresse_email (
  id SERIAL PRIMARY KEY,
  email VARCHAR(200) NOT NULL,
  type VARCHAR(50),
  contact_id INTEGER,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_adresse_email_modtime BEFORE UPDATE ON adresse_email
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: client
-- ========================================
CREATE TABLE client (
  id SERIAL PRIMARY KEY,
  numero VARCHAR(50),
  compte VARCHAR(50),
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  parent_id INTEGER REFERENCES client(id) ON DELETE SET NULL
);

CREATE TRIGGER update_client_modtime BEFORE UPDATE ON client
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: secteur
-- ========================================
CREATE TABLE secteur (
  id SERIAL PRIMARY KEY,
  client_id INTEGER REFERENCES client(id) ON DELETE CASCADE,
  nom_secteur VARCHAR(150) NOT NULL,
  note TEXT,
  adresse_id INTEGER REFERENCES adresse(id) ON DELETE SET NULL,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_secteur_modtime BEFORE UPDATE ON secteur
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: agence
-- ========================================
CREATE TABLE agence (
  id SERIAL PRIMARY KEY,
  client_id INTEGER REFERENCES client(id) ON DELETE CASCADE,
  nom_agence VARCHAR(150) NOT NULL,
  note TEXT,
  adresse_id INTEGER REFERENCES adresse(id) ON DELETE SET NULL,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_agence_modtime BEFORE UPDATE ON agence
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: organisation
-- ========================================
CREATE TABLE organisation (
  id SERIAL PRIMARY KEY,
  client_id INTEGER REFERENCES client(id) ON DELETE CASCADE,
  nom_organisation VARCHAR(150) NOT NULL,
  note TEXT,
  adresse_id INTEGER REFERENCES adresse(id) ON DELETE SET NULL,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_organisation_modtime BEFORE UPDATE ON organisation
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: particulier
-- ========================================
CREATE TABLE particulier (
  id SERIAL PRIMARY KEY,
  client_id INTEGER REFERENCES client(id) ON DELETE CASCADE,
  nom_complet VARCHAR(150) NOT NULL,
  note TEXT,
  adresse_id INTEGER REFERENCES adresse(id) ON DELETE SET NULL,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_particulier_modtime BEFORE UPDATE ON particulier
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: habitation
-- ========================================
CREATE TABLE habitation (
  id SERIAL PRIMARY KEY,
  reference VARCHAR(100) NOT NULL,
  surface DECIMAL(8,2),
  note TEXT,
  adresse_id INTEGER REFERENCES adresse(id) ON DELETE SET NULL,
  secteur_id INTEGER REFERENCES secteur(id) ON DELETE SET NULL,
  agence_id INTEGER REFERENCES agence(id) ON DELETE SET NULL,
  organisation_id INTEGER REFERENCES organisation(id) ON DELETE SET NULL,
  particulier_id INTEGER REFERENCES particulier(id) ON DELETE SET NULL,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_habitation_modtime BEFORE UPDATE ON habitation
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: num_tel
-- ========================================
CREATE TABLE num_tel (
  id SERIAL PRIMARY KEY,
  numero VARCHAR(20) NOT NULL,
  type VARCHAR(50),
  contact_id INTEGER,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_num_tel_modtime BEFORE UPDATE ON num_tel
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: contact
-- ========================================
CREATE TABLE contact (
  id SERIAL PRIMARY KEY,
  nom_complet VARCHAR(150) NOT NULL,
  poste VARCHAR(100),
  date_du DATE,
  date_au DATE,
  memo_note TEXT,
  client_id INTEGER REFERENCES client(id) ON DELETE CASCADE,
  secteur_id INTEGER REFERENCES secteur(id) ON DELETE SET NULL,
  habitation_id INTEGER REFERENCES habitation(id) ON DELETE SET NULL,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_contact_modtime BEFORE UPDATE ON contact
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: referent
-- ========================================
CREATE TABLE referent (
  id SERIAL PRIMARY KEY,
  nom_complet VARCHAR(150) NOT NULL,
  fonction VARCHAR(100),
  organisation VARCHAR(150),
  note TEXT,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_referent_modtime BEFORE UPDATE ON referent
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: technicien
-- ========================================
CREATE TABLE technicien (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100) NOT NULL,
  dateNaissance DATE,
  adresse VARCHAR(255),
  telephone VARCHAR(20) NOT NULL,
  email VARCHAR(150),
  pwd VARCHAR(255),
  specialite VARCHAR(100) NOT NULL,
  certifications TEXT,
  experience TEXT,
  zoneIntervention VARCHAR(255),
  dateEmbauche DATE,
  typeContrat VARCHAR(50),
  salaire DECIMAL(10,2),
  statut VARCHAR(50),
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_technicien_modtime BEFORE UPDATE ON technicien
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: equipe_technicien
-- ========================================
CREATE TABLE equipe_technicien (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(150) NOT NULL,
  description TEXT,
  chefId INTEGER REFERENCES technicien(id) ON DELETE SET NULL,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_equipe_technicien_modtime BEFORE UPDATE ON equipe_technicien
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: technicien_equipe (junction table)
-- ========================================
CREATE TABLE technicien_equipe (
  id SERIAL PRIMARY KEY,
  technicienId INTEGER NOT NULL REFERENCES technicien(id) ON DELETE CASCADE,
  equipeId INTEGER NOT NULL REFERENCES equipe_technicien(id) ON DELETE CASCADE,
  dateAffectation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(technicienId, equipeId)
);

-- ========================================
-- Table: affaire
-- ========================================
CREATE TABLE affaire (
  id SERIAL PRIMARY KEY,
  reference VARCHAR(150),
  titre VARCHAR(100),
  description VARCHAR(255),
  clientId INTEGER REFERENCES client(id) ON DELETE SET NULL,
  etatLogement VARCHAR(100),
  technicienId INTEGER REFERENCES technicien(id) ON DELETE SET NULL,
  equipeTechnicienId INTEGER REFERENCES equipe_technicien(id) ON DELETE SET NULL,
  dateDebut DATE,
  dateFin DATE,
  motsCles VARCHAR(900),
  dureePrevueHeures INTEGER,
  dureePrevueMinutes INTEGER,
  memo TEXT,
  memoPiecesJointes TEXT,
  adresse_id INTEGER REFERENCES adresse(id) ON DELETE SET NULL,
  client_adresse_id INTEGER,
  type_client_adresse VARCHAR(250),
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_affaire_modtime BEFORE UPDATE ON affaire
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: affaire_referent
-- ========================================
CREATE TABLE affaire_referent (
  id SERIAL PRIMARY KEY,
  idAffaire INTEGER NOT NULL REFERENCES affaire(id) ON DELETE CASCADE,
  idReferent INTEGER NOT NULL REFERENCES referent(id) ON DELETE CASCADE,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_affaire_referent_modtime BEFORE UPDATE ON affaire_referent
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: intervention
-- ========================================
CREATE TABLE intervention (
  id SERIAL PRIMARY KEY,
  titre VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  numero INTEGER NOT NULL,
  type VARCHAR(100) NOT NULL,
  priorite VARCHAR(50),
  etat VARCHAR(100),
  date_butoir_realisation DATE,
  date_cloture_estimee DATE,
  mots_cles VARCHAR(255),
  montant_intervention DECIMAL(10,2) DEFAULT 0.00,
  montant_main_oeuvre DECIMAL(10,2) DEFAULT 0.00,
  montant_fournitures DECIMAL(10,2) DEFAULT 0.00,
  date_prevue TIMESTAMP,
  duree_prevue_heures INTEGER,
  duree_prevue_minutes INTEGER,
  affaire_id INTEGER REFERENCES affaire(id) ON DELETE CASCADE,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_intervention_modtime BEFORE UPDATE ON intervention
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: intervention_planning
-- ========================================
CREATE TABLE intervention_planning (
  id SERIAL PRIMARY KEY,
  intervention_id INTEGER NOT NULL REFERENCES intervention(id) ON DELETE CASCADE,
  date_debut TIMESTAMP,
  date_fin TIMESTAMP,
  statut VARCHAR(50),
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_intervention_planning_modtime BEFORE UPDATE ON intervention_planning
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: intervention_referent
-- ========================================
CREATE TABLE intervention_referent (
  id SERIAL PRIMARY KEY,
  intervention_id INTEGER NOT NULL REFERENCES intervention(id) ON DELETE CASCADE,
  referent_id INTEGER NOT NULL REFERENCES referent(id) ON DELETE CASCADE,
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_intervention_referent_modtime BEFORE UPDATE ON intervention_referent
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: intervention_technicien
-- ========================================
CREATE TABLE intervention_technicien (
  id SERIAL PRIMARY KEY,
  intervention_id INTEGER NOT NULL REFERENCES intervention(id) ON DELETE CASCADE,
  technicien_id INTEGER NOT NULL REFERENCES technicien(id) ON DELETE CASCADE,
  role VARCHAR(100),
  createur_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER update_intervention_technicien_modtime BEFORE UPDATE ON intervention_technicien
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

-- ========================================
-- Table: fichier
-- ========================================
CREATE TABLE fichier (
  id SERIAL PRIMARY KEY,
  nom VARCHAR(255),
  chemin VARCHAR(255),
  taille INTEGER,
  type VARCHAR(100),
  idReferent INTEGER REFERENCES referent(id) ON DELETE CASCADE,
  idAffaire INTEGER REFERENCES affaire(id) ON DELETE CASCADE,
  date_upload TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  createur_id INTEGER
);

-- Indexes for better performance
CREATE INDEX idx_client_parent ON client(parent_id);
CREATE INDEX idx_adresse_email_contact ON adresse_email(contact_id);
CREATE INDEX idx_num_tel_contact ON num_tel(contact_id);
CREATE INDEX idx_contact_client ON contact(client_id);
CREATE INDEX idx_contact_secteur ON contact(secteur_id);
CREATE INDEX idx_contact_habitation ON contact(habitation_id);
CREATE INDEX idx_technicien_equipe_technicien ON technicien_equipe(technicienId);
CREATE INDEX idx_technicien_equipe_equipe ON technicien_equipe(equipeId);
CREATE INDEX idx_affaire_client ON affaire(clientId);
CREATE INDEX idx_affaire_technicien ON affaire(technicienId);
CREATE INDEX idx_affaire_referent_affaire ON affaire_referent(idAffaire);
CREATE INDEX idx_affaire_referent_referent ON affaire_referent(idReferent);
CREATE INDEX idx_intervention_affaire ON intervention(affaire_id);
CREATE INDEX idx_fichier_referent ON fichier(idReferent);
CREATE INDEX idx_fichier_affaire ON fichier(idAffaire);

-- Comments
COMMENT ON TABLE users IS 'User authentication and authorization';
COMMENT ON TABLE technicien IS 'Technicians working on interventions';
COMMENT ON TABLE equipe_technicien IS 'Teams of technicians';
COMMENT ON TABLE technicien_equipe IS 'Many-to-many relationship between technicians and teams';
COMMENT ON TABLE affaire IS 'Business cases/projects';
COMMENT ON TABLE intervention IS 'Interventions within a project';
