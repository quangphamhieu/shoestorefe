from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai
import os
import logging

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # allow CORS for all origins (adjust in production)

# Load API key từ biến môi trường hoặc gán trực tiếp
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "AIzaSyD0eVAQzf8RaFdwnp554oRmyolMHMdJ8zE")
genai.configure(api_key=GEMINI_API_KEY)

MODEL_NAME= "gemini-2.5-flash"

# setup logger
logging.basicConfig(level=logging.INFO)

@app.route("/chat", methods=["POST"])
def chat():
    try:
        data = request.get_json(force=True, silent=True) or {}
        user_message = data.get("message", "")
        app.logger.info("Received /chat POST: %s", user_message)

        if not user_message:
            return jsonify({"error": "Missing 'message'"}), 400

        model = genai.GenerativeModel(MODEL_NAME)

        response = model.generate_content(user_message)

        # response may have .text or other structure; try to extract text safely
        bot_text = getattr(response, "text", None)
        if bot_text is None:
            # fallback to str(response)
            bot_text = str(response)

        app.logger.info("Responding with: %s", bot_text)
        return jsonify({"response": bot_text}), 200

    except Exception as e:
        app.logger.exception("Error in /chat:")
        return jsonify({"error": str(e)}), 500


# Run server
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
