from flask import Flask, jsonify, request
import psycopg2

app = Flask(__name__)

conn = psycopg2.connect(
    host='db',
    database='postgres',
    user='postgres',
    password='postgres'
)

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data['email']
    password = data['password']

    try:
        cur = conn.cursor()
        cur.execute('SELECT * FROM users WHERE email = %s AND senha = %s', (email, password))
        user = cur.fetchone()
        cur.close()

        if user:
            return jsonify({'message': 'Login successful'})
        else:
            return jsonify({'message': 'Invalid credentials'})
    except Exception as e:
        return jsonify({'message': str(e)})

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data['email']
    password = data['password']

    try:
        cur = conn.cursor()
        cur.execute('INSERT INTO users (email, password) VALUES (%s, %s)', (email, password))
        conn.commit()
        cur.close()

        return jsonify({'message': 'User created successfully'})
    except Exception as e:
        return jsonify({'message': str(e)})


@app.route('/users', methods=['GET'])
def users():
    try:
        cur = conn.cursor()
        cur.execute('SELECT * FROM users')
        users = cur.fetchall()
        cur.close()

        return jsonify(users)
    except Exception as e:
        return jsonify({'message': str(e)})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)