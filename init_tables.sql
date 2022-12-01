-- справочник типов документов
CREATE TABLE IF NOT EXISTS eid_types (
    id SERIAL PRIMARY KEY,
    eid_type_name VARCHAR NOT NULL UNIQUE
);


-- таблица-справочник органов, выдающие паспорта
CREATE TABLE IF NOT EXISTS issuing_authorities (
    ia_id SERIAL PRIMARY KEY,
    ia_code VARCHAR NOT NULL,
    ia_name VARCHAR NOT NULL
);


-- документ абитуриента, удостоверяющий личность
CREATE TABLE IF NOT EXISTS entrant_identity_documents (
    eid_id SERIAL PRIMARY KEY,
    eid_type SMALLINT NOT NULL DEFAULT 1
        REFERENCES eid_types(id),
    eid_serial VARCHAR,
    eid_number VARCHAR NOT NULL,
    eid_issued_by INTEGER NOT NULL
        REFERENCES issuing_authorities(ia_id),
    eid_issue_day DATE NOT NULL
);


-- справочник типов документов об образовании
CREATE TABLE IF NOT EXISTS eed_types (
    id SERIAL PRIMARY KEY,
    eed_type_name VARCHAR NOT NULL UNIQUE
);


-- справочник организаций, выдающих документы об образовании
CREATE TABLE IF NOT EXISTS eed_issuing_organizations (
    id SERIAL PRIMARY KEY,
    io_name VARCHAR NOT NULL UNIQUE
);


-- документ об образовании
CREATE TABLE IF NOT EXISTS entrant_education_documents (
    eed_id SERIAL PRIMARY KEY,
    eed_type SMALLINT NOT NULL
        REFERENCES eed_types(id),
    eed_serial VARCHAR,
    eed_number VARCHAR NOT NULL,
    eed_issued_by INTEGER NOT NULL
        REFERENCES eed_issuing_organizations(id),
    eed_issue_day DATE NOT NULL,
    eed_original_of_eed BOOLEAN DEFAULT false
);


-- личные данные абитуриента
CREATE TABLE IF NOT EXISTS entrants (
    e_id SERIAL PRIMARY KEY,
    e_first_name VARCHAR NOT NULL,
    e_mid_name VARCHAR,
    e_last_name VARCHAR NOT NULL,
    e_gender CHAR NOT NULL,
    e_birthday DATE NOT NULL,
    e_email VARCHAR NOT NULL UNIQUE,
    e_mobile_phone VARCHAR NOT NULL,
    e_identity_document_id INTEGER NOT NULL
        REFERENCES entrant_identity_documents(eid_id),
    e_education_document_id INTEGER NOT NULL
        REFERENCES entrant_education_documents(eed_id)
);


CREATE TABLE IF NOT EXISTS exams (
    exam_id SERIAL PRIMARY KEY,
    exam_name VARCHAR NOT NULL UNIQUE,
    minimal_result SMALLINT NOT NULL
);


-- сведения о результатах экзаменов
CREATE TABLE IF NOT EXISTS entrant_exam_result (
    eer_id SERIAL PRIMARY KEY,
    eer_entrant_id INTEGER NOT NULL
        REFERENCES entrants(e_id),
    eer_exam_id SMALLINT NOT NULL
        REFERENCES exams(exam_id),
    eer_result SMALLINT NOT NULL,
    eer_exam_date DATE NOT NULL
);


-- список специальностей
CREATE TABLE IF NOT EXISTS specialties (
    id SERIAL PRIMARY KEY,
    s_code VARCHAR NOT NULL,
    s_name VARCHAR NOT NULL,
    s_budget_places_count SMALLINT NOT NULL,
    s_exam_id SMALLINT NOT NULL
        REFERENCES exams(exam_id)
);


CREATE TABLE IF NOT EXISTS officer_positions (
    op_id SERIAL PRIMARY KEY,
    position VARCHAR NOT NULL UNIQUE
);


-- сотрудник приемной комиссии
CREATE TABLE IF NOT EXISTS admissions_officers (
    ao_id SERIAL PRIMARY KEY,
    ao_first_name VARCHAR NOT NULL,
    ao_mid_name VARCHAR,
    ao_last_name VARCHAR NOT NULL,
    ao_position_id SMALLINT NOT NULL DEFAULT 1
        REFERENCES officer_positions(op_id),
    ao_email VARCHAR NOT NULL UNIQUE,
    ao_mobile_phone VARCHAR NOT NULL UNIQUE
);


-- заявления о поступлении
CREATE TABLE IF NOT EXISTS admission_applications (
    aa_id SERIAL PRIMARY KEY,
    aa_entrant_id INTEGER NOT NULL
        REFERENCES entrants(e_id),
    aa_speciality_id INTEGER NOT NULL
        REFERENCES specialties(id),
    aa_competition_points SMALLINT NOT NULL,
    aa_agreement BOOLEAN DEFAULT false,
    aa_date DATE,
    aa_responsible_officer_id INTEGER NOT NULL
        REFERENCES admissions_officers(ao_id)
);