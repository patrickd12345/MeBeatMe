export default function handler(req, res) {
  res.status(200).json({ 
    message: "Simple API test - " + new Date().toISOString(),
    working: true 
  });
}
