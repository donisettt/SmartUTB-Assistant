"""
Backend Flask API untuk SmartUTB Assistant
Menangani autentikasi, manajemen riwayat, dan logika chatbot.
"""

import os
import json
import difflib
import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS

# --- Inisialisasi Aplikasi ---
app = Flask(__name__)
CORS(app)

# --- Setup Path Konstan ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
USERS_FILE = os.path.join(BASE_DIR, 'users.json')
PUBLIC_DATA_FILE = os.path.join(BASE_DIR, 'data_public.json')
ACADEMIC_DATA_FILE = os.path.join(BASE_DIR, 'data_academic.json')
HISTORY_FILE = os.path.join(BASE_DIR, 'history_sessions.json')

# --- Fungsi Helper (Pustaka) ---

def load_json(filename, default_type='dict'):
    """
    Membaca dan mem-parsing file JSON dengan aman.
    Mengembalikan 'default_type' (list atau dict) jika file tidak ada atau error.
    """
    path = os.path.join(BASE_DIR, filename)
    if not os.path.exists(path):
        return [] if default_type == 'list' else {}
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError):
        print(f"Error: Gagal membaca file {filename}")
        return [] if default_type == 'list' else {}

def save_json(filename, data):
    """
    Menyimpan data (list/dict) ke file JSON.
    """
    path = os.path.join(BASE_DIR, filename)
    try:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
    except IOError:
        print(f"Error: Gagal menyimpan ke file {filename}")

# --- Load Database Statis (Hanya 1x saat Server Nyala) ---
# Ini membuat server lebih cepat karena tidak perlu baca file di hard disk setiap ada chat
USERS_DB = load_json(USERS_FILE, default_type='list')
PUBLIC_DB = load_json(PUBLIC_DATA_FILE, default_type='list')
ACADEMIC_DB = load_json(ACADEMIC_DATA_FILE, default_type='dict')


# --- Fungsi Logika Inti ---

def save_session_message(nim, session_id, user_text, bot_text):
    """
    Menyimpan satu pesan (user dan bot) ke dalam riwayat sesi yang spesifik.
    File history_sessions.json dibaca dan ditulis setiap kali fungsi ini dipanggil
    untuk memastikan data selalu ter-update (thread-safe sederhana).
    """
    # Membaca data terbaru dari file history
    all_history = load_json(HISTORY_FILE, default_type='list')
    if not isinstance(all_history, list):
        all_history = []  # Fallback jika file korup/bukan list

    user_data = next((item for item in all_history if item["nim"] == nim), None)

    if not user_data:
        user_data = {"nim": nim, "sessions": []}
        all_history.append(user_data)

    session = next((s for s in user_data["sessions"] if s["id"] == session_id), None)
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")

    if session:
        # Sesi sudah ada, tambahkan pesan
        session["messages"].append({"sender": "user", "text": user_text})
        session["messages"].append({"sender": "bot", "text": bot_text})
        session["last_updated"] = timestamp
    else:
        # Sesi baru, buat entri sesi
        new_session = {
            "id": session_id,
            "title": user_text[:30] + "...",  # Judul diambil dari 30 karakter pertama
            "last_updated": timestamp,
            "messages": [
                {"sender": "user", "text": user_text},
                {"sender": "bot", "text": bot_text}
            ]
        }
        user_data["sessions"].insert(0, new_session)  # Sesi baru di paling atas

    save_json(HISTORY_FILE, all_history)

def _get_academic_response(user_input):
    """
    Mencari jawaban spesifik dari database akademik (hanya untuk mahasiswa).
    Menggunakan pencocokan keyword sederhana.
    """
    # Membaca dari DB global yang sudah di-load
    mahasiswa = ACADEMIC_DB.get('mahasiswa', {})
    keuangan = ACADEMIC_DB.get('keuangan', {})
    info = ACADEMIC_DB.get('info_umum', {})

    # Keyword: IPK / Nilai
    if 'ipk' in user_input or 'nilai' in user_input:
        val = mahasiswa.get('ipk', 'N/A')
        return f"IPK Kumulatif kamu saat ini adalah **{val}**. Pertahankan ya!"

    # Keyword: Dosen Wali
    elif 'dosen wali' in user_input:
        dw = mahasiswa.get('dosen_wali', {})
        return f"Dosen wali kamu adalah **{dw.get('nama', 'N/A')}**. Kontak: {dw.get('email', 'N/A')}."

    # Keyword: Tagihan / Biaya / Keuangan
    elif 'tagihan' in user_input or 'biaya' in user_input or 'bayar' in user_input:
        tagihan = keuangan.get('tagihan_semester', 0)
        status = keuangan.get('status_pembayaran', 'N/A')
        va = keuangan.get('virtual_account', 'N/A')
        rp_tagihan = f"Rp {tagihan:,.0f}".replace(",", ".")
        return f"Status: **{status}**. Tagihan semester ini: **{rp_tagihan}**. VA: {va}."

    # Keyword: Jadwal
    elif 'jadwal' in user_input or 'kuliah' in user_input:
        jadwal_list = ACADEMIC_DB.get('jadwal_kuliah', [])
        target_hari = None
        for h in ["senin", "selasa", "rabu", "kamis", "jumat"]:
            if h in user_input:
                target_hari = h.capitalize()
                break
        
        if target_hari:
            jadwal_harian = [j for j in jadwal_list if j['hari'] == target_hari]
            if jadwal_harian:
                list_str = "\n".join([f"• {j['matkul']} ({j['jam']}) di {j['ruang']}" for j in jadwal_harian])
                return f"Jadwal kuliah hari **{target_hari}**:\n{list_str}"
            else:
                return f"Tidak ada jadwal kuliah di hari {target_hari}."
        else:
            # Default: Tampilkan jadwal hari ini (atau Senin sbg demo)
            jadwal_senin = [j for j in jadwal_list if j['hari'] == "Senin"]
            list_str = "\n".join([f"• {j['matkul']} ({j['jam']})" for j in jadwal_senin])
            return f"Ini jadwal hari Senin:\n{list_str}\n(Sebutkan nama hari untuk jadwal lain)"

    # Keyword: Cuti / Beasiswa
    elif 'cuti' in user_input:
        return info.get('syarat_cuti', 'Informasi cuti belum tersedia.')
    elif 'beasiswa' in user_input:
        return info.get('beasiswa', 'Informasi beasiswa belum tersedia.')

    # Jika tidak ada keyword yang cocok
    return None

def _get_public_response(user_input):
    """
    Mencari jawaban dari database publik (untuk tamu & mahasiswa).
    Menggunakan 'difflib' untuk mentolerir typo (fuzzy matching).
    """
    if not isinstance(PUBLIC_DB, list) or not PUBLIC_DB:
        return None

    questions = [item.get('question', '') for item in PUBLIC_DB]
    
    # Mencari 1 jawaban paling mirip dengan tingkat kemiripan minimal 60%
    matches = difflib.get_close_matches(user_input, questions, n=1, cutoff=0.6)
    
    if matches:
        best_match = matches[0]
        for item in PUBLIC_DB:
            if item.get('question') == best_match:
                return item.get('answer')
    
    return None

# --- Rute API (Endpoints) ---

# [CATATAN KEAMANAN]: 
# Login ini membandingkan password plaintext.
# Di aplikasi production, password harus di-hash (misal: bcrypt)
# dan database hanya menyimpan hash-nya, bukan password asli.
@app.route('/login', methods=['POST'])
def login():
    """
    Endpoint: /login
    Metode: POST
    Body: {"nim": "...", "password": "..."}
    Fungsi: Mengautentikasi pengguna berdasarkan data di USERS_DB.
    """
    data = request.json
    # Mencari user di DB global
    for user in USERS_DB:
        if user['nim'] == data.get('nim') and user['password'] == data.get('password'):
            return jsonify({'status': 'success', 'message': 'Login Berhasil', 'data': user})
    
    return jsonify({'status': 'error', 'message': 'NIM atau Password salah'}), 401

@app.route('/get_sessions', methods=['POST'])
def get_sessions():
    """
    Endpoint: /get_sessions
    Metode: POST
    Body: {"nim": "..."}
    Fungsi: Mengambil daftar (ringkasan) semua sesi chat milik seorang NIM.
    """
    nim = request.json.get('nim')
    all_history = load_json(HISTORY_FILE, default_type='list')
    
    user_data = next((item for item in all_history if item.get("nim") == nim), None)
    
    if user_data:
        # Hanya kirim ringkasan (tanpa isi chat) agar ringan
        summary = [
            {"id": s.get("id"), "title": s.get("title"), "date": s.get("last_updated")}
            for s in user_data.get("sessions", [])
        ]
        return jsonify({'status': 'success', 'data': summary})
    
    return jsonify({'status': 'success', 'data': []})

@app.route('/get_chat_detail', methods=['POST'])
def get_chat_detail():
    """
    Endpoint: /get_chat_detail
    Metode: POST
    Body: {"nim": "...", "session_id": "..."}
    Fungsi: Mengambil seluruh isi percakapan dari satu sesi yang spesifik.
    """
    nim = request.json.get('nim')
    session_id = request.json.get('session_id')
    
    all_history = load_json(HISTORY_FILE, default_type='list')
    user_data = next((item for item in all_history if item.get("nim") == nim), None)
    
    if user_data:
        session = next((s for s in user_data.get("sessions", []) if s.get("id") == session_id), None)
        if session:
            return jsonify({'status': 'success', 'data': session.get('messages', [])})
            
    return jsonify({'status': 'error', 'message': 'Sesi tidak ditemukan'}), 404

@app.route('/chat', methods=['POST'])
def chat():
    """
    Endpoint: /chat
    Metode: POST
    Body: {"message": "...", "role": "...", "nim": "...", "session_id": "..."}
    Fungsi: Endpoint utama untuk memproses pesan chat dari user.
    """
    req = request.json
    user_input = req.get('message', '').lower()
    role = req.get('role', 'guest')
    user_nim = req.get('nim', '')
    session_id = req.get('session_id', '') 

    response_text = None
    found = False

    # Prioritas 1: Cek data akademik (jika mahasiswa)
    if role == 'mahasiswa':
        response_text = _get_academic_response(user_input)
        if response_text:
            found = True

    # Prioritas 2: Cek data publik (jika P1 gagal atau jika user adalah 'guest')
    if not found:
        response_text = _get_public_response(user_input)
        if response_text:
            found = True

    # Fallback: Jika P1 dan P2 gagal
    if not response_text:
        response_text = "Maaf, saya belum mengerti. Coba tanya tentang IPK, Jadwal, atau Biaya."

    # Simpan riwayat HANYA jika mahasiswa
    if role == 'mahasiswa' and user_nim and session_id:
        save_session_message(user_nim, session_id, req.get('message'), response_text)

    return jsonify({'response': response_text, 'found': found})

# Menjalankan server
if __name__ == '__main__':
    # 'debug=True' dan 'host='0.0.0.0'' bagus untuk development lokal,
    # tapi tidak diperlukan saat deploy di PythonAnywhere.
    app.run()