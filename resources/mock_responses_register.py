from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/api/v1/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    if data["email"] == "existinguser@example.com":
        return jsonify({"error": "A user with this email already exists."}), 409
    return jsonify({
        "id": 1,
        "email": data["email"],
        "name": data.get("name", "Unknown"),
        "message": "User registered successfully."
    }), 201

if __name__ == "__main__":
    app.run(port=5000)