create or replace view DATATABLES_PROD.PATRIMOINE_CLASSE1.V_TIRAGE_INAPP(
	NO_PARUTION,
	SOURCE,
	NB_EXEMPLAIRES,
	ABO_GRATUIT,
	CATEGORIE,
	SOUS_CATEGORIE,
	ANNEE,
	DATE_FIN_SEMAINE,
	DATE_PARUTION,
	ABO_PAYE_IND,
	TYPE_ABO_SIMPLIFIE,
	CA_HT,
	PU_NUMERO_HT,
	TYPE_DUREE_SIMPLIFIE
) as 
with inapp_inter as (

    select i.*
    ,abonnements_payants - abonnements_gratuits as nb_exemplaires_payant
    ,nb_exemplaires_payant - installations_payees as stock_payant
    ,round(estimation_ca_ht * (stock_payant / nb_exemplaires_payant),3) as ca_ht_stock
    ,round(estimation_ca_ht - ca_ht_stock,3) as ca_ht_acquisition
    ,1 as abo_paye_ind
    ,'NUM' as type_abo_simplifie
    ,'DL' as type_duree_simplifie
    ,c.cal_au as date_parution
    ,dateadd(week,1,date_parution) - 1 as date_fin_semaine
    ,year(c.cal_au) as annee
    ,round(pu_moyen,3) as pu_numero_ht
    from rawdata_prod.referentiel.ref_inapp i
    inner join RAWDATA_PROD.ABOWEB.T_CALENDRIERS c on c.no_parution = i.no_parution and c.ref_titre = 1

)


select *
from (

-- ACQUISITION
select
     no_parution
    ,source
    ,installations_payees as nb_exemplaires
    ,0 as abo_gratuit
    ,'ACQUISITION' as categorie
    ,'INAPP' as sous_categorie
    ,annee
    ,date_fin_semaine
    ,date_parution
    ,abo_paye_ind
    ,type_abo_simplifie
    ,ca_ht_acquisition as ca_ht
    ,pu_numero_ht
    ,type_duree_simplifie
from inapp_inter

union all

-- STOCK PAYANT
select
     no_parution
    ,source
    ,case when source = 'GOOGLE' then abonnements_payants - installations_payees
      when source = 'APPLE' then abonnements_payants - (abonnements_gratuits + installations_payees) end  as nb_exemplaires
    ,0 as abo_gratuit
    ,'STOCK' as categorie
    ,'STOCK' as sous_categorie
    ,annee
    ,date_fin_semaine
    ,date_parution
    ,abo_paye_ind
    ,type_abo_simplifie
    ,ca_ht_stock as ca_ht
    ,pu_numero_ht
    ,type_duree_simplifie
from inapp_inter


union all

-- STOCK GRATUIT
select
     no_parution
    ,source
    ,abonnements_gratuits as nb_exemplaires
    ,1 as abo_gratuit
    ,'STOCK' as categorie
    ,'STOCK' as sous_categorie
    ,annee
    ,date_fin_semaine
    ,date_parution
    ,abo_paye_ind
    ,type_abo_simplifie
    ,0 as ca_ht
    ,pu_numero_ht
    ,type_duree_simplifie
from inapp_inter
where 
    source = 'APPLE'


)inapp_final;
