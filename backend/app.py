from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import difflib
import os

app = Flask(__name__)
CORS(app)

# Pastikan membaca file di folder yang sama
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATABASE_FILE = os.path.join(BASE_DIR, 'data.json')

def load_data():
    if not os.path.exists(DATABASE_FILE):
        return []
    with open(DATABASE_FILE, 'r') as f:
        return json.load(f)

def save_data(data):
    with open(DATABASE_FILE, 'w') as f:
        json.dump(data, f, indent=2)

@app.route('/chat', methods=['POST'])
def chat():
    user_input = request.json.get('message', '').lower()
    data = load_data()

    questions = [item['question'] for item in data]
    # Mencari kemiripan teks (agar typo dikit tetap terbaca)
    matches = difflib.get_close_matches(user_input, questions, n=1, cutoff=0.6)

    if matches:
        matched_question = matches[0]
        for item in data:
            if item['question'] == matched_question:
                return jsonify({'response': item['answer'], 'found': True})

    return jsonify({'response': "Maaf, saya tidak mengerti. Ajari saya dong?", 'found': False})

@app.route('/teach', methods=['POST'])
def teach():
    question = request.json.get('question', '').lower()
    answer = request.json.get('answer', '')
    data = load_data()

    data.append({'question': question, 'answer': answer})
    save_data(data)

    return jsonify({'status': 'Success', 'message': 'Terima kasih ilmunya!'})

if __name__ == '__main__':
    # Host 0.0.0.0 agar bisa diakses dari luar (emulator/HP)
    app.run(host='0.0.0.0', port=5000, debug=True)