# SmartUTB Assistant 🎓

**SmartUTB Assistant** adalah aplikasi chatbot berbasis AI sederhana yang dirancang untuk membantu mahasiswa UTB mendapatkan informasi akademik secara cepat dan interaktif.

## 🚀 Fitur Utama
* **Chat Interaktif:** Tanya jawab seputar akademik (Jadwal, Ruang Dosen, Syarat Ujian).
* **Fuzzy Logic:** Dapat mengenali pertanyaan meski terdapat *typo* (salah ketik).
* **Teaching Mode:** User dapat mengajari bot jawaban baru jika bot tidak mengetahui jawabannya, data langsung tersimpan ke `data.json`.
* **Multi-Session:** Mendukung banyak sesi percakapan sekaligus.

## 🛠️ Teknologi
* **Frontend:** Flutter (Dart)
* **Backend:** Python (Flask)
* **Database:** JSON (Simple Knowledge Base)

## 📸 Cara Menjalankan
1. Jalankan Backend: `cd backend && python app.py`
2. Jalankan Frontend: `cd frontend && flutter run`