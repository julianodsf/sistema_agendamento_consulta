import psycopg2
from psycopg2 import errors
from datetime import datetime

def conectar_banco():
    try:
        # Parâmetros de conexão
        conexao = psycopg2.connect(
            host="localhost",
            database="sis_agendamento_consulta",
            user="postgres",
            password="obmep2018",
            port="5432"
        )
        return conexao
    except Exception as e:
        print(f"Erro ao conectar com o banco de dados: {e}")
        return None

def exibir_menu():
    print("\n" + "="*45)
    print("      SISTEMA DE AGENDAMENTO CLÍNICO      ")
    print("="*45)
    print("[1] Visualizar Agenda Completa dos Médicos")
    print("[2] Agendar uma Nova Consulta")
    print("[3] Consultar Categoria do Paciente")
    print("[4] Histórico Prévio do Paciente")
    print("[0] Sair")
    print("="*45)

# --- CONSULTA USANDO VIEW ---
def menu_listar_agenda(cursor):
    print("\n--- AGENDA COMPLETA ---")
    cursor.execute("""
        SELECT consulta_id, data_hora, paciente_nome, medico_nome, especialidade, status 
        FROM vw_agenda_completa
        ORDER BY data_hora ASC;
    """)
    consultas = cursor.fetchall()
    
    if not consultas:
        print("Nenhuma consulta encontrada.")
        return

    print(f"{'ID':<4} | {'Data/Hora':<19} | {'Paciente':<20} | {'Médico (Especialidade)':<30} | {'Status'}")
    print("-" * 85)
    for c in consultas:
        med_esp = f"{c[3]} ({c[4]})"
        print(f"{c[0]:<4} | {str(c[1]):<19} | {c[2]:<20} | {med_esp:<30} | {c[5]}")

# --- OPERAÇÃO DE INSERT PASSANDO POR TRIGGER ---
def menu_agendar_consulta(conexao, cursor):
    print("\n--- NOVO AGENDAMENTO ---")
    try:
        id_paciente = int(input("ID do Paciente: "))
        id_medico = int(input("ID do Médico: "))
        data_hora_str = input("Data e Hora (AAAA-MM-DD HH:MM): ")
        
        # Valida formato básico da data digitada
        data_hora = datetime.strptime(data_hora_str, "%Y-%m-%d %H:%M")
        
        # Tenta inserir no banco de dados
        cursor.execute("""
            INSERT INTO Consulta (id_paciente, id_medico, data_hora, status)
            VALUES (%s, %s, %s, 'Agendada');
        """, (id_paciente, id_medico, data_hora))
        
        conexao.commit()
        print("\n[SUCESSO] Consulta agendada com sucesso!")
        
    except errors.RaiseException as ex:
        # Captura a exceção lançada pela trigger 'trg_validar_conflito_horario'
        conexao.rollback()
        print("\n[ERRO DE VALIDAÇÃO DA TRIGGER]")
        print(ex.diag.message_primary)
    except ValueError:
        print("\n[ERRO] Entrada inválida ou formato de data incorreto.")
    except Exception as e:
        conexao.rollback()
        print(f"\n[ERRO INESPERADO] {e}")

# --- CHAMADA DE FUNCTION ---
def menu_categoria_paciente(cursor):
    print("\n--- CATEGORIA DO PACIENTE ---")
    try:
        id_paciente = int(input("Digite o ID do Paciente: "))
        
        # Chama a function do banco de dados
        cursor.execute("SELECT fn_categoria_paciente(%s);", (id_paciente,))
        categoria = cursor.fetchone()[0]
        
        print(f"\nResultado do Banco: O paciente de ID {id_paciente} é considerado: **{categoria}**")
    except ValueError:
        print("[ERRO] ID inválido.")
    except Exception as e:
        print(f"[ERRO] {e}")

# --- CHAMADA DE PROCEDURE ---
def menu_historico_paciente(conexao, cursor):
    print("\n--- HISTÓRICO COMPLETO DO PACIENTE ---")
    try:
        id_paciente = int(input("Digite o ID do Paciente: "))
        
        # Limpa notices antigos da conexão para garantir leitura limpa
        del conexao.notices[:]
        
        # Chama a procedure
        cursor.execute("CALL pr_listar_historico_paciente(%s);", (id_paciente,))
        
        # Recupera as mensagens emitidas pelo 'RAISE NOTICE' dentro da procedure
        if conexao.notices:
            print("\n--- Mensagens retornadas pelo Banco de Dados ---")
            for notice in conexao.notices:
                print(notice.strip())
        else:
            print("\nNenhum registro impresso ou paciente sem histórico.")
            
    except ValueError:
        print("[ERRO] ID inválido.")
    except Exception as e:
        print(f"[ERRO] {e}")

def main():
    conexao = conectar_banco()
    if not conexao:
        return
        
    cursor = conexao.cursor()
    
    while True:
        exibir_menu()
        opcao = input("Escolha uma opção: ").strip()
        
        if opcao == "1":
            menu_listar_agenda(cursor)
        elif opcao == "2":
            menu_agendar_consulta(conexao, cursor)
        elif opcao == "3":
            menu_categoria_paciente(cursor)
        elif opcao == "4":
            menu_historico_paciente(conexao, cursor)
        elif opcao == "0":
            print("\nSaindo do sistema. Até logo!")
            break
        else:
            print("\nOpção inválida! Tente novamente.")
            
    cursor.close()
    conexao.close()

if __name__ == "__main__":
    main()