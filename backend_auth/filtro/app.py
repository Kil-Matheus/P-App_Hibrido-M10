from flask import Flask, request, send_file, jsonify
from PIL import Image, ImageFilter
import io
import logging

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route('/upload', methods=['POST'])
def upload_image():
    logger.info('Upload request received')
    if 'image' not in request.files:
        return jsonify({'error': 'No image part'}), 400

    file = request.files['image']

    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if file:
        logger.info('Image received: %s', file.filename)
        # Abrir a imagem com Pillow
        image = Image.open(file)

        # Aplicar um filtro (exemplo: BLUR)
        filtered_image = image.filter(ImageFilter.BLUR)

        # Converter para modo RGB se a imagem estiver em RGBA
        if filtered_image.mode == 'RGBA':
            filtered_image = filtered_image.convert('RGB')

        # Salvar a imagem filtrada em um objeto BytesIO
        img_io = io.BytesIO()
        filtered_image.save(img_io, 'JPEG')
        img_io.seek(0)

        logger.info('Image processed successfully')

        # Retornar a imagem como resposta HTTP
        return send_file(img_io, mimetype='image/jpeg')

    return jsonify({'error': 'File not processed'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
