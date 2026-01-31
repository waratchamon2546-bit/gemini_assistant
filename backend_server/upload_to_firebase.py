import firebase_admin
from firebase_admin import credentials, firestore
import json
import os

# --- ส่วนของการตั้งค่า Path ---
# หาที่อยู่ของโฟลเดอร์ปัจจุบันที่ไฟล์นี้วางอยู่
base_path = os.path.dirname(os.path.abspath(__file__))
key_path = os.path.join(base_path, 'serviceAccountKey.json')
json_path = os.path.join(base_path, 'diseases.json')

print(f"--- เริ่มต้นการทำงาน ---")
print(f"ตรวจพบตำแหน่งไฟล์กุญแจ: {key_path}")
print(f"ตรวจพบตำแหน่งไฟล์ข้อมูล: {json_path}")

try:
    # 1. เชื่อมต่อ Firebase
    if not firebase_admin._apps:
        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("✅ เชื่อมต่อ Firebase สำเร็จ")

    # 2. อ่านไฟล์ JSON
    if not os.path.exists(json_path):
        print(f"❌ ผิดพลาด: ไม่พบไฟล์ {json_path}")
    else:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # 3. เริ่มการอัปโหลด
        diseases_list = data.get('diseases', [])
        print(f"พบข้อมูลโรคทั้งหมด {len(diseases_list)} รายการ")

        for disease in diseases_list:
            name = disease.get('name')
            if name:
                # บันทึกลงคอลเลกชัน 'diseases' โดยใช้ชื่อโรคเป็น ID
                db.collection('diseases').document(name).set(disease)
                print(f"   - อัปโหลดโรค '{name}' เรียบร้อย")

        print("--- ✅ อัปโหลดข้อมูลเสร็จสมบูรณ์ 100% ---")

except Exception as e:
    print(f"❌ เกิดข้อผิดพลาดร้ายแรง: {e}")