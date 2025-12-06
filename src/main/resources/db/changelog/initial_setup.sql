create schema USER_SCHEMA;
create table USER_SCHEMA.USERS (
    id bigint not null,
    name varchar(255) not null,
    primary key (id)
);
