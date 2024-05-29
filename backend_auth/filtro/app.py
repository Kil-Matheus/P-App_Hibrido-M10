from flask import Flask, request, send_file, jsonify
from PIL import Image, ImageFilter, ImageEnhance
import psycopg2
import io
import logging
import requests

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
file_handler = logging.FileHandler('app.log')
file_handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)

logger.addHandler(file_handler)

app = Flask(__name__)

conn = psycopg2.connect(
    host='db',
    database='postgres',
    user='postgres',
    password='postgres'
)

def log_to_api(level, message, logger_name):
    try:
        data = {
            'level': level,
            'message': message,
            'logger_name': logger_name
        }
        requests.post('http://172.17.0.1:8000/log', json=data)
    except Exception as e:
        print(f'Failed to send log to API: {str(e)}')


@app.route('/upload', methods=['POST'])
def upload_image():
    log_to_api('INFO', 'Upload request received', 'uploadHandler')
    if 'image' not in request.files:
        return jsonify({'error': 'No image part'}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if file:
        logger.info('Image received: %s', file.filename)
        # Abrir a imagem com Pillow
        image = Image.open(file)

        enhancer = ImageEnhance.Color(image)
        filtered_image = enhancer.enhance(9.5)

        # Converter para modo RGB se a imagem estiver em RGBA
        if filtered_image.mode == 'RGBA':
            filtered_image = filtered_image.convert('RGB')

        # Salvar a imagem filtrada em um objeto BytesIO
        img_io = io.BytesIO()
        filtered_image.save(img_io, 'JPEG')
        img_io.seek(0)

        log_to_api('INFO', 'Image processed successfully', 'uploadHandler')

        # Retornar a imagem como resposta HTTP
        return send_file(img_io, mimetype='image/jpeg')

    return jsonify({'error': 'File not processed'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
