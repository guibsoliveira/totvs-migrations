-- export.saluno2 fonte

CREATE OR REPLACE VIEW export.saluno2
AS SELECT DISTINCT ON (er.id_person) pf.name::character varying(120) AS nome,
    NULL::text AS sobrenome,
    COALESCE(pf.birthdate::date, '0001-01-01'::date) AS dtnascimento,
    pf.cpf,
    pf.rg AS cartidentidade,
    pf.rg_issuing_state AS ufcartident,
    NULL::text AS carteiratrab,
    NULL::text AS seriecarttrab,
    NULL::text AS ufcarttrab,
    NULL::text AS empresanome,
    NULL::text AS empresarua,
    NULL::text AS empresanumero,
    NULL::text AS empresacomplemento,
    NULL::text AS empresabairro,
    NULL::text AS empresacep,
    NULL::text AS empresacidade,
    NULL::text AS empresauf,
    NULL::text AS empresatelefone,
    NULL::text AS empresahorario,
    NULL::text AS tipocertidao,
    NULL::text AS certnumero,
    NULL::text AS certcartorio,
    NULL::text AS certcomarca,
    NULL::date AS certdata,
    NULL::text AS certfolha,
    NULL::text AS certlivro,
    NULL::text AS certdistrito,
    NULL::text AS certuf,
    pf_pai.name AS nomepai,
    pf_pai.birthdate::date AS dtnascimentopai,
    pf_pai.cpf AS cpfpai,
    pf_pai.rg AS rgpai,
    pf_mae.name AS nomemae,
    pf_mae.birthdate::date AS dtnascimentomae,
    pf_mae.cpf AS cpfmae,
    pf_mae.rg AS rgmae,
    1 AS codcoligada,
    scu.code_unif::text AS ra,
    NULL::text AS tipoaluno,
    NULL::text AS instdestino,
    NULL::text AS instorigem,
    NULL::text AS codcurhist,
    NULL::text AS codseriehist,
        CASE
            WHEN (( SELECT cf.codcfo::text AS codcfo
               FROM gennera_stg.cliente_fornecedor cf
                 JOIN gennera_stg.person_fisica pf_fin ON pf_fin.cpf = cf.cgccfo::text
              WHERE pf_fin.id_person = e.id_financial_responsible
             LIMIT 1)) IS NOT NULL THEN '1'::text
            WHEN (( SELECT cf.codcfo::text AS codcfo
               FROM gennera_stg.cliente_fornecedor cf
                 JOIN gennera_stg.person_fisica pf_fin ON pf_fin.id_person = e.id_financial_responsible
              WHERE cf.nomefantasia::text ~~* pf_fin.name
             LIMIT 1)) IS NOT NULL THEN '1'::text
            ELSE NULL::text
        END AS codcolcfo,
    lpad(COALESCE(( SELECT cf.codcfo::text AS codcfo
           FROM gennera_stg.cliente_fornecedor cf
             JOIN gennera_stg.person_fisica pf_fin ON pf_fin.cpf = cf.cgccfo::text
          WHERE pf_fin.id_person = e.id_financial_responsible
         LIMIT 1), ( SELECT cf.codcfo::text AS codcfo
           FROM gennera_stg.cliente_fornecedor cf
             JOIN gennera_stg.person_fisica pf_fin ON pf_fin.id_person = e.id_financial_responsible
          WHERE cf.nomefantasia::text ~~* pf_fin.name
         LIMIT 1), NULL::text), 6, '0'::text) AS codcfo,
    NULL::text AS codparentcfo,
    pf_acad.name AS nomerespacad,
    pf_acad.birthdate::date AS dtnascimentorespacad,
    pf_acad.cpf AS cpfrespacad,
    pf_acad.rg AS rgrespacad,
    NULL::text AS codparentraca,
    NULL::text AS obshist,
    NULL::text AS identificador2,
    NULL::text AS identificador3,
    NULL::text AS anoingresso,
    NULL::text AS anotacoes,
    1 AS codtipocurso,
    NULL::integer AS codinstorigem,
    NULL::integer AS codinstdestino,
    'São Paulo'::text AS naturalidade,
    'SP'::text AS estadonatal,
    NULL::text AS naturalidadepai,
    NULL::text AS estadonatalpai,
    NULL::text AS naturalidademae,
    NULL::text AS estadonatalmae,
    'Não Informado'::text AS naturalidadeacad,
    '--'::text AS estadonatalacad,
    NULL::text AS codsistec,
    NULL::integer AS codinst2grau,
    NULL::text AS grauultimainst,
    NULL::text AS anoultimainst,
    NULL::integer AS codetnia
   FROM gennera_stg.enrollment_record er
     LEFT JOIN gennera_stg.person_fisica pf ON pf.id_person = er.id_person
     LEFT JOIN gennera_stg.student_code_unico scu ON scu.id_person = er.id_person
     LEFT JOIN LATERAL ( SELECT e1.id_enrollment,
            e1.id_institution,
            e1.id_parent_enrollment,
            e1.id_person,
            e1.id_academic_responsible,
            e1.id_financial_responsible,
            e1.cod_col,
            e1.code,
            e1.status,
            e1.date,
            e1.campaign_name,
            e1.academic_calendar,
            e1.curriculum_name,
            e1.course_name,
            e1.module_name,
            e1.class_name,
            e1.cancellation_reason,
            e1.blocked
           FROM gennera_stg.enrollment e1
          WHERE e1.id_person = er.id_person AND e1.id_institution <> 3
          ORDER BY (e1.id_financial_responsible IS NULL), (e1.academic_calendar::integer) DESC
         LIMIT 1) e ON true
     LEFT JOIN ( SELECT DISTINCT ON (r.id_target) r.id_target,
            r.id_owner
           FROM gennera_stg.relationship r
          WHERE r.type = 'FATHER'::text
          ORDER BY r.id_target, r.id_owner) rel_pai ON rel_pai.id_target = er.id_person
     LEFT JOIN gennera_stg.person_fisica pf_pai ON pf_pai.id_person = rel_pai.id_owner
     LEFT JOIN ( SELECT DISTINCT ON (r.id_target) r.id_target,
            r.id_owner
           FROM gennera_stg.relationship r
          WHERE r.type = 'MOTHER'::text
          ORDER BY r.id_target, r.id_owner) rel_mae ON rel_mae.id_target = er.id_person
     LEFT JOIN gennera_stg.person_fisica pf_mae ON pf_mae.id_person = rel_mae.id_owner
     LEFT JOIN gennera_stg.person_fisica pf_acad ON pf_acad.id_person = e.id_academic_responsible
  ORDER BY er.id_person;