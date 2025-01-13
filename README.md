**README: API Test with Robot Framework**

This document provides a comprehensive guide on creating a mock server using Flask, generating mock data, and writing automated tests using the Robot Framework. It includes examples for handling authentication, managing products, reviews, and orders, and implementing access control.

**1. Setting Up the Mock Server**

Prerequisites

Python 3.7 or higher

Flask (pip install flask)

Robot Framework (pip install robotframework)

Mock Server Code

The mock server handles authentication and routes for Products, Reviews, and Orders. The following endpoints are implemented:

Authentication Endpoints

POST /api/v1/auth/login: Log in a user.

GET /api/v1/auth/logout: Log out a user.

Product Endpoints

GET /api/v1/products: Retrieve all products.

POST /api/v1/products: Create a new product (admin only).

DELETE /api/v1/products/<id>: Delete a product by ID (admin only).

Review Endpoints

GET /api/v1/reviews: Retrieve all reviews.

GET /api/v1/reviews/<id>: Retrieve a single review by ID.

POST /api/v1/reviews: Create a new review.

PUT /api/v1/reviews/<id>: Update a review by ID.

DELETE /api/v1/reviews/<id>: Delete a review by ID.

Order Endpoints

GET /api/v1/orders: Retrieve all orders (admin only).

GET /api/v1/orders/<id>: Retrieve a single order by ID (admin only).

POST /api/v1/orders: Create a new order.

PUT /api/v1/orders/<id>: Update an order by ID (admin only).

DELETE /api/v1/orders/<id>: Delete an order by ID (admin only).

Running the Server

Save the mock server code to a file (e.g., mock_server.py).

Run the server:

python3 mock_server.py

The server will be available at http://127.0.0.1:5000.


**2. Access Control and Authentication**

Token-Based Authentication

Tokens are issued during login and are required for endpoints marked as "admin only."

Example tokens:

Admin: admin_token

User: user_token

Helper Functions

authenticate(token): Validates a token.

require_role(role, token): Ensures the token corresponds to a user with the specified role.

**3. Writing Tests in Robot Framework**

Setting Up Robot Framework

Install required libraries:

pip install requests robotframework-requests

Create a test file (e.g., orders_test.robot).

Example Test Cases

Orders

Get All Orders As Admin
    [Documentation]    Verify retrieving all orders as admin.
    
    ${headers}=    Set up Admin token
    ${response}=    GET    ${BASE_URL_ORDERS}    headers=${headers}
    Should Be Equal As Numbers    ${response.status_code}    200


**4. Common Issues and Troubleshooting**

Port Already in Use

Identify the process using the port:

lsof -i :5000

Kill the process:

kill -9 <PID>
