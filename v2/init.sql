-- create user openresty with password 'speedtheweb';
-- grant all privileges on database openresty_org to openresty;
-- create database openresty_org;

drop table if exists posts cascade;

create table posts (
    id serial primary key,
    title text not null,
    html_body text not null,
    creator varchar(32) not null,
    created timestamp with time zone not null,
    modifier varchar(32) not null,
    modified timestamp with time zone not null,
    changes int not null,
    textsearch_index_col tsvector
);

\copy posts (title, html_body, creator, created, modifier, modified, changes) from 'posts.tsv'

drop function if exists posts_trigger() cascade;

create function posts_trigger() returns trigger as $$
begin
      new.textsearch_index_col :=
         setweight(to_tsvector('pg_catalog.english', coalesce(new.title,'')), 'A')
         || setweight(to_tsvector('pg_catalog.english', coalesce(new.html_body,'')), 'D');
      return new;
end
$$ language plpgsql;

create trigger tsvectorupdate before insert or update
    on posts for each row execute procedure posts_trigger();

create index textsearch_idx on posts using gin(textsearch_index_col);

update posts set title = title;
