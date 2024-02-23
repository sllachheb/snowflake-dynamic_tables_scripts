create or replace view DATATABLES_PROD.PATRIMOINE_CLASSE1.DT_PAR_MODES_PAIEMENT_CORRIGES(
	CODE_CLIENT,
	REF_ABONNEMENT,
	NO_PARUTION,
	CODE_TARIF,
	MODE_PAIEMENT_ORIGINAL,
	MODE_PAIEMENT_CORRIGE,
	ERREUR_DE_TYPE,
	FORMULE_TYPE_ABONNEMENT,
	FORMULE_ZONE_GEOGRAPHIQUE,
	FORMULE_MONTANT_ABONNEMENT,
	FORMULE_DUREE_ABONNEMENT,
	FORMULE_TYPE_DUREE,
	FORMULE_MODE_PAIEMENT,
	ABO_PAYE_IND,
	ABO_GRANDE_ECOLE,
	ABO_PARTENAIRES,
	ABO_POINT_COM,
	ABO_GRATUIT,
	ABO_GRACE_COPIE
) as

SELECT
code_client
,ref_abonnement
,no_parution
,code_tarif
,mode_paiement as mode_paiement_original
,mode_paiement_corrige
,erreur_de_type
,split_part(trim(code_tarif), '-', 1) as formule_type_abonnement
,split_part(split_part(trim(code_tarif), '-', 2), '-', -1) as formule_zone_geographique
,split_part(split_part(trim(code_tarif), '-', 3), '-', -1) as formule_montant_abonnement
,split_part(split_part(trim(code_tarif), '-', 4), '-', -1) as formule_duree_abonnement
,split_part(split_part(trim(code_tarif), '-', 5), '-', -1) as formule_type_duree
,split_part(split_part(trim(code_tarif), '-', 6), '-', -1) as formule_mode_paiement
,case when coalesce(formule_montant_abonnement,0) != 0 and not(upper(code_tarif) like any ('%PAR%','%TG7%')) 
    and not (mode_paiement_corrige in ('POINT DEV','PARTENAIRES','DC','POINT COM') or mode_paiement_corrige is null) then 1 else 0 
    end as abo_paye_ind
,case when mode_paiement_corrige = 'POINT DEV' then 1 else 0 
    end abo_grande_ecole
,case when coalesce(mode_paiement_corrige,'') in ('PARTENAIRES','DC') or upper(code_tarif) like any ('%PAR%','%TG7%') then 1 else 0 
    end as abo_partenaires
,case when coalesce(mode_paiement_corrige,'') = 'POINT COM' or coalesce(lib_version,'') = 'I80' then 1 else 0 end as abo_point_com
,case when formule_montant_abonnement = 0 and formule_montant_abonnement is not null then 1 else 0 end as abo_gratuit
,flag_grace_copie as abo_grace_copie

FROM (
SELECT 
    a.code_client
    ,a.ref_abonnement
    ,a.no_parution
    ,cp.mode_paiement
    ,tf.code_tarif
    ,case when tf.code_tarif = 'NUM-FR-110-1-DL-0' and coalesce(cp.mode_paiement,'') != 'POINT DEV' then 1
          when tf.code_tarif = 'NUM-FR-1300-13-DD-0' and coalesce(cp.mode_paiement, '') != 'PARTENAIRES' then 2
          when tf.code_tarif = 'NUM-FR-1950-13-DD-0-PAR' and coalesce(cp.mode_paiement,'') != 'PARTENAIRES' then 3 
    end as erreur_de_type
    ,case when coalesce(erreur_de_type,0) = 1 then 'POINT DEV'
          when coalesce(erreur_de_type,0) in (2,3) then 'PARTENAIRES'
          else cp.mode_paiement 
    end as mode_paiement_corrige
    ,vf.lib_version
    ,case when coalesce(upper(paygcpgrt),'') = 'GRÂCE COPIE' then 1 else 0 end as flag_grace_copie 
FROM RAWDATA_PROD.BI_ABOWEB.F_HISTO_ABONNEMENTS_EN_ACTIVITE a
LEFT JOIN RAWDATA_PROD.BI_ABOWEB.D_CANALPAIEMENT cp on a.ref_abonnement = cp.ref_abonnement
LEFT JOIN RAWDATA_PROD.BI_ABOWEB.D_TARIFSETFORMULES tf on tf.ref_tarif = a.ref_groupe
LEFT JOIN RAWDATA_PROD.BI_ABOWEB.D_VERSIONSFORMATS vf on vf.ref_versionformat = a.ref_versionformat
GROUP BY ALL
) TAB;
