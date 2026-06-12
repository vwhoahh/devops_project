from flask import Flask, render_template

app = Flask(__name__)

PRODUCTS = [
    {"id": 1, "name": "Laptop",      "price": 55000, "icon": "💻"},
    {"id": 2, "name": "Smartphone",  "price": 30000, "icon": "📱"},
    {"id": 3, "name": "Headphones",  "price": 3000,  "icon": "🎧"},
]

ENV = "BLUE"
VERSION = "1"

@app.route("/")
def home():
    return render_template("index.html", products=PRODUCTS, env=ENV, version=VERSION)

@app.route("/cart")
def cart():
    return render_template("cart.html", env=ENV, version=VERSION)

@app.route("/checkout")
def checkout():
    return render_template("checkout.html", env=ENV, version=VERSION)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
