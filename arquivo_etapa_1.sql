create table Especialidade (
  id_especialidade serial primary key,
  nome_especialidade varchar(32) not null
);

create table Medico (
  id_medico serial primary key,
  id_especialidade int not null,
  nome_medico varchar(64) not null,
  foreign key (id_especialidade) references Especialidade(id_especialidade)
);

create table Paciente (
  id_paciente serial primary key,
  nome_paciente varchar(64) not null,
  telefone varchar(32) not null,
  data_nascimento date not null
);

create table Consulta (
  id_consulta serial primary key,
  data_consulta date default current_date,
  id_paciente int not null,
  id_medico int not null,
  id_horario int not null,
  foreign key (id_paciente) references Paciente(id_paciente),
  foreign key (id_medico) references Medico(id_medico)
);

create table Horario (
  id_horario serial primary key,
  id_medico int not null,
  inicio_horario int not null,
  fim_horario int not null,
  foreign key (id_medico) references Medico(id_medico)
);


insert into Especialidade(nome_especialidade) values
  ('Pediatria'),
  ('Cardiologia'),
  ('Dermatologia'),
  ('Endocrinologia'),
  ('Neurologia'),
  ('Cirurgia Geral'),
  ('Cirurgia Plástica'),
  ('Urologia'),
  ('Ortopedia'),
  ('Anestesiologia');

insert into Paciente(nome_paciente, telefone, data_nascimento) values
  ('José Carlos de Nobrega', '(86) 994212222', '2001-07-20'),
  ('Maria Júlia Junqueira', '(11) 994211313', '1999-04-10'),
  ('Luendell Sousa', '(86) 994211111', '1980-01-04'),
  ('Leonardo Vinhaes Castelo Branco', '(86) 994214422', '2002-12-25'),
  ('Francisco das Chagas de Freitas', '(86) 994313222', '1995-12-11'),
  ('Francisco Ryan Cabral', '(86) 994267222', '2003-03-03'),
  ('Mateus Cavalcante Soares', '(86) 994216222', '2001-07-10'),
  ('Bruno Andrade Ferreira', '(86) 994215222', '1989-02-21'),
  ('Luana de Sousa Cruz', '(86) 994219222', '1998-05-02'),
  ('Marcela Sousa Silva', '(86) 994213222', '2005-09-12');

insert into Medico(nome_medico, id_especialidade) values
  ('Mateus Hiroki', 1),
  ('Márcia Roffman', 4),
  ('Patricia Veras de Farias', 2),
  ('Igor Morozevich Romanov', 3),
  ('Gerson Pires Cruz', 8),
  ('Diego Tonini', 7),
  ('Marcos Soprani Passamani', 9),
  ('Livia Kruger Freitas', 10),
  ('Alexandre Garcia Aragão', 6),
  ('Viviane Sousa Passos', 5);

insert into Horario(id_medico, inicio_horario, fim_horario) values
  (1, 7, 12),
  (2, 8, 10),
  (3, 8, 12),
  (4, 9, 13),
  (5, 9, 13),
  (6, 14, 18),
  (7, 15, 19),
  (8, 15, 19),
  (9, 16, 20),
  (10, 19, 23);

insert into Consulta(id_paciente, id_medico, id_horario) values
  (4, 1, 1),
  (2, 10, 10),
  (3, 8, 8),
  (6, 3, 3),
  (1, 2, 2),
  (5, 9, 9),
  (7, 1, 1),
  (8, 9, 9),
  (9, 4, 4),
  (10, 5, 5);


select id_horario, nome_medico, inicio_horario, fim_horario
from Medico
inner join Horario on Medico.id_medico = Horario.id_medico;

select nome_medico, nome_especialidade
from Medico
inner join Especialidade on Medico.id_especialidade = Especialidade.id_especialidade;

select id_consulta, nome_paciente, nome_medico
from Paciente
inner join (select nome_medico, id_paciente as P_id_paciente, id_consulta
from Medico
inner join Consulta on Medico.id_medico = Consulta.id_medico) on Paciente.id_paciente = P_id_paciente;
