-- ====================--
-- CRIAÇÃO DAS TABELAS --
-- ====================--
CREATE TABLE Especialidade (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Medico (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    crm VARCHAR(20) NOT NULL UNIQUE,
    id_especialidade INT NOT NULL,
    FOREIGN KEY (id_especialidade) REFERENCES Especialidade(id) ON DELETE RESTRICT
);

CREATE TABLE Paciente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100)
);

-- Tabela pra definir a grade de horários de trabalho padrão do médico
CREATE TABLE Horario (
    id SERIAL PRIMARY KEY,
    id_medico INT NOT NULL,
    dia_semana INT NOT NULL CHECK (dia_semana BETWEEN 0 AND 6), -- 0 = Domingo, 1 = Segunda, etc.
    hora_inicio TIME NOT NULL,
    hora_fim TIME NOT NULL,
    FOREIGN KEY (id_medico) REFERENCES Medico(id) ON DELETE CASCADE
);

CREATE TABLE Consulta (
    id SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Cancelada', 'Realizada')),
    FOREIGN KEY (id_paciente) REFERENCES Paciente(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_medico) REFERENCES Medico(id) ON DELETE RESTRICT
);
-- ===============--
-- DADOS DE TESTE --
-- ===============--

-- Limpeza Pŕevia
TRUNCATE TABLE Consulta, Horario, Paciente, Medico, Especialidade RESTART IDENTITY CASCADE;

INSERT INTO Especialidade (nome) VALUES
('Cardiologia'),
('Pediatria'),
('Clínica Médica'),
('Dermatologia'),
('Ortopedia'),
('Ginecologia'),
('Neurologia'),
('Psiquiatria'),
('Oftalmologia'),
('Endocrinologia');

INSERT INTO Medico (nome, crm, id_especialidade) VALUES
('Dr. Arnaldo Silva', 'CRM/SP 123456', 1),
('Dra. Juliana Medeiros', 'CRM/SP 654321', 2),
('Dr. Roberto Souza', 'CRM/RJ 111222', 3),
('Dra. Fernanda Lima', 'CRM/MG 333444', 4),
('Dr. Carlos Santos', 'CRM/SP 555666', 5),
('Dra. Camila Alves', 'CRM/RS 777888', 6),
('Dr. Lucas Costa', 'CRM/PR 999000', 7),
('Dra. Beatriz Rocha', 'CRM/BA 121314', 8),
('Dr. Gabriel Melo', 'CRM/SC 151617', 9),
('Dra. Patricia Oliveira', 'CRM/GO 181920', 10);

INSERT INTO Paciente (nome, data_nascimento, telefone, email) VALUES
('Carlos Andrade', '1988-05-14', '(11) 98888-7777', 'carlos@email.com'),
('Mariana Souza', '2015-10-22', '(11) 97777-6666', 'mae_mariana@email.com'),
('João Pereira', '1975-03-20', '(21) 96666-5555', 'joao.p@email.com'),
('Maria Rodrigues', '1992-08-12', '(31) 95555-4444', 'maria.rod@email.com'),
('Pedro Santos', '1960-12-05', '(11) 94444-3333', 'pedro.santos@email.com'),
('Ana Oliveira', '2000-01-25', '(51) 93333-2222', 'ana.oli@email.com'),
('Luiz Fernando', '1983-07-09', '(41) 92222-1111', 'luiz.f@email.com'),
('Sofia Costa', '2018-04-14', '(71) 91111-0000', 'pais_sofia@email.com'),
('Ricardo Almeida', '1995-11-30', '(48) 99900-1234', 'ricardo.a@email.com'),
('Julia Martins', '1968-02-18', '(62) 98800-4321', 'julia.mar@email.com');

-- 1 = Segunda, 2 = Terça, 3 = Quarta, 4 = Quinta, 5 = Sexta
INSERT INTO Horario (id_medico, dia_semana, hora_inicio, hora_fim) VALUES
(1, 1, '08:00:00', '12:00:00'),
(2, 1, '13:00:00', '17:00:00'),
(3, 2, '08:00:00', '12:00:00'),
(4, 2, '14:00:00', '18:00:00'),
(5, 3, '09:00:00', '13:00:00'),
(6, 3, '14:00:00', '18:00:00'),
(7, 4, '08:00:00', '12:00:00'),
(8, 4, '13:00:00', '17:00:00'),
(9, 5, '08:00:00', '12:00:00'),
(10, 5, '14:00:00', '18:00:00');

INSERT INTO Consulta (id_paciente, id_medico, data_hora, status) VALUES
(1, 1, '2026-06-01 08:00:00', 'Agendada'),
(2, 1, '2026-06-01 08:30:00', 'Agendada'),
(3, 2, '2026-06-01 13:00:00', 'Agendada'),
(4, 3, '2026-06-02 09:00:00', 'Agendada'),
(5, 4, '2026-06-02 14:30:00', 'Agendada'),
(6, 5, '2026-06-03 10:00:00', 'Agendada'),
(7, 6, '2026-06-03 15:00:00', 'Agendada'),
(8, 7, '2026-06-04 11:00:00', 'Realizada'),
(9, 8, '2026-06-04 16:00:00', 'Cancelada'),
(10, 9, '2026-06-05 08:30:00', 'Agendada');

-- =================--
-- CONSULTAS SELECT --
-- =================--

SELECT
    m.id AS medico_id,
    m.nome AS nome_medico,
    m.crm,
    e.nome AS especialidade
FROM Medico m
INNER JOIN Especialidade e ON m.id_especialidade = e.id
ORDER BY m.nome;

SELECT
    c.id AS consulta_id,
    c.data_hora,
    p.nome AS nome_paciente,
    m.nome AS nome_medico,
    c.status
FROM Consulta c
INNER JOIN Paciente p ON c.id_paciente = p.id
INNER JOIN Medico m ON c.id_medico = m.id
ORDER BY c.data_hora;

SELECT
    m.nome AS nome_medico,
    CASE h.dia_semana
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Segunda-feira'
        WHEN 2 THEN 'Terça-feira'
        WHEN 3 THEN 'Quarta-feira'
        WHEN 4 THEN 'Quinta-feira'
        WHEN 5 THEN 'Sexta-feira'
        WHEN 6 THEN 'Sábado'
    END AS dia_da_semana,
    h.hora_inicio,
    h.hora_fim
FROM Horario h
INNER JOIN Medico m ON h.id_medico = m.id
ORDER BY m.nome, h.dia_semana;

-- ==========--
-- FUNCTIONS --
-- ==========--

CREATE OR REPLACE FUNCTION fn_calcular_idade_paciente(p_id_paciente INT)
RETURNS INT AS $$
DECLARE
    v_idade INT;
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, data_nascimento))
    INTO v_idade
    FROM Paciente
    WHERE id = p_id_paciente;

    RETURN v_idade;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_categoria_paciente(p_id_paciente INT)
RETURNS VARCHAR AS $$
DECLARE
    v_idade INT;
    v_categoria VARCHAR(50);
BEGIN
    v_idade := fn_calcular_idade_paciente(p_id_paciente);

    IF v_idade IS NULL THEN
        v_categoria := 'Paciente não encontrado';
    ELSIF v_idade < 12 THEN
        v_categoria := 'Infantil (Pediatria)';
    ELSIF v_idade >= 60 THEN
        v_categoria := 'Idoso (Prioritário)';
    ELSE
        v_categoria := 'Adulto';
    END IF;

    RETURN v_categoria;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE pr_listar_historico_paciente(p_id_paciente INT)
AS $$
DECLARE
    r_consulta RECORD;
BEGIN
    RAISE NOTICE '--- HISTÓRICO DO PACIENTE ID: % ---', p_id_paciente;

    FOR r_consulta IN
        SELECT c.data_hora, m.nome AS medico, c.status
        FROM Consulta c
        INNER JOIN Medico m ON c.id_medico = m.id
        WHERE c.id_paciente = p_id_paciente
        ORDER BY c.data_hora DESC
    LOOP
        RAISE NOTICE 'Data/Hora: % | Médico: % | Status: %',
                     r_consulta.data_hora, r_consulta.medico, r_consulta.status;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ======--
-- VIEWS --
-- ======--

CREATE OR REPLACE VIEW vw_agenda_completa AS
SELECT
    c.id AS consulta_id,
    c.data_hora,
    p.nome AS paciente_nome,
    p.telefone AS paciente_telefone,
    m.nome AS medico_nome,
    e.nome AS especialidade,
    c.status
FROM Consulta c
INNER JOIN Paciente p ON c.id_paciente = p.id
INNER JOIN Medico m ON c.id_medico = m.id
INNER JOIN Especialidade e ON m.id_especialidade = e.id;

CREATE OR REPLACE VIEW vw_painel_consultas_ativas AS
SELECT
    id AS consulta_id,
    id_medico,
    data_hora
FROM Consulta
WHERE status = 'Agendada';

-- =========--
-- TRIGGERS --
-- =========--

-- Criação da tabela de auditoria
CREATE TABLE Log_Consulta (
    id SERIAL PRIMARY KEY,
    id_consulta INT,
    acao VARCHAR(20),
    status_anterior VARCHAR(20),
    status_novo VARCHAR(20),
    usuario VARCHAR(100) DEFAULT CURRENT_USER,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Função do Trigger
CREATE OR REPLACE FUNCTION fn_trg_auditoria_consulta()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO Log_Consulta (id_consulta, acao, status_novo)
        VALUES (NEW.id, 'INSERÇÃO', NEW.status);
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO Log_Consulta (id_consulta, acao, status_anterior, status_novo)
        VALUES (NEW.id, 'ATUALIZAÇÃO', OLD.status, NEW.status);
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO Log_Consulta (id_consulta, acao, status_anterior)
        VALUES (OLD.id, 'EXCLUSÃO', OLD.status);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Vincular o Trigger à tabela
CREATE TRIGGER trg_auditoria_consulta
AFTER INSERT OR UPDATE OR DELETE ON Consulta
FOR EACH ROW
EXECUTE FUNCTION fn_trg_auditoria_consulta();

-- Função de Validação
CREATE OR REPLACE FUNCTION fn_trg_validar_conflito_horario()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o médico já possui alguma consulta 'Agendada' que intercepte a nova janela de 30 minutos
    IF EXISTS (
        SELECT 1
        FROM Consulta
        WHERE id_medico = NEW.id_medico
          AND status = 'Agendada'
          AND id <> COALESCE(NEW.id, 0)
          -- Lógica de sobreposição de horários (Janela de 30 minutos)
          AND data_hora < NEW.data_hora + INTERVAL '30 minutes'
          AND data_hora + INTERVAL '30 minutes' > NEW.data_hora
    ) AND NEW.status = 'Agendada' THEN

        RAISE EXCEPTION 'Falha no agendamento: O médico (ID %) já possui uma consulta ativa no período entre % e %.',
            NEW.id_medico,
            NEW.data_hora,
            NEW.data_hora + INTERVAL '30 minutes';

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Vinculação do Trigger à tabela
CREATE TRIGGER trg_validar_conflito_horario
BEFORE INSERT OR UPDATE ON Consulta
FOR EACH ROW
EXECUTE FUNCTION fn_trg_validar_conflito_horario();

-- ============================--
-- CASOS DE TESTE DAS TRIGGERS --
-- ============================--

-- Teste de Trigger 1
-- INSERT INTO Consulta (id_paciente, id_medico, data_hora, status)
-- VALUES (4, 1, '2026-06-01 08:15:00', 'Agendada');

-- Teste de Trigger 2
-- Inserindo uma nova consulta para gerar o log de INSERÇÃO
-- INSERT INTO Consulta (id_paciente, id_medico, data_hora, status)
-- VALUES (5, 2, '2026-06-01 15:00:00', 'Agendada');
-- Atualizando o status para gerar o log de ATUALIZAÇÃO
-- UPDATE Consulta
-- SET status = 'Realizada'
-- WHERE id_paciente = 5 AND id_medico = 2 AND data_hora = '2026-06-01 15:00:00';
-- Verificando a tabela de auditoria
-- SELECT acao, status_anterior, status_novo, usuario
-- FROM Log_Consulta
-- ORDER BY data_alteracao DESC
-- LIMIT 2;

-- Teste de Trigger 3
-- Deletando o registro criado no teste anterior
-- DELETE FROM Consulta
-- WHERE id_paciente = 1 AND id_medico = 1 AND data_hora = '2026-06-01 08:00:00';

-- Verificando o último registro inserido no log
-- SELECT acao, status_anterior, status_novo, data_alteracao
-- FROM Log_Consulta
-- ORDER BY data_alteracao DESC
-- LIMIT 1;
