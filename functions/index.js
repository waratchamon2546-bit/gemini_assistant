const functions = require("firebase-functions");
const admin = require("firebase-admin");

process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";

admin.initializeApp({
  projectId: "apppppppp-159fd",
});

const db = admin.firestore();

/* ===============================
   KEYWORD → SYMPTOM MAP
================================ */
const SYMPTOM_KEYWORDS = [
  "ไข้สูง",
  "ไข้",
  "อาเจียน",
  "ปวดท้อง",
  "ไอ",
  "น้ำมูก",
  "ซึม",
];

/* ===============================
   MAIN TEST FUNCTION
================================ */
exports.askGemini = functions.https.onRequest(async (req, res) => {
  try {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    const message = req.body?.message || "";
    console.log("👤 User message:", message);

    /* ---------- 1. Extract symptoms (NO AI) ---------- */
    const extractedSymptoms = SYMPTOM_KEYWORDS.filter((s) =>
      message.includes(s)
    );

    console.log("🧪 Extracted symptoms:", extractedSymptoms);

    if (extractedSymptoms.length === 0) {
      res.json({
        reply: "❌ ไม่พบอาการที่รู้จัก (ทดสอบ extract)",
      });
      return;
    }

    /* ---------- 2. Query Firestore ---------- */
    console.log("🔍 Querying Firestore with:", extractedSymptoms);

    const snapshot = await db
      .collection("diseases")
      .where("symptoms", "array-contains-any", extractedSymptoms)
      .get();

    if (snapshot.empty) {
      console.log("❌ NO MATCH IN FIRESTORE");
      res.json({
        reply: "❌ ไม่พบข้อมูลโรคใน Firestore",
      });
      return;
    }

    const disease = snapshot.docs[0].data();

    console.log("🔥 FOUND FROM FIRESTORE:", disease.name);

    /* ---------- 3. Reply (TEST) ---------- */
    res.json({
      reply: `🔥 ดึงจาก Firestore สำเร็จ\nโรค: ${disease.name}\nการดูแล: ${disease.care}`,
      disease,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.toString() });
  }
});
