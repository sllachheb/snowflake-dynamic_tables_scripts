create or replace view DATATABLES_PROD.PATRIMOINE_CLASSE2.V_EMBASEMENT_NAV(
	NO_PARUTION,
	DATE_PARUTION,
	DATE_DEBUT_SEMAINE,
	DATE_FIN_SEMAINE,
	SEG_ABONNE,
	SOUS_SEG_ABONNE,
	FREQ_VISITES_APP,
	FREQ_VISITES_SITE_MOBILE,
	FREQ_VISITES_DESKTOP,
	FREQ_VISITES_GLOBALE,
	FREQ_VISITES_BOUTIQUE_APP,
	FREQ_VISITES_BOUTIQUE_SITE_MOBILE,
	FREQ_VISITES_BOUTIQUE_DESKTOP,
	FREQ_VISITES_BOUTIQUE_GLOBALE,
	FREQ_VISITES_BOUTIQUE_APP_CONVERTIE,
	FREQ_VISITES_BOUTIQUE_SITE_MOBILE_CONVERTIE,
	FREQ_VISITES_BOUTIQUE_DESKTOP_CONVERTIE,
	FREQ_VISITES_BOUTIQUE_CONVERTIE_GLOBALE
) as
select
    cal.no_parution,
    cal.date_parution,
    cal.date_debut_semaine,
    cal.date_fin_semaine,
    coalesce(seg_abonne,'Hors abonné') as seg_abonne,
    coalesce(sous_seg_abonne,'Anonyme') as sous_seg_abonne,
    --case when v.visite_categorie ilike '%abonné%' then 'Abonnés' else 'Hors abonnés' end as visite_segment,
    --coalesce(type_abo_simplifie,'N/A') as type_abo_simplifie,
   -- case when visite_segment = 'Hors abonnés' then visite_segment else coalesce(segment,'Anonyme') end as segment,
    count_if(visite_support in ('_Mobiles','_Tablettes')) as freq_visites_app,
    count_if(visite_support = 'Site mobile') as freq_visites_site_mobile,
    count_if(visite_support = 'Le Point') as freq_visites_desktop,
    freq_visites_app + freq_visites_site_mobile + freq_visites_desktop as freq_visites_globale,
    count_if(PAGE_ENTREE_CATEGORIE_NIV1 = 'Accueil_Abonnement_V2' and visite_support in ('_Mobiles','_Tablettes')) as freq_visites_boutique_app,
    count_if(PAGE_ENTREE_CATEGORIE_NIV1 = 'Accueil_Abonnement_V2' and visite_support = 'Site mobile') as freq_visites_boutique_site_mobile,
    count_if(PAGE_ENTREE_CATEGORIE_NIV1 = 'Accueil_Abonnement_V2' and visite_support = 'Le Point') as freq_visites_boutique_desktop,
    freq_visites_boutique_app + freq_visites_boutique_site_mobile + freq_visites_boutique_desktop as freq_visites_boutique_globale,
    count_if(PAGE_ENTREE_CATEGORIE_NIV1 = 'Accueil_Abonnement_V2' and visite_support in ('_Mobiles','_Tablettes') and visite_convertie = true) as freq_visites_boutique_app_convertie,
    count_if(PAGE_ENTREE_CATEGORIE_NIV1 = 'Accueil_Abonnement_V2' and visite_support = 'Site mobile' and visite_convertie = true) as freq_visites_boutique_site_mobile_convertie,
    count_if(PAGE_ENTREE_CATEGORIE_NIV1 = 'Accueil_Abonnement_V2' and visite_support = 'Le Point' and visite_convertie = true) as freq_visites_boutique_desktop_convertie,
    freq_visites_boutique_app_convertie + freq_visites_boutique_site_mobile_convertie + freq_visites_boutique_desktop_convertie as freq_visites_boutique_convertie_globale,
    
from datatables_prod.patrimoine_classe2.visites v 
left join datatables_prod.patrimoine_classe2.dt_embasement on compte_id_utilisateur::varchar = replace(v.id_utilisateur,'an_','')::varchar and visite_date between date_debut_semaine and date_fin_semaine
cross join datatables_prod.patrimoine_classe1.v_calendrier_parutions cal
where
v.visite_date between cal.date_debut_semaine and cal.date_fin_semaine
    and cal.flg_hors_serie = 0
 --   and id_utilisateur = '991734'
 --   and visite_date >= current_date - 20
 --   and cal.no_parution in (2694,2695)
group by all
--order by no_parution,seg_abonne,sous_seg_abonne
;
