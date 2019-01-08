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
	psql -a -d $(DB_NAME) -f tables.sql

views: tables
	psql -a -d $(DB_NAME) -f views.sql

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
