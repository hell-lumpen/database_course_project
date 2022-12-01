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

CREATE OR REPLACE FUNCTION random_gender()
    RETURNS CHAR
AS $$
    DECLARE
        gender_set VARCHAR = 'ММЖ';
    BEGIN
        RETURN substring(gender_set from random_in_range(1, 3) for 1);
    END;
$$ LANGUAGE plpgsql;


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


CREATE OR REPLACE FUNCTION generate_email()
    RETURNS VARCHAR
AS $$
    DECLARE
        email_len SMALLINT;
        email VARCHAR = '';
        domain VARCHAR = '@mai.edu';
        alphabet VARCHAR = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789';
    BEGIN
        email_len = (SELECT random_in_range(5, 20));
        WHILE length(email) < email_len LOOP
            email = concat(email, substring(alphabet from random_in_range(1, 61) for 1));
        END LOOP;
        RETURN concat(email, domain);
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION generate_entrant_identity_documents(size INTEGER)
RETURNS VOID
AS $$
    DECLARE
        i INTEGER = 0;
    BEGIN
        WHILE i < size LOOP
            INSERT INTO entrant_identity_documents (eid_type, eid_serial, eid_number, eid_issued_by, eid_issue_day)
            VALUES (
                    1,
                    random_in_range(1000, 9999),
                    random_in_range(100000, 999999),
                    random_in_range(1, 16496),
                    random_date_in_range('2017-01-01', '2018-12-31')
                   );
            i = i + 1;
            END LOOP;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION generate_entrant_education_documents(size INTEGER)
RETURNS VOID
AS $$
    DECLARE
        i INTEGER = 0;
    BEGIN
        WHILE i < size LOOP
            INSERT INTO entrant_education_documents (eed_type, eed_serial, eed_number, eed_issued_by, eed_issue_day, eed_original_of_eed)
            VALUES (
                    1,
                    NULL,
                    random_in_range(10000000, 99999999),
                    random_in_range(1, 1290),
                    random_date_in_range('2021-01-01', '2022-08-01'),
                    CAST(random_in_range(0, 1) AS BOOLEAN)
                   );
            i = i + 1;
            END LOOP;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION generate_entrants(size INTEGER)
RETURNS VOID
AS $$
    DECLARE
        i INTEGER = 1;
    BEGIN
        WHILE i <= size LOOP
            INSERT INTO entrants (e_first_name,
                                  e_mid_name,
                                  e_last_name,
                                  e_gender,
                                  e_birthday,
                                  e_email,
                                  e_mobile_phone,
                                  e_identity_document_id,
                                  e_education_document_id)
            VALUES (
                    (SELECT name FROM _names
                    WHERE id = (SELECT random_in_range(1, 207))),
                    (SELECT midname FROM _midnames
                    WHERE id = (SELECT random_in_range(1, 619))),
                    (SELECT lastname FROM _lastnames
                    WHERE id = (SELECT random_in_range(1, 1080))),
                    random_gender(),
                    random_date_in_range('2002-01-01', '2004-12-31'),
                    generate_email(),
                    '+74991584977',
                    i,
                    i
                   );
            i = i + 1;
            END LOOP;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION generate_entrant_data(size INTEGER)
RETURNS VOID
AS $$
    BEGIN
        truncate table entrants restart identity cascade;
        truncate table entrant_identity_documents restart identity cascade;
        truncate table entrant_education_documents restart identity cascade;
        PERFORM generate_entrant_education_documents(size);
        PERFORM generate_entrant_identity_documents(size);
        PERFORM generate_entrants(size);
    END;
$$ LANGUAGE plpgsql;

SELECT generate_entrant_data(10000);


CREATE OR REPLACE VIEW v_entrants AS
SELECT e_last_name, e_first_name, e_mid_name, e_gender, e_birthday, e_email, e_mobile_phone, eid_type_name, eid_serial, eid_number, ia_code, ia_name, eid_issue_day, eed_type_name, eed_serial, eed_number, eed_issue_day, io_name, eed_original_of_eed
FROM entrants
    JOIN entrant_education_documents eed on eed.eed_id = entrants.e_education_document_id
    JOIN entrant_identity_documents eid on eid.eid_id = entrants.e_identity_document_id
    JOIN eed_issuing_organizations eio on eio.id = eed.eed_issued_by
    JOIN eed_types et on et.id = eed.eed_type
    JOIN eid_types e on e.id = eid.eid_type
    JOIN issuing_authorities ia on ia.ia_id = eid.eid_issued_by;