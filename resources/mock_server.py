from flask import Flask, request, jsonify

app = Flask(__name__)

# Mock Data
users = [
    {"id": 1, "email": "admin@example.com", "name": "Admin User", "password": "admin123", "role": "admin"},
    {"id": 2, "email": "user@example.com", "name": "Normal User", "password": "user123", "role": "user"}
]
tokens = {"admin_token": "admin", "user_token": "user"}  # Mock tokens for simplicity
products = [
    {"id": 1, "name": "Product A", "price": 10.99},
    {"id": 2, "name": "Product B", "price": 20.99},
]
reviews = [
    {"id": 1, "product_id": 1, "review": "Great product!", "rating": 5},
    {"id": 2, "product_id": 2, "review": "Not bad", "rating": 3},
]

orders = [
    {"id": 1, "product_id": 1, "user_id": 2, "quantity": 2, "status": "Pending"},
    {"id": 2, "product_id": 2, "user_id": 2, "quantity": 1, "status": "Shipped"},
]

# Helper Functions
# def authenticate(token):
#     """Check if the token is valid."""
#     if token in tokens:
#         return tokens[token]
#     return None

def authenticate(token):
    """Check if the token is valid."""
    token = token.replace("Bearer ", "") if token else None
    if token in tokens:
        return tokens[token]
    return None

def require_role(required_role, token):
    """Check if the token belongs to a user with the required role."""
    role = authenticate(token)
    if role == required_role:
        return True
    return False

# Authentication Endpoints
@app.route('/api/v1/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    print(data)
    if not data or "email" not in data or "password" not in data:
        return jsonify({"error": "Missing required fields: 'email' and 'password'"}), 400
    # print(data)
    user = next((u for u in users if u["email"] == data["email"] and u["password"] == data["password"]), None)
    if not user:
        return jsonify({"error": "Invalid credentials"}), 401
    print(user)
    token = f"{user['role']}_token"  # Mock token generation
    print(token)
    return jsonify({"message": "Login successful", "token": token}), 200

@app.route('/api/v1/auth/logout', methods=['GET'])
def logout():
    token = request.headers.get("Authorization")
    if not token:
        return jsonify({"error": "Authorization token missing"}), 401

    user_role = authenticate(token)
    if not user_role:
        return jsonify({"error": "Invalid or expired token"}), 403

    # Invalidate the token (mock behavior - simply return a success message)
    return jsonify({"message": "Logout successful"}), 200


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
    

@app.route('/api/v1/products', methods=['GET'])
def get_products():
    return jsonify(products), 200

@app.route('/api/v1/products', methods=['POST'])
def create_product():
    token = request.headers.get("Authorization")
    if not require_role("admin", token):
        return jsonify({"error": "Unauthorized. Admin access required"}), 403

    data = request.get_json()
    if not data or "name" not in data or "price" not in data:
        return jsonify({"error": "Missing required fields: 'name' and 'price'"}), 400
    new_product = {
        "id": len(products) + 1,
        "name": data["name"],
        "price": data["price"]
    }
    products.append(new_product)
    return jsonify(new_product), 201

@app.route('/api/v1/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    token = request.headers.get("Authorization")
    if not require_role("admin", token):
        return jsonify({"error": "Unauthorized. Admin access required"}), 403

    global products
    product = next((p for p in products if p["id"] == product_id), None)
    if not product:
        return jsonify({"error": f"Product with id {product_id} not found"}), 404
    products = [p for p in products if p["id"] != product_id]
    return jsonify({"message": f"Product with id {product_id} deleted successfully"}), 200

# Reviews Endpoints (Accessible to All)
@app.route('/api/v1/reviews', methods=['GET'])
def get_reviews():
    return jsonify(reviews), 200


@app.route('/api/v1/reviews/<int:review_id>', methods=['GET'])
def get_review_by_id(review_id):
    review = next((r for r in reviews if r["id"] == review_id), None)
    if not review:
        return jsonify({"error": f"Review with id {review_id} not found"}), 404
    return jsonify(review), 200

@app.route('/api/v1/reviews', methods=['POST'])
def create_review():
    data = request.get_json()
    if not data or "product_id" not in data or "review" not in data or "rating" not in data:
        return jsonify({"error": "Missing required fields: 'product_id', 'review', and 'rating'"}), 400
    new_review = {
        "id": len(reviews) + 1,
        "product_id": data["product_id"],
        "review": data["review"],
        "rating": data["rating"]
    }
    reviews.append(new_review)
    return jsonify(new_review), 201

@app.route('/api/v1/reviews/<int:review_id>', methods=['PUT'])
def update_review(review_id):
    data = request.get_json()
    review = next((r for r in reviews if r["id"] == review_id), None)
    if not review:
        return jsonify({"error": f"Review with id {review_id} not found"}), 404

    review.update({
        "review": data.get("review", review["review"]),
        "rating": data.get("rating", review["rating"])
    })
    return jsonify(review), 200

@app.route('/api/v1/reviews/<int:review_id>', methods=['DELETE'])
def delete_review(review_id):
    global reviews
    review = next((r for r in reviews if r["id"] == review_id), None)
    if not review:
        return jsonify({"error": f"Review with id {review_id} not found"}), 404
    reviews = [r for r in reviews if r["id"] != review_id]
    return jsonify({"message": f"Review with id {review_id} deleted successfully"}), 200

@app.route('/api/v1/orders', methods=['GET'])
def get_orders():
    token = request.headers.get("Authorization")
    if not require_role("admin", token):
        return jsonify({"error": "Unauthorized. Admin access required"}), 403
    return jsonify(orders), 200

@app.route('/api/v1/orders/<int:order_id>', methods=['GET'])
def get_order_by_id(order_id):
    token = request.headers.get("Authorization")
    if not require_role("admin", token):
        return jsonify({"error": "Unauthorized. Admin access required"}), 403
    order = next((o for o in orders if o["id"] == order_id), None)
    if not order:
        return jsonify({"error": f"Order with id {order_id} not found"}), 404
    return jsonify(order), 200

@app.route('/api/v1/orders', methods=['POST'])
def create_order():
    data = request.get_json()
    if not data or "product_id" not in data or "user_id" not in data or "quantity" not in data:
        return jsonify({"error": "Missing required fields: 'product_id', 'user_id', and 'quantity'"}), 400
    new_order = {
        "id": len(orders) + 1,
        "product_id": data["product_id"],
        "user_id": data["user_id"],
        "quantity": data["quantity"],
        "status": data.get("status", "Pending"),
    }
    orders.append(new_order)
    return jsonify(new_order), 201

@app.route('/api/v1/orders/<int:order_id>', methods=['PUT'])
def update_order(order_id):
    token = request.headers.get("Authorization")
    if not require_role("admin", token):
        return jsonify({"error": "Unauthorized. Admin access required"}), 403
    data = request.get_json()
    order = next((o for o in orders if o["id"] == order_id), None)
    if not order:
        return jsonify({"error": f"Order with id {order_id} not found"}), 404
    order.update({
        "quantity": data.get("quantity", order["quantity"]),
        "status": data.get("status", order["status"]),
    })
    return jsonify(order), 200

@app.route('/api/v1/orders/<int:order_id>', methods=['DELETE'])
def delete_order(order_id):
    token = request.headers.get("Authorization")
    if not require_role("admin", token):
        return jsonify({"error": "Unauthorized. Admin access required"}), 403
    global orders
    order = next((o for o in orders if o["id"] == order_id), None)
    if not order:
        return jsonify({"error": f"Order with id {order_id} not found"}), 404
    orders = [o for o in orders if o["id"] != order_id]
    return jsonify({"message": f"Order with id {order_id} deleted successfully"}), 200

if __name__ == "__main__":
    app.run(port=5000)
