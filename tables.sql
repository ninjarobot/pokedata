create table if not exists pokemon (
    id serial, 
    identifier varchar(100) not null,
    species_id int not null,
    height int not null,
    weight int not null,
    base_experience int not null,
    "order" int not null,
    is_default boolean not null
);

create table if not exists types (
    id serial,
    identifier varchar(100) not null,
    generation_id int not null,
    damage_class_id int
);

create table if not exists pokemon_types (
    id serial,
    type_id int not null,
    slot int not null
);

create table if not exists pokemon_species (
    id serial,
    identifier varchar(100) not null,
    generation_id int,
    evolves_from_species_id int null,
    evolution_chain_id int,
    color_id int,
    shape_id int,
    habitat_id int,
    gender_rate int,
    capture_rate int,
    base_happiness int,
    is_baby boolean,
    hatch_counter int,
    has_gender_differences boolean,
    growth_rate_id int,
    forms_switchable boolean,
    "order" int,
    conquest_order int null
);

create table if not exists pokemon_shapes (
    id serial,
    identifier varchar(100)
);

create table if not exists pokemon_colors (
    id serial,
    identifier varchar(100)
);
