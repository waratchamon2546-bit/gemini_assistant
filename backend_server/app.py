import os
import google.generativeai as genai
from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore

app = Flask(__name__)
CORS(app)

# 1. Firebase
base_path = os.path.dirname(os.path.abspath(__file__))
cred_path = os.path.join(base_path, 'serviceAccountKey.json')
if not firebase_admin._apps:
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
db = firestore.client()

# 2. Gemini 
genai.configure(api_key="AIzaSyCa28K5GaSqCiQC2bv2113UNf8efUmlVK4")
model = genai.GenerativeModel('gemini-2.5-flash')

def get_medical_context(user_input):
    context = ""
    try:
        docs = db.collection('diseases').stream()
        for doc in docs:
            d = doc.to_dict()
            if any(s in user_input for s in d.get('symptoms', [])):
                context += f"\nโรค: {d['name']}\nการดูแล: {d['care']}\nอาการอันตราย: {d['red_flags']}\nอ้างอิง: {d.get('link', '')}\n"
        return context
    except Exception as e:
        print(f"Firebase Error: {e}")
        return ""

@app.route('/analyze', methods=['POST'])
def analyze():
    data = request.json
    user_message = data.get('message', '')
    medical_info = get_medical_context(user_message)

    # Prompt 
    prompt = f"""
    คุณคือผู้ช่วยกุมารแพทย์ (AI Assistant)
    กฎเหล็กในการตอบ:
    1. วิเคราะห์อาการเบื้องต้นและถามทีละ 1 คำถามเท่านั้น
    2. หากต้องถามอายุ ต้องมีคำว่า [อายุ] ในประโยคเสมอ
    3. หากต้องถามเรื่องไข้หรืออุณหภูมิ ต้องมีคำว่า [ไข้] ในประโยคเสมอ
    4. หากต้องถามเพศ ต้องมีคำว่า [เพศ] ในประโยคเสมอ
    5. ใช้ข้อมูลอ้างอิงนี้: {medical_info}
    6. หากมีอาการอันตราย ให้เตือนให้ไปโรงพยาบาลทันที
    7. เมื่อจบการซักถามและสรุปผล ให้แนบลิงก์ 'อ้างอิง' เสมอ

    คำถามจากผู้ปกครอง: {user_message}
    """

    try:
        response = model.generate_content(prompt)
        return jsonify({"reply": response.text})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
