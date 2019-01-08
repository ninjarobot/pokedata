
create or replace view pokemon_with_type as
	select p.id, p.identifier, t.identifier as type, c.identifier as color, s.identifier as shape
	from pokemon p
	inner join pokemon_types pt on p.id = pt.id
	inner join types t on pt.type_id = t.id
	inner join pokemon_species ps on p.species_id = ps.id
	inner join pokemon_colors c on ps.color_id = c.id
	inner join pokemon_shapes s on ps.shape_id = s.id;
