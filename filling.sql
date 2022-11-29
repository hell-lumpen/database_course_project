CREATE TABLE _names (
                        id SERIAL PRIMARY KEY,
                        name VARCHAR
);


CREATE TABLE _lastnames (
                        id SERIAL PRIMARY KEY,
                        lastname VARCHAR
);


CREATE TABLE _midnames (
                        id SERIAL PRIMARY KEY,
                        midname VARCHAR
);


INSERT INTO eid_types (eid_type_name)
VALUES
    ('Паспорт РФ'),
    ('Заграничный паспорт РФ'),
    ('Удостоверение беженца'),
    ('Свидетельство о рождении'),
    ('Паспорт иностранного гражданина');

INSERT INTO eed_types (eed_type_name)
VALUES
    ('Аттестат об основном общем образовании'),
    ('Аттестат о среднем общем образовании'),
    ('Аттестат о среднем профессиональном образовании'),
    ('Диплом бакалавра'),
    ('Диплом специалиста'),
    ('Диплом магистра');


CREATE OR REPLACE FUNCTION random_in_range(INTEGER, INTEGER)
    RETURNS INTEGER
AS $$
    SELECT floor(($1 + ($2 - $1 + 1) * random()))::INTEGER;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION random_in_range(BIGINT, BIGINT)
    RETURNS BIGINT
AS $$
    SELECT floor(($1 + ($2 - $1 + 1) * random()))::BIGINT;
$$ LANGUAGE SQL;

CREATE FUNCTION random_date_in_range(DATE, DATE)
    RETURNS DATE
AS $$
    SELECT $1 + floor(($2 - $1 + 1) * random())::INTEGER;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION generate_full_name()
    RETURNS TABLE (
        lastname VARCHAR,
        firstname VARCHAR,
        midname VARCHAR)
AS $$
    BEGIN
        SELECT name INTO firstname FROM _names
        WHERE id = (SELECT random_in_range(1, 207));

        SELECT _midnames.midname INTO midname FROM _midnames
        WHERE id = (SELECT random_in_range(1, 619));

        SELECT _lastnames.lastname INTO lastname FROM _lastnames
        WHERE id = (SELECT random_in_range(1, 1080));

        RETURN NEXT;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION generate_education_document()
    RETURNS TABLE (eed_type SMALLINT,
                   eed_serial VARCHAR,
                   eed_number VARCHAR,
                   eed_issued_by INTEGER,
                   eed_issue_day DATE,
                   eed_original_of_eed BOOLEAN)
AS $$
    BEGIN
        eed_type = 1;
        SELECT random_in_range(1000000, 9999999) INTO eed_number;
        SELECT random_in_range(1, 1290) INTO eed_issued_by;
        SELECT random_date_in_range('2021-01-01', '2022-08-01') INTO eed_issue_day;
        SELECT CAST(random_in_range(0, 1) AS BOOLEAN) INTO eed_original_of_eed;
        RETURN NEXT;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION generate_identity_document()
    RETURNS TABLE (eid_type SMALLINT,
                   eid_serial VARCHAR,
                   eid_number VARCHAR,
                   eid_issued_by INTEGER,
                   eid_issue_day DATE)
AS $$
    BEGIN
        eid_type = 1;
        SELECT random_in_range(1000, 9999) INTO eid_serial;
        SELECT random_in_range(100000, 999999) INTO eid_number;
        SELECT random_in_range(1, 16496) INTO eid_issued_by;
        SELECT random_date_in_range('2017-01-01', '2018-12-31') INTO eid_issue_day;
        RETURN NEXT;
    END;
$$ LANGUAGE plpgsql;

SELECT lastname, firstname, midname, eid_type_name, eid_serial, eid_number, ia_code, ia_name, eid_issue_day FROM generate_full_name(), generate_identity_document()
    JOIN issuing_authorities on eid_issued_by = issuing_authorities.ia_id
    JOIN eid_types on eid_type = eid_types.id;

SELECT eed_type_name, eed_serial, eed_number, io_name, eed_issue_day, eed_original_of_eed FROM generate_education_document()
    JOIN eed_issuing_organizations on eed_issued_by = eed_issuing_organizations.id
    JOIN eed_types on eed_type = eed_types.id;