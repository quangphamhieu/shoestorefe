from flask import Flask, request, jsonify
from flask_cors import CORS
import google.generativeai as genai
import os
import logging
import requests
import json
import threading
import time
from datetime import datetime

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# API Key
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "AIzaSyDYwJ9RaetxzQU-6CDDq8U5SIRtqJUSeUo")
genai.configure(api_key=GEMINI_API_KEY)

MODEL_NAME = "gemini-2.5-flash"

# Config Logger
logging.basicConfig(level=logging.INFO)

# --- GLOBAL CONTEXT STORE ---
STORE_CONTEXT = {
    "products": [],
    "stores": [],
    "promotions": [],
    "policy": """
    CHÍNH SÁCH CỬA HÀNG:
    1. Đổi trả: Hỗ trợ đổi size trong vòng 7 ngày nếu giày chưa qua sử dụng. Không hỗ trợ trả hàng hoàn tiền trừ lỗi sản xuất.
    2. Bảo hành: Bảo hành keo chỉ 6 tháng.
    3. Giao hàng: Miễn phí ship cho đơn từ 500k. Khu vực nội thành 1-2 ngày, ngoại thành 3-4 ngày.
    """
}

# Backend API URL
BASE_API_URL = "https://localhost:7097/api"

# --- DATA FETCHING FUNCTIONS ---
def fetch_all_data():
    """Fetch Products, Stores, Promotions from Backend"""
    try:
        # 1. Fetch Stores
        stores = []
        try:
            r_store = requests.get(f"{BASE_API_URL}/Store", timeout=5, verify=False)
            if r_store.status_code == 200:
                raw_stores = r_store.json()
                for s in raw_stores:
                    s_id = s.get('id')
                    s_name = s.get('name')
                    s_address = s.get('address')
                    
                    # Logic for Warehouse vs Store
                    # StoreId=1 -> "Kho Online" (Backend term) -> UI/Chat term: "Mua Online"
                    display_name = "Mua Online (Website/App)" if s_id == 1 else f"Cửa hàng {s_name}"
                    
                    stores.append({
                        "id": s_id,
                        "name": display_name,
                        "address": s_address,
                        "is_online": s_id == 1
                    })
                STORE_CONTEXT["stores"] = stores
        except Exception as e:
            app.logger.error(f"Error fetching stores: {e}")

        # 2. Fetch Promotions
        promotions = []
        try:
            r_promo = requests.get(f"{BASE_API_URL}/Promotion", timeout=5, verify=False)
            if r_promo.status_code == 200:
                raw_promos = r_promo.json()
                
                for p in raw_promos:
                    # Basic info
                    p_name = p.get('name')
                    p_desc = p.get('description', '')
                    
                    # Store Scope
                    # PromotionDto has 'Stores' list or we check logic. 
                    # Assuming Dto has 'Stores' list based on previous step analysis or simplistic 'StoreId' if flat.
                    # The user mentioned "Store apply". Let's try to see if 'Stores' list exists or single 'StoreId'
                    # Based on PromotionDto.cs seen: List<PromotionStoreDto>? Stores.
                    p_stores = p.get('stores', [])
                    
                    applied_scopes = []
                    if not p_stores:
                        applied_scopes.append("toàn hệ thống")
                    else:
                        for ps in p_stores:
                            sid = ps.get('storeId')
                            if sid == 1:
                                applied_scopes.append("khi Mua Online")
                            else:
                                # Find store name
                                s_name = next((s['name'] for s in stores if s['id'] == sid), f"Store {sid}")
                                applied_scopes.append(f"tại {s_name}")
                    
                    scope_str = ", ".join(applied_scopes)

                    # Product Scope
                    p_products = p.get('products', [])
                    applied_products = []
                    if p_products:
                        for pp in p_products:
                            # PromotionProductDto likely has ProductName or ProductId
                            # Let's guess structure or just list count if huge.
                            # Ideally list names.
                            prod_name = pp.get('productName', f"Sản phẩm {pp.get('productId')}")
                            applied_products.append(prod_name)
                    
                    product_str = ", ".join(applied_products) if applied_products else "tất cả sản phẩm"

                    promotions.append(f"- Chương trình: {p_name}\n  + Ưu đãi: {p_desc}\n  + Áp dụng: {scope_str}\n  + Sản phẩm: {product_str}")
                    
                STORE_CONTEXT["promotions"] = promotions
        except Exception as e:
            app.logger.error(f"Error fetching promotions: {e}")

        # 3. Fetch Products (and availability)
        try:
            r_prod = requests.get(f"{BASE_API_URL}/Products", timeout=5, verify=False)
            if r_prod.status_code == 200:
                raw_prods = r_prod.json()
                products_summary = []
                for p in raw_prods:
                    name = p.get('name', 'Unknown')
                    price = p.get('originalPrice', 0)
                    desc = p.get('description', 'Không mô tả')
                    
                    # Availability logic
                    # ProductDto has List<StoreQuantityDto> Stores
                    p_stores = p.get('stores', [])
                    available_locs = []
                    
                    # Check Online (Id=1)
                    online_stock = next((s for s in p_stores if s['storeId'] == 1), None)
                    if online_stock and online_stock['quantity'] > 0:
                        available_locs.append("Online (Website)")
                        
                    # Check Physical
                    physical_stock = [s for s in p_stores if s['storeId'] != 1 and s['quantity'] > 0]
                    for s in physical_stock:
                        s_name = s.get('storeName') # StoreQuantityDto has StoreName
                        available_locs.append(s_name if s_name else f"Cửa hàng {s['storeId']}")
                    
                    stock_str = ", ".join(available_locs) if available_locs else "Hết hàng"

                    products_summary.append(f"- {name} | Giá: {price}đ | Có bán tại: {stock_str} | Link: [Xem {name}](/product-detail?name={name})")
                
                STORE_CONTEXT["products"] = products_summary
        except Exception as e:
            app.logger.error(f"Error fetching products: {e}")

        app.logger.info("Data refresh complete.")
        
    except Exception as e:
        app.logger.error(f"General error fetching data: {e}")

# Function to auto-refresh product data every hour
def start_background_fetch():
    def run():
        while True:
            fetch_all_data()
            time.sleep(3600) 
    thread = threading.Thread(target=run, daemon=True)
    thread.start()

start_background_fetch()

# --- SYSTEM INSTRUCTION ---
def get_system_instruction():
    store_list = [f"- {s['name']}: {s['address']}" for s in STORE_CONTEXT["stores"] if not s['is_online']]
    store_text = "\n".join(store_list)
    
    promo_text = "\n".join(STORE_CONTEXT["promotions"]) if STORE_CONTEXT["promotions"] else "Hiện không có chương trình khuyến mãi nào."
    product_text = "\n".join(STORE_CONTEXT["products"])
    policy_text = STORE_CONTEXT["policy"]
    
    return f"""
    Bạn là AI Assistant của cửa hàng giày 'ShoeStore'.
    
    NHIỆM VỤ:
    1. Tư vấn sản phẩm: Dựa vào nhu cầu và TÌNH TRẠNG KHO (Có bán tại đâu).
    2. Thông báo KHUYẾN MÃI: Phải nói rõ chương trình áp dụng "khi mua Online" hay "tại cửa hàng" nào, và áp dụng cho sản phẩm nào.
    3. Chỉ dẫn địa chỉ cửa hàng (chỉ liệt kê các cửa hàng vật lý).
    
    THUẬT NGỮ CẦN TUÂN THỦ:
    - Store ID 1 -> GỌI LÀ "khi mua Online" hoặc "trên Website". KHÔNG gọi là "kho online".
    - Các Store khác -> Gọi là "Cửa hàng + Tên".
    
    DỮ LIỆU CỬA HÀNG:
    {store_text}
    
    DANH SÁCH KHUYẾN MÃI (CHI TIẾT):
    {promo_text}
    
    DANH SÁCH SẢN PHẨM & KHO HÀNG:
    {product_text}
    
    CHÍNH SÁCH CHUNG:
    {policy_text}
    """

@app.route("/chat", methods=["POST"])
def chat():
    try:
        data = request.get_json(force=True, silent=True) or {}
        user_message = data.get("message", "")
        
        if not user_message:
            return jsonify({"error": "Missing 'message'"}), 400

        model = genai.GenerativeModel(
            MODEL_NAME,
            system_instruction=get_system_instruction()
        )

        chat_session = model.start_chat(history=[])
        response = chat_session.send_message(user_message)
        bot_text = getattr(response, "text", str(response))
        
        return jsonify({"response": bot_text}), 200

    except Exception as e:
        app.logger.exception("Error in /chat:")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    fetch_all_data()
    app.run(host="0.0.0.0", port=5000, debug=True)
