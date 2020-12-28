create database db_herit

go
use db_herit

-- create tables

-- person
create table t_person
(
    id int not null,
    nom varchar(50) not null,
    prenom varchar(50) not null,
    sexe varchar(10),
    primary key clustered
    (
        id
    )
)

-- provider
create table t_agent
(
    id int references t_person(id),
    adresse text,
    primary key clustered
    (
        id
    )
)

-- provider
create table t_user
(
    id int references t_person(id),
    username varchar(255) not null,
    pwd varchar(25) not null,
    primary key clustered
    (
        id
    )
)


-- 


-- stored procedure

go
create procedure sp_update_person
(
    @id int,
    @nom varchar(50),
    @prenom varchar(50),
    @sexe varchar(10),
    @adresse text,
    @username varchar(255),
    @pwd varchar(25),
    -- we use a bit variable
    @type bit
)
as
begin
    declare @test bit = 0

    if not exists(select * from t_person where id = @id)
        begin
            insert into t_person values(@id, @nom, @prenom, @sexe)
            set @test = 1
        end
    else
        update t_person set nom = @nom, prenom = @prenom, sexe = @sexe where id = @id
    
    -- use the test
    if @test = 1
        begin
            if @type = 0
                insert into t_agent values (@id, @adresse)
            else
                insert into t_user values(@id, @username, @pwd)
        end
    
    begin transaction
    commit
end

exec sp_update_person 1, 'Venceslas', 'josh', 'homme', '', 'bvenceslas','bvenceslas', 1
exec sp_update_person 2, 'G', 'Audi', 'femme', '14, Himbi av. du musée', '','', 0

-- data from person 
select p.id, p.nom, p.prenom, p.sexe, 'AGENT' as category
    from t_person p, t_agent a
        where p.id = a.id

union all

select p.id, p.nom, p.prenom, p.sexe, 'USER' as category
    from t_person p, t_user u
        where p.id = u.id


-- use the merge syntax
create table t_book
(
    id int not null,
    title varchar(255) not null,
    nb_page int,
    book_state text,
    primary key clustered
    (
        id
    )
)

go
create procedure sp_update_book
(
    @id int,
    @title varchar(255),
    @nb_page int,
    @book_state text
)
as
begin
    merge into t_book using(values(@id, @title, @nb_page, @book_state)) as buku(a, b, c, d) on t_book.id = buku.a
    
    when matched then
        update set title = @title, nb_page = @nb_page, book_state = @book_state
    when not matched then
        insert values (a, b, c, d);
end

execute sp_update_book 1, 'Josh et la vie spirituelle', 900,'new'
select * from t_book