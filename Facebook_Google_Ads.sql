CREATE MATERIALIZED VIEW facebook_google_ads AS
WITH joined_facebook_data AS (
	SELECT
		ad_date, url_parameters,
		spend, impressions, reach, clicks, leads, value,
		adset_name
	FROM
		facebook_ads_basic_daily f
	LEFT JOIN
		facebook_campaign c ON f.campaign_id = c.campaign_id
	LEFT JOIN
		facebook_adset a ON f.adset_id = a.adset_id
),
combined_ads_data AS (
	SELECT
		ad_date,
		url_parameters,
		'facebook' AS media_source,
		adset_name,
		COALESCE(spend, 0) AS spend,
		COALESCE(impressions, 0) AS impressions,
		COALESCE(reach, 0) AS reach,
		COALESCE(clicks, 0) AS clicks,
		COALESCE(leads, 0) AS leads,
		COALESCE(value, 0) AS value
	FROM
		joined_facebook_data
	UNION ALL
	SELECT
		ad_date,
		url_parameters,
		'google' AS media_source,
		adset_name,
		COALESCE(spend, 0) AS spend,
		COALESCE(impressions, 0) AS impressions,
		COALESCE(reach, 0) AS reach,
		COALESCE(clicks, 0) AS clicks,
		COALESCE(leads, 0) AS leads,
		COALESCE(value, 0) AS value
	FROM
		google_ads_basic_daily
),
combined_ads_month AS (
	SELECT
		DATE(DATE_TRUNC('month', ad_date)) AS ad_month,
		media_source,
		CASE 
			WHEN url_parameters LIKE '%utm_campaign=nan%' THEN NULL
			ELSE SUBSTRING(url_parameters FROM 'utm_campaign=([a-z0-9_]+)')
		END AS utm_campaign,
		adset_name,
		SUM(spend) AS total_spend,
		SUM(impressions) AS total_impressions,
		SUM(clicks) AS total_clicks,
		SUM(value) AS total_value,
		CASE
			WHEN SUM(clicks) = 0 THEN 0
			ELSE ROUND(CAST(SUM(spend) * 1.0 / SUM(clicks) AS numeric), 2)
		END AS cpc,
		CASE
			WHEN SUM(impressions) = 0 THEN 0
			ELSE ROUND(CAST(SUM(spend) * 1.0 / SUM(impressions) * 1000 AS numeric), 2)
		END AS cpm,
		CASE
			WHEN SUM(impressions) = 0 THEN 0
			ELSE ROUND(CAST(SUM(clicks) * 1.0 / SUM(impressions) * 100 AS numeric), 2)
		END AS ctr,
		CASE
			WHEN SUM(spend) = 0 THEN 0
			ELSE ROUND(CAST((SUM(value) - SUM(spend)) * 1.0 / SUM(spend) * 100 AS numeric), 2)
		END AS romi
	FROM
		combined_ads_data
	GROUP BY
		ad_month,
		utm_campaign,
		adset_name,
		media_source
)
SELECT
	ad_month,
	utm_campaign,
	media_source,
	adset_name,
	total_spend,
	total_impressions,
	total_clicks,
	total_value,
	ctr,
	cpc,
	cpm,
	romi,
	ROUND(CAST((ctr / LAG(ctr) OVER (PARTITION BY utm_campaign, adset_name, media_source ORDER BY ad_month)) * 100 - 100 AS numeric), 2) AS ctr_mom_growth_rate,
	ROUND(CAST((cpm / LAG(cpm) OVER (PARTITION BY utm_campaign, adset_name, media_source ORDER BY ad_month)) * 100 - 100 AS numeric), 2) AS cpm_mom_growth_rate,
	ROUND(CAST((romi / LAG(romi) OVER (PARTITION BY utm_campaign, adset_name, media_source ORDER BY ad_month)) * 100 - 100 AS numeric), 2) AS romi_mom_growth_rate	
FROM
	combined_ads_month
ORDER BY
	utm_campaign,
	adset_name,
	ad_month,
	media_source;