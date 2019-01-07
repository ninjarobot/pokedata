DB_NAME=pokedata
PWD=$(shell pwd)

all: tables views import

db:
	psql -d postgres -tc "select 1 from pg_database where datname = '$(DB_NAME)'" | grep -q 1 || createdb $(DB_NAME)

dropdb:
	dropdb $(DB_NAME)

clean: dropdb
	rm -f *.csv

tables: db
	psql -d $(DB_NAME) -c "create table if not exists pokemon (id serial, identifier varchar(100) not null, species_id int not null, height int not null, weight int not null, base_experience int not null, \"order\" int not null, is_default boolean not null);"
	psql -d $(DB_NAME) -c "create table if not exists types (id serial, identifier varchar(100) not null, generation_id int not null, damage_class_id int);"
	psql -d $(DB_NAME) -c "create table if not exists pokemon_types (id serial, type_id int not null, slot int not null);"
	psql -d $(DB_NAME) -c "create table if not exists pokemon_species ( \
			id serial, \
			identifier varchar(100) not null,  \
			generation_id int, \
			evolves_from_species_id int null, \
			evolution_chain_id int, \
			color_id int, \
			shape_id int, \
			habitat_id int, \
			gender_rate int, \
			capture_rate int, \
			base_happiness int, \
			is_baby boolean, \
			hatch_counter int, \
			has_gender_differences boolean, \
			growth_rate_id int, \
			forms_switchable boolean, \
			\"order\" int, \
			conquest_order int null \
		);"
	psql -d $(DB_NAME) -c "create table if not exists pokemon_shapes (id serial, identifier varchar(100));"
	psql -d $(DB_NAME) -c "create table if not exists pokemon_colors (id serial, identifier varchar(100));"

views: tables
	psql -d $(DB_NAME) -c "create or replace view pokemon_with_type as \
	select p.id, p.identifier, t.identifier as type, c.identifier as color, s.identifier as shape \
	from pokemon p \
	inner join pokemon_types pt on p.id = pt.id \
	inner join types t on pt.type_id = t.id \
	inner join pokemon_species ps on p.species_id = ps.id \
	inner join pokemon_colors c on ps.color_id = c.id \
	inner join pokemon_shapes s on ps.shape_id = s.id;"

pokemon.csv:
	curl -sSLO https://raw.githubusercontent.com/veekun/pokedex/master/pokedex/data/csv/pokemon.csv

types.csv:
	curl -sSLO https://raw.githubusercontent.com/veekun/pokedex/master/pokedex/data/csv/types.csv

pokemon_types.csv:
	curl -sSLO https://raw.githubusercontent.com/veekun/pokedex/master/pokedex/data/csv/pokemon_types.csv

pokemon_colors.csv:
	curl -sSLO https://raw.githubusercontent.com/veekun/pokedex/master/pokedex/data/csv/pokemon_colors.csv

pokemon_shapes.csv:
	curl -sSLO https://raw.githubusercontent.com/veekun/pokedex/master/pokedex/data/csv/pokemon_shapes.csv

pokemon_species.csv:
	curl -sSLO https://raw.githubusercontent.com/veekun/pokedex/master/pokedex/data/csv/pokemon_species.csv

import: tables views pokemon.csv types.csv pokemon_types.csv pokemon_colors.csv pokemon_shapes.csv pokemon_species.csv
	psql -d $(DB_NAME) -c "copy pokemon from '$(PWD)/pokemon.csv' CSV HEADER;"
	psql -d $(DB_NAME) -c "copy types from '$(PWD)/types.csv' CSV HEADER;"
	psql -d $(DB_NAME) -c "copy pokemon_types from '$(PWD)/pokemon_types.csv' CSV HEADER;"
	psql -d $(DB_NAME) -c "copy pokemon_colors from '$(PWD)/pokemon_colors.csv' CSV HEADER;"
	psql -d $(DB_NAME) -c "copy pokemon_shapes from '$(PWD)/pokemon_shapes.csv' CSV HEADER;"
	psql -d $(DB_NAME) -c "copy pokemon_species from '$(PWD)/pokemon_species.csv' CSV HEADER;"

pokemon: views
	psql -d $(DB_NAME) -c "select id, identifier, array_agg(type) as types, color, shape \
	from pokemon_with_type \
	group by id, identifier, color, shape"

numtypes: views
	psql -d $(DB_NAME) -c "select type, count(type) from pokemon_with_type group by type;"

delete: tables
	psql -d $(DB_NAME) -c "delete from pokemon_types; delete from pokemon; delete from types;"
