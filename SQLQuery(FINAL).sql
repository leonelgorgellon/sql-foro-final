-- FINAL

-- 2) Implementar el modelo de datos en SQL Server

CREATE DATABASE FORO

USE FORO

CREATE TABLE Usuario (
	IDUsuario int not null identity (1,1),
	Num_Usuario int not null, 
	Avatar varchar (100) not null ,
	Nombre varchar (100) not null,
	Apellido varchar (100) not null,
	Email varchar (50) not null,
	Telefono int not null,
	Contraseña varchar (10) not null,
	IDCat_Usuario varchar (4) not null,
	IDHist_Usuario varchar (4) not null,
	IDMsj_Priv varchar(10) not null, 
	primary key (IDUsuario)
	)

CREATE TABLE CategoriaUsuarios (
	IDCat_Usuario int not null identity (1,1),
	Nombre varchar (50) not null,
	Descripcion varchar (250) not null,
	primary key (IDCat_Usuario) 
	)

CREATE TABLE HistorialUsuario (
	IDHist_Usuario int not null identity (1,1),
	Cant_Visitas int not null,
	IDUsuario int not null,
	primary key (IDHist_Usuario) 
	)

CREATE TABLE MensajePrivado (
	IDMsj_Priv int not null identity (1,1),
	IDUsuario int not null, 
	Destino_NumUsuario int not null,
	CuerpoTexto varchar(250) not null,
	primary key (IDMsj_Priv)
	)

CREATE TABLE Posteo (
	IDPosteo int not null identity (1,1),
	IDTema int not null,
	IDUsuario int not null,
	Posteo_Date datetime,
	CuerpoTexto varchar (250) not null,
	Cant_Posteo int not null,
	primary key (IDPosteo)
	)

CREATE TABLE Respuesta (
	IDRespuesta int not null identity (1,1),
	IDPosteo int not null,
	IDUsuario int not null,
	Resp_Date datetime,
	CuerpoTexto varchar (250) not null,
	Cant_Resp int not null,
	primary key (IDRespuesta)
	)

CREATE TABLE Tema (
	IDTema int not null identity (1,1),
	IDPosteo int not null,
	NombreTema varchar (50),
	NivelMinCat_Post varchar (50),
	primary key (IDTema)
	)
	
CREATE TABLE Subtema (
	IDSubtema int not null identity (1,1),
	IDTema int not null,
	NombreSubtema varchar (50),
	NivelMinCat_Post varchar (50),
	primary key (IDSubtema)
	)

-- 3) Construir  la vista Temas_Subtemas donde muestre TEMA-SUBTEMA-CantidadDeMensajes
-- nota ( tomo CantidadDeMensajes a la suma de los posteos que hayan y las respuestas que tengan cada uno)

create view vwTemas_Subtemas as
select T.NombreTema, S.NombreSubtema, sum (P.Cant_Posteo + R.Cant_Resp) as CantidadDeMensajes
from Tema as T
inner join Subtema as S on T.IDTema = S.IDTema
inner join Posteo as P on T.IDTema = P.IDTema
inner join Respuesta as R on P.IDPosteo = R.IDPosteo
group by NombreTema, NombreSubtema

select * from vwTemas_Subtemas 


-- 4) Construir el stored procedure que recibiendo un IDUsuario como parametro retorne TEMA-Topic-Fecha
--    de todos los mensajes creados desde la ultima vez que ingreso al sistema de foro
-- nota (tomo como fecha de mensaje a la fecha donde se realiza el posteo y las respuesta a ellos)

create procedure sp_Consulta1
@IDUsuario int
as 
begin 

	begin transaction 
	if (@IDUsuario is not null)
	begin
	select count (Posteo_Date) as FechaMsjPosteo from Posteo where IDUsuario = @IDUsuario 
	select count (Resp_Date) as FechaMsjResp from Respuesta where IDUsuario = @IDUsuario
	select IDTema as Topic from Posteo where IDUsuario = @IDUsuario  
	print @@identity 
	end 
	else 
	print 'Error'

	if @@ERROR = 0
	commit transaction
	else 
	rollback transaction

end

begin transaction
exec sp_Consulta1 8 
commit transaction
rollback transaction


-- 5) Construir el stored procedure que reciba (IDUsuario, IDTema, topic, texto) 
-- y si el nivel de usuario lo permite, realice el posteo, sino que retorne error.

create procedure sp_Consulta2
@IDUsuario int,
@IDTema int,
@NombreTema varchar (50),
@CuerpoTexto varchar (250)
as
begin 
declare @Categoria varchar (50)
declare @Fecha date
declare @Cant int

select @Categoria = (select IDCat_Usuario from Usuario where IDUsuario = @IDUsuario)
select @Fecha = getdate()
select @Cant = (select Cant_Posteo from Posteo where IDTema = @IDTema)  

--nota = tomo el IDCat_Usuario ya que me da los niveles que tiene la CategoriaUsario, tomo como que cualquier nivel de 
-- usuario en ese TEMA puede postear, por ende cuando es mayor a 0 le da el permiso)

if (@Categoria > 0)
begin 
	insert into Posteo (IDTema, IDUsuario , Posteo_Date, CuerpoTexto, Cant_Posteo)
	values (@IDTema, @IDUsuario, @Fecha, @CuerpoTexto, @Cant)
	update Posteo set Cant_Posteo = Cant_Posteo + @Cant where IDTema = @IDTema and IDUsuario = @IDUsuario
	print @@identity 
end 
else
	print 'Error nivel no permitido'

if @@error = 0
commit transaction 
else 
rollback transaction
end


begin transaction
exec sp_Consulta2 2, 5, 'Economia', 'A la salida de una nueva reunión del Gabinete Económico,
el funcionario se refirió a la situación macroeconómica del país y también a los movimientos del Gobierno 
para intentar dar algo de calma a la cotización del dólar. '
commit transaction 
rollback transaction




