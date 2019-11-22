with records as (
	select 
		occurrence.id,
		(aphia.classification->>'speciesid')::int as speciesid,
		case
			when aphia.classification->>'classid' = '1837' then 'mammalia'
			when aphia.classification->>'classid' = '1836' then 'aves'
			when aphia.classification->>'classid' = '10194' then 'actinopterygii'
			when aphia.classification->>'classid' = '1071' then 'malacostraca'
			when aphia.classification->>'classid' = '101' then 'gastropoda'
			when aphia.classification->>'classid' = '10193' then 'elasmobranchii'
			when aphia.classification->>'phylumid' = '1267' then 'cnidaria'
			when aphia.classification->>'phylumid' = '882' then 'annelida'
			when aphia.classification->>'classid' = '1838' then 'reptilia'
			when aphia.classification->>'classid' = '1300' then 'arachnida'
			else null
		end as gr
		from occurrence
	left join aphia on occurrence.aphia = aphia.id
	where dropped is not true and absence is not true
	and aphia.classification->>'speciesid' is not null
)
select speciesid, gr, count(*) from records
group by speciesid, gr;
