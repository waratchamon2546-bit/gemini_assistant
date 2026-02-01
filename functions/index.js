const functions = require("firebase-functions");
const fetch = require("node-fetch");

// ❗ ใส่ Gemini API Key ใหม่ของคุณตรงนี้ (ชั่วคราว)
const GEMINI_API_KEY = "AIzaSyBE-bjwKwb5EJ2Vxo7PkQmth_A4leJFQmI";

// ใช้ Gemini 2.5 Flash
const GEMINI_ENDPOINT =
  "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent";

exports.askGemini = functions.https.onRequest(async (req, res) => {
  try {
    // เปิด CORS แบบง่าย (สำหรับ Flutter Web)
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    const message = req.body?.message;

    if (!message) {
      res.status(400).json({ error: "No message provided" });
      return;
    }

    const response = await fetch(
      `${GEMINI_ENDPOINT}?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [{ text: message }],
            },
          ],
        }),
      }
    );

    const data = await response.json();

    if (!response.ok) {
      console.error("Gemini error:", data);
      res.status(500).json({ error: data });
      return;
    }

    const reply =
      data.candidates?.[0]?.content?.parts?.[0]?.text ??
      "ขออภัย ไม่สามารถตอบได้ในขณะนี้";

    res.json({ reply });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.toString() });
  }
});
