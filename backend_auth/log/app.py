from flask import Flask, jsonify, request
import psycopg2
import logging

app = Flask(__name__)

# Conexão com o banco de dados
conn = psycopg2.connect(
    host='db',
    database='postgres',
    user='postgres',
    password='postgres'
)

# Função para registrar logs no banco de dados
def log_to_db(level, message, logger_name):
    try:
        cur = conn.cursor()
        cur.execute('INSERT INTO logs (level, message, logger_name) VALUES (%s, %s, %s)', (level, message, logger_name))
        conn.commit()
        cur.close()
    except Exception as e:
        print(f'Error logging to database: {str(e)}')

# Rota para registrar logs
@app.route('/log', methods=['POST'])
def log():
    data = request.get_json()
    level = data['level']
    message = data['message']
    logger_name = data['logger_name']

    log_to_db(level, message, logger_name)
    
    return jsonify({'message': 'Log registered successfully'})

# Rota para requisitar logs
@app.route('/logs', methods=['GET'])
def get_logs():
    try:
        cur = conn.cursor()
        cur.execute('SELECT id, timestamp, level, message, logger_name FROM logs')
        logs = cur.fetchall()
        cur.close()

        logs_list = []
        for log in logs:
            logs_list.append({
                'id': log[0],
                'timestamp': log[1],
                'level': log[2],
                'message': log[3],
                'logger_name': log[4]
            })

        return jsonify(logs_list)
    except Exception as e:
        return jsonify({'message': str(e)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)
