const admin = require("firebase-admin");
const data = require("../backend_server/diseases.json");


process.env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:8080";

if (!data.diseases || !Array.isArray(data.diseases)) {
  console.error("❌ diseases.json must contain { diseases: [] }");
  process.exit(1);
}

/* ===============================
   3. INIT FIREBASE ADMIN
================================ */
admin.initializeApp({
  projectId: "apppppppp-159fd", // ใส่ให้ตรงกับ emulator project
});

const db = admin.firestore();

/* ===============================
   4. IMPORT DATA
================================ */
async function importDiseases() {
  console.log("🔥 Importing diseases to Firestore Emulator...");
  console.log("Project:", admin.app().options.projectId);
  console.log("Total diseases:", data.diseases.length);

  const batch = db.batch();

  data.diseases.forEach((disease, index) => {
    // validate minimal schema
    if (
      !disease.name ||
      !Array.isArray(disease.symptoms) ||
      !disease.care
    ) {
      console.warn(`⚠️ Skip invalid disease at index ${index}`);
      return;
    }

    const ref = db.collection("diseases").doc();
    batch.set(ref, {
      name: disease.name,
      symptoms: disease.symptoms,
      care: disease.care,
      red_flags: disease.red_flags || "",
      link: disease.link || "",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log("✅ Diseases imported to Firestore Emulator");
}

/* ===============================
   5. RUN
================================ */
importDiseases()
  .then(() => {
    console.log("🎉 DONE");
    process.exit(0);
  })
  .catch((err) => {
    console.error("❌ Import failed:", err);
    process.exit(1);
  });