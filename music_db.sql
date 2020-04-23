drop table podobne_albumy
drop table podobne_utwory
drop table utwor_playlista
drop table przeboje
drop table playlista
drop table utwor
drop table album
drop table gatunek
drop table wykonawca
drop procedure dodaj_album
drop procedure dodaj_gatunek
drop procedure dodaj_playliste
drop procedure dodaj_podobne_albumy
drop procedure dodaj_podobne_utwory
drop procedure dodaj_przeboj
drop procedure dodaj_utwor
drop procedure dodaj_utwor_i_przeboj
drop procedure dodaj_wykonawce
drop procedure dodaj_wykonawce_i_album
drop procedure zmien_gatunek_albumu
drop procedure zmien_nazwe_zespolu
drop procedure zmien_opis_gatunku
drop procedure zmien_przeboje
drop procedure usun_utwor_na_playliscie
drop procedure usun_playliste
drop trigger autonumerowanie
drop trigger dodajpodobneutwory
drop trigger dodajpodobnealbumy
drop trigger numerowaniealbum
create table wykonawca ( id int identity constraint PK_wykonawca primary key, nazwa
varchar(40) not null, kraj varchar(40) not null, rok_zalozenia int not null )
create table gatunek ( id int identity not null constraint PK_gatunek primary key ,gatunek
varchar(40) not null ,opis varchar(100) null )
create table album ( id int identity not null constraint PK_album primary key, nazwa
varchar(40) not null, id_wykonawcy int not null constraint FK_album_wykonawca foreign key
references wykonawca(id), rok_wydania int not null, id_gatunek int not null constraint
FK_album_gatunek foreign key references gatunek(id), l_utworow int not null default 0 )
create table utwor ( id int identity constraint PK_utwor primary key, nazwa varchar(40) not
null, id_albumu int not null constraint FK_utwor_album foreign key references album(id),
dlugosc time not null, nr_w_albumie int not null )
create table playlista ( id int identity not null constraint PK_playlista primary key, nazwa
varchar(40) not null )

create table utwor_playlista ( id int identity constraint PK_utwor_playlista primary key,
id_playlista int constraint FK_playlista foreign key references playlista(id),
id_utwor int not null constraint FK_utwor foreign key references utwor(id), nr_na_liscie int )
create table przeboje ( id int identity constraint PK_przeboje primary key, id_utworu int
constraint FK_przeboje_utwor foreign key references utwor(id), ocena int null, nr_na_liscie
int null, opis varchar(100) null, rok int null )
create table podobne_albumy ( id int identity constraint PK_podobne_albumy primary key,
id1 int not null constraint FK_podobne_albumy_album1 foreign key references album(id), id2
int not null constraint FK_podobne_albumy_album2 foreign key references album(id))
create table podobne_utwory ( id int identity constraint PK_podobne_utwory primary key, id1
int not null constraint FK_podobne_utwory_utwor1 foreign key references utwor(id), id2 int
not null constraint FK_podobne_utwory_utwor2 foreign key references utwor(id))
go
create procedure dodaj_wykonawce @nazwa varchar(40), @kraj
varchar(40),@rok_zalozenia int
as
insert into wykonawca ( nazwa ,kraj ,rok_zalozenia) values ( @nazwa , @kraj ,
@rok_zalozenia)
select * from wykonawca where id=SCOPE_IDENTITY()
go
create procedure dodaj_album @nazwa varchar(40), @wykonawca varchar(40),
@rok_wydania int, @gatunek varchar(40)
as
insert into album ( nazwa ,id_wykonawcy ,rok_wydania ,id_gatunek )
values ( @nazwa , (select ID from wykonawca where nazwa like @wykonawca)
,@rok_wydania ,(select ID from gatunek where gatunek = @gatunek))
select * from album where id=SCOPE_IDENTITY()
go
create procedure dodaj_utwor @nazwa varchar(40), @album varchar(40),@dlugosc time,
@nr_w_albumie int as insert into utwor ( nazwa ,id_albumu ,dlugosc ,nr_w_albumie) values
( @nazwa ,(select ID from album where nazwa like @album) ,@dlugosc ,@nr_w_albumie)
select * from utwor where id=SCOPE_IDENTITY()
update album set l_utworow = l_utworow +1 where nazwa like @album
go
create procedure dodaj_przeboj @utwor varchar(40),@ocena int=null, @nr_na_liscie
int=null,@opis varchar(100)=null,@rok int=null as insert into przeboje ( id_utworu ,ocena
,nr_na_liscie ,opis,rok) values ( (select id from utwor where nazwa like @utwor) ,@ocena
,@nr_na_liscie ,@opis ,@rok)
select * from przeboje where id=SCOPE_IDENTITY()
go

create procedure dodaj_gatunek @gatunek varchar(40),@opis varchar(100)=null as insert
into gatunek ( gatunek ,opis) values ( @gatunek ,@opis)
select * from gatunek where id=SCOPE_IDENTITY()
go
create procedure dodaj_podobne_albumy @album1 varchar(40),@album2 varchar(40) as
insert into podobne_albumy ( id1 ,id2) values ( (select ID from album where nazwa like
@album1) ,(select ID from album where nazwa like @album2))
select * from podobne_albumy where id=SCOPE_IDENTITY()
go
create procedure dodaj_podobne_utwory @utwor1 varchar(40),@utwor2 varchar(40) as
insert into podobne_albumy ( id1 ,id2) values (
(select ID from utwor where nazwa like @utwor1) ,(select ID from utwor where nazwa like
@utwor2))
select * from podobne_utwory where id=SCOPE_IDENTITY()
go
create procedure dodaj_playliste @nazwa varchar(40),@nazwa_utworu varchar(40)
as
if(@nazwa not in (select nazwa from playlista))
begin
insert into playlista (nazwa) values (@nazwa)
insert into utwor_playlista (id_playlista,id_utwor,nr_na_liscie)
values ( SCOPE_IDENTITY() ,(select ID from utwor where nazwa = @nazwa_utworu) ,1 )
end
else
insert into utwor_playlista (id_playlista,id_utwor,nr_na_liscie)
values ( (select id from playlista where nazwa =@nazwa) ,(select id from utwor where
nazwa =@nazwa_utworu) ,((select MAX(u.nr_na_liscie) from utwor_playlista u join playlista
p on p.id=u.id_playlista where p.nazwa like @nazwa)+1) )
select * from utwor_playlista u join playlista p on p.id=u.id_playlista where u.id like
SCOPE_IDENTITY()
go
create procedure usun_utwor_na_playliscie @nazwa varchar(40),@nazwa_utworu
varchar(40)
as
delete from utwor_playlista where id_utwor=(select id from utwor where nazwa =
@nazwa_utworu ) and id_playlista = (select id from playlista where nazwa=@nazwa)
go
create procedure usun_playliste @nazwa varchar(40)
as
delete from utwor_playlista where id_playlista = (select id from playlista where
nazwa=@nazwa)
delete from playlista where nazwa = @nazwa
go

create procedure zmien_opis_gatunku @gatunek varchar(40),@opis varchar(100) as update
gatunek set opis = @opis where gatunek = @gatunek select * from gatunek where
id=SCOPE_IDENTITY()
go
create procedure zmien_nazwe_zespolu @nazwa_przed varchar(40),@nazwa_po
varchar(40) as update wykonawca set nazwa = @nazwa_po where nazwa = @nazwa_przed
select * from wykonawca where id=SCOPE_IDENTITY()
go
create procedure zmien_gatunek_albumu @nazwa_albumu varchar(40),@gatunek
varchar(40) as update album set id_gatunek =(select id from gatunek where gatunek=
@gatunek) where nazwa = @nazwa_albumu select * from album where
id=SCOPE_IDENTITY()
go
create procedure zmien_przeboje @id int, @ocena int=null,@nr_na_liscie int=null,@opis
varchar(100)=null,@rok int=null
as if(@ocena is not null) update przeboje set ocena=@ocena where id=@id if(@nr_na_liscie
is not null) update przeboje set nr_na_liscie=@nr_na_liscie where id=@id if(@opis is not
null)
update przeboje set opis=@opis where id=@id if(@rok is not null) update przeboje set
rok=@rok where id=@id select * from przeboje where id=SCOPE_IDENTITY()
go
create procedure dodaj_wykonawce_i_album @nazwa_wykonawcy varchar(40), @kraj
varchar(40), @rok_zalozenia int, @nazwa_albumu varchar(40), @rok_wydania int,
@nazwa_gatunku varchar(40) as insert into wykonawca (nazwa,kraj,rok_zalozenia) values (
@nazwa_wykonawcy, @kraj, @rok_zalozenia) insert into album
(nazwa,id_wykonawcy,rok_wydania,id_gatunek) values ( @nazwa_albumu,
SCOPE_IDENTITY(), @rok_wydania, (select id from gatunek where gatunek=
@nazwa_gatunku) )
select * from album a join wykonawca w on w.id=a.id_wykonawcy where
a.id=SCOPE_IDENTITY()
go
create procedure dodaj_utwor_i_przeboj @nazwa varchar(40), @nazwa_albumu
varchar(40), @dlugosc time, @nr_w_albumie int
as insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values ( @nazwa, (select id
from album where nazwa = @nazwa_albumu), @dlugosc, @nr_w_albumie) update album
set l_utworow = l_utworow +1 where nazwa like @nazwa_albumu insert into przeboje
(id_utworu) values (SCOPE_IDENTITY())
select * from utwor u join przeboje p on u.id=p.id_utworu where p.id=SCOPE_IDENTITY()
go

create trigger numerowaniealbum on utwor for delete as update album set l_utworow =
l_utworow-1 where id in (select id_albumu from deleted)
go
create trigger dodajpodobnealbumy on album for insert
as
declare @a varchar(40)
set @a = (select top 1 a.id from album a join inserted i on a.id_gatunek=i.id_gatunek order
by NEWID())
if @a not like (select id from inserted)
begin
insert into podobne_albumy (id1,id2) values ((select id from inserted), @a)
select * from podobne_albumy where id=SCOPE_IDENTITY()
end
go
create trigger dodajpodobneutwory on utwor for insert
as
declare @a varchar(40)
set @a = (select top 1 u.id from utwor u join album on u.id_albumu = album.id where
id_gatunek=(select id_gatunek from inserted join album on inserted.id_albumu=album.id)
order by NEWID())
if @a not like (select id from inserted)
begin
insert into podobne_utwory (id1,id2) values ((select id from inserted), @a )
select * from podobne_utwory where id=SCOPE_IDENTITY()
end
go
create trigger autonumerowanie on utwor_playlista for delete as
declare @i int
set @i=(select top 1 nr_na_liscie from deleted)
while exists (select * from utwor_playlista where nr_na_liscie>@i)
begin
update utwor_playlista set nr_na_liscie=@i where id_playlista =(select id_playlista from
deleted) and nr_na_liscie=@i+1
set @i=@i+1
end
go
insert into wykonawca (nazwa, kraj, rok_zalozenia) values ('Aerosmith', 'USA', 1970)
insert into wykonawca (nazwa, kraj, rok_zalozenia) values ('Guns n Roses', 'USA', 1985)
insert into wykonawca (nazwa, kraj, rok_zalozenia) values ('Metallica', 'USA', 1981) insert
into wykonawca (nazwa, kraj, rok_zalozenia) values ('Kult', 'Polska', 1982) insert into
wykonawca (nazwa, kraj, rok_zalozenia) values ('Eagles', 'USA', 1970) insert into
wykonawca (nazwa, kraj, rok_zalozenia) values ('The Beatles', 'Wielka Brytania', 1960)

insert into wykonawca (nazwa, kraj, rok_zalozenia) values ('The Rolling Stones', 'Wielka
Brytania', 1962) insert into wykonawca (nazwa, kraj, rok_zalozenia) values ('Quarashi',
'Irlandia', 1996) insert into wykonawca (nazwa, kraj, rok_zalozenia) values ('Nirvana', 'USA',
1987) insert into wykonawca (nazwa, kraj, rok_zalozenia) values ('Led Zeppelin', 'Wielka
Brytania', 1968) insert into wykonawca (nazwa, kraj, rok_zalozenia) values ('The
Cranberries', 'Irlandia', 1989) insert into wykonawca (nazwa, kraj, rok_zalozenia) values
('Michael Jackson', 'USA', 1979) insert into wykonawca (nazwa, kraj, rok_zalozenia) values
('Queen', 'Wielka Brytania', 1970) insert into wykonawca (nazwa, kraj, rok_zalozenia) values
('50 Cent', 'USA', 2003)
insert into gatunek (gatunek) values ('rock') insert into gatunek (gatunek) values ('trash
metal') insert into gatunek (gatunek) values ('hard rock') insert into gatunek (gatunek) values
('rock alternatywny')
insert into gatunek (gatunek) values ('rap') insert into gatunek (gatunek) values ('Hip hop')
insert into gatunek (gatunek) values ('Blues') insert into gatunek (gatunek) values ('Country')
insert into gatunek (gatunek) values ('folk') insert into gatunek (gatunek) values ('Pop')

insert into album (nazwa, id_wykonawcy,rok_wydania,id_gatunek,l_utworow) values ('Get a
Grip',1,1993,1,15) insert into album (nazwa,
id_wykonawcy,rok_wydania,id_gatunek,l_utworow) values ('Master of Puppets',3,1986,2,0)
insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Intro',1,'00:00:23',1)
insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Eat the
Rich',1,'00:04:09',2) insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Get
a Grip',1,'00:03:58',3) insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values
('Fever',1,'00:04:15',4) insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values
('Livin on the Edge',1,'00:06:20',5) insert into utwor
(nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Flesh',1,'00:05:56',6) insert into utwor
(nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Walk on Down',1,'00:03:37',7) insert into
utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Shut Up and Dance',1,'00:04:55',8)
insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Cryin',1,'00:05:08',9)
insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Gotta Love
It',1,'00:05:58',10) insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values
('Crazy',1,'00:05:16',11) insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values
('Line up',1,'00:04:02',12) insert into utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values
('Cant Stop Messin',1,'00:03:32',13) insert into utwor
(nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Amaazing',1,'00:05:56',14) insert into
utwor (nazwa,id_albumu,dlugosc,nr_w_albumie) values ('Boogie Man',1,'00:02:16',15)
exec dodaj_utwor 'leper messiah','master of puppets','00:05:40',6
exec dodaj_album 'Appetite for Destruction', 'Guns n Roses' ,1984, 'rock'
exec dodaj_utwor 'Paradise City', 'Appetite for Destruction','00:06:46',6
exec dodaj_wykonawce_i_album 'AC/DC','australia',1973,'High Voltage', 1975,'rock'
exec dodaj_album 'Bad','Michael Jackson',1987,'Pop'
exec dodaj_album 'Get Rich or Die Tryin', '50 Cent', 2003,'Rap'
exec dodaj_utwor_i_przeboj 'Battery','Master of puppets','00:05:12',1

exec dodaj_utwor_i_przeboj 'Master of puppets', 'master of puppets', '00:08:35',2
exec dodaj_album 'Beatles for Sale', 'The Beatles', 1964,'rock'
exec dodaj_utwor_i_przeboj 'No reply','Beatles for sale','00:02:15',1
exec dodaj_playliste 'fajne','battery'
exec dodaj_playliste 'fajne', 'Paradise City'
exec dodaj_playliste 'fajne', 'get a grip'
exec dodaj_playliste 'impreza','No reply'
exec dodaj_playliste 'impreza','intro'
exec dodaj_playliste 'impreza','eat the rich'
exec dodaj_playliste 'impreza','crazy'
exec dodaj_playliste 'impreza','cryin'
exec dodaj_playliste 'impreza','line up'
exec dodaj_playliste 'impreza','gotta love it'
exec dodaj_playliste 'impreza','fever'
exec dodaj_playliste 'zxc','master of puppets'
exec dodaj_utwor 'Orion','Master of puppets' ,'00:08:27',7
go
/*
drop table podobne_albumy
drop table podobne_utwory
drop table utwor_playlista
drop table przeboje
drop table playlista
drop table utwor
drop table album
drop table gatunek
drop table wykonawca
drop procedure dodaj_album
drop procedure dodaj_gatunek
drop procedure dodaj_playliste
drop procedure dodaj_podobne_albumy
drop procedure dodaj_podobne_utwory
drop procedure dodaj_przeboj
drop procedure dodaj_utwor
drop procedure dodaj_utwor_i_przeboj
drop procedure dodaj_wykonawce
drop procedure dodaj_wykonawce_i_album
drop procedure zmien_gatunek_albumu
drop procedure zmien_nazwe_zespolu
drop procedure zmien_opis_gatunku
drop procedure zmien_przeboje
drop procedure usun_utwor_na_playliscie
drop procedure usun_playliste
drop trigger autonumerowanie
drop trigger dodajpodobneutwory
drop trigger dodajpodobnealbumy

drop trigger numerowaniealbum
select * from album
select * from wykonawca
select * from utwor
select * from gatunek
select * from utwor_playlista
select * from podobne_utwory
select * from podobne_albumy
select * from przeboje
select * from playlista
*/