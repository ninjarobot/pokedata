pokedata
========

A Postgres database of pokemon from importing CSV pokedex.

Getting Started
---------------
Supports macOS and Linux.

Install Postgres locally and ensure your user has rights to create a database.

Install `make`.

Run `make all` - this creates the tables and views, then downloads and imports the data.  After that, connect with `psql -d pokedata` and query the pokedex data.

```
pokedata=# select id, identifier, array_agg(type) as types, color, shape from pokemon_with_type group by id, identifier, color, shape;
  id   |       identifier        |       types        | color  |   shape   
-------+-------------------------+--------------------+--------+-----------
     1 | bulbasaur               | {grass,poison}     | green  | quadruped
     2 | ivysaur                 | {grass,poison}     | green  | quadruped
     3 | venusaur                | {grass,poison}     | green  | quadruped
     4 | charmander              | {fire}             | red    | upright
     5 | charmeleon              | {fire}             | red    | upright
...
```
