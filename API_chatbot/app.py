from flask import Flask, request, jsonify
from flask_cors import CORS
# Load .env variables
from dotenv import load_dotenv
load_dotenv()

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

# API Key - Get from Environment Variable
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    app.logger.warning("GEMINI_API_KEY not found in environment variables.")

genai.configure(api_key=GEMINI_API_KEY)

MODEL_NAME = "gemini-2.5-flash"

# Config Logger
logging.basicConfig(level=logging.INFO)

# --- GLOBAL CONTEXT STORE ---
STORE_CONTEXT = {
    "products": [],
    "stores": [],
    "promotions": [],
    "brands": [],
    "top_selling_products": [],
    "top_brands": [],
    "policy": """
    CHÍNH SÁCH CỬA HÀNG:
    1. Đổi trả: Hỗ trợ đổi size trong vòng 7 ngày nếu giày chưa qua sử dụng. Không hỗ trợ trả hàng hoàn tiền trừ lỗi sản xuất.
    2. Bảo hành: Bảo hành keo chỉ 6 tháng.
    3. Giao hàng: Miễn phí ship cho đơn từ 500k. Khu vực nội thành 1-2 ngày, ngoại thành 3-4 ngày.
    """
}

# Backend API URL
BASE_API_URL = "https://helloshoestore.runasp.net/api"

# --- DATA FETCHING FUNCTIONS ---
def fetch_all_data():
    """Fetch Products, Stores, Promotions, Brands, and Stats from Backend"""
    try:
        app.logger.info("Starting data fetch...")
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }

        # 1. Fetch Brands FIRST (to map BrandId -> Name)
        brand_map = {}
        try:
            r_brand = requests.get(f"{BASE_API_URL}/brands", headers=headers, timeout=10, verify=False)
            if r_brand.status_code == 200:
                raw_brands = r_brand.json()
                for b in raw_brands:
                    brand_map[b.get('id')] = b.get('name')
                
                STORE_CONTEXT["brands"] = list(brand_map.values())
        except Exception as e:
             app.logger.error(f"Error fetching brands: {e}")

        # 2. Fetch Stores
        stores = []
        try:
            r_store = requests.get(f"{BASE_API_URL}/store", headers=headers, timeout=10, verify=False)
            if r_store.status_code == 200:
                raw_stores = r_store.json()
                for s in raw_stores:
                    s_id = s.get('id')
                    s_name = s.get('name')
                    s_address = s.get('address')
                    
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

        # 3. Fetch Promotions
        promotions = []
        try:
            r_promo = requests.get(f"{BASE_API_URL}/promotion", headers=headers, timeout=10, verify=False)
            if r_promo.status_code == 200:
                raw_promos = r_promo.json()
                
                for p in raw_promos:
                    p_name = p.get('name')
                    p_desc = p.get('description', '') or 'Ưu đãi đặc biệt'
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
                                s_name = next((s['name'] for s in stores if s['id'] == sid), f"Store {sid}")
                                applied_scopes.append(f"tại {s_name}")
                    
                    scope_str = ", ".join(applied_scopes)

                    p_products = p.get('products', [])
                    applied_products = []
                    if p_products:
                        for pp in p_products:
                            prod_name = pp.get('productName', f"Sản phẩm {pp.get('productId')}")
                            applied_products.append(prod_name)
                    
                    product_str = ", ".join(applied_products) if applied_products else "tất cả sản phẩm"

                    promotions.append(f"- Chương trình: {p_name}\n  + Ưu đãi: {p_desc}\n  + Áp dụng: {scope_str}\n  + Sản phẩm: {product_str}")
                    
                STORE_CONTEXT["promotions"] = promotions
        except Exception as e:
            app.logger.error(f"Error fetching promotions: {e}")

        # 4. Fetch Products
        try:
            r_prod = requests.get(f"{BASE_API_URL}/products", headers=headers, timeout=10, verify=False)
            if r_prod.status_code == 200:
                raw_prods = r_prod.json()
                products_summary = []
                for p in raw_prods:
                    name = p.get('name', 'Unknown')
                    original_price = p.get('originalPrice', 0)
                    brand_id = p.get('brandId')
                    brand_name = brand_map.get(brand_id, 'Unknown')
                    
                    p_stores = p.get('stores', [])
                    
                    # --- 1. Stock Availability & Discount Logic ---
                    available_locs = []
                    
                    # Find lowest valid price across in-stock stores
                    min_price = original_price
                    discount_info = [] # List of locations offering the discounted price

                    for s in p_stores:
                        s_id = s.get('storeId')
                        s_qty = s.get('quantity', 0)
                        # Ensure salePrice is valid; if 0 or None, fallback to original_price could be risky if API returns 0.
                        # Assuming API returns correct SalePrice or equals OriginalPrice if no sale.
                        # Some APIs return 0 if no sale price defined. Let's handle safe fallback.
                        s_price = s.get('salePrice')
                        if s_price is None: s_price = original_price
                        
                        s_name = "Online" if s_id == 1 else s.get('storeName', f"CH {s_id}")

                        if s_qty > 0:
                            available_locs.append(s_name)
                            
                            # Check for better price
                            if s_price < min_price:
                                min_price = s_price
                                discount_info = [s_name]
                            elif s_price == min_price and s_price < original_price:
                                discount_info.append(s_name)
                    
                    stock_str = ", ".join(available_locs) if available_locs else "Hết hàng"
                    
                    # --- 2. Format Price String ---
                    if min_price < original_price:
                        # Discount detected
                        places = ", ".join(discount_info)
                        price_str = f"GIÁ GỐC: {original_price:,.0f}đ -> GIẢM CÒN: {min_price:,.0f}đ (Áp dụng tại: {places})"
                    else:
                        price_str = f"{original_price:,.0f}đ"
                    
                    import urllib.parse
                    encoded_name = urllib.parse.quote(name)
                    link = f"https://helloshoestore.web.app/#/product-detail/{encoded_name}"
                    
                    products_summary.append(f"- {name} ({brand_name}) | Giá: {price_str} | Kho: {stock_str} | Link: [Xem]({link})")
                
                STORE_CONTEXT["products"] = products_summary
        except Exception as e:
            app.logger.error(f"Error fetching products: {e}")

        # 5. Fetch Dashboard Stats (Top Selling & Trends)
        try:
            # Use monthCount=1 to get "Current/Recent" trends (last 30 days)
            r_dash = requests.get(f"{BASE_API_URL}/dashboard?months=1", headers=headers, timeout=10, verify=False)
            if r_dash.status_code == 200:
                data = r_dash.json()
                
                # Top Products
                top_prods = data.get("topProducts", [])
                STORE_CONTEXT["top_selling_products"] = [
                    f"{p['productName']} (Đã bán: {p['quantitySold']})" for p in top_prods
                ]

                # Top Brands
                top_brands = data.get("topBrands", [])
                STORE_CONTEXT["top_brands"] = [
                    f"{b['brandName']} (Đã bán: {b['quantitySold']})" for p in top_brands
                ]
        except Exception as e:
            app.logger.error(f"Error fetching dashboard stats: {e}")

        app.logger.info("Data refresh complete.")
        
    except Exception as e:
        app.logger.error(f"General error fetching data: {e}")

# Function to auto-refresh product data every day (24h)
def start_background_fetch():
    def run():
        # Wait a bit for server to be fully ready if needed, or run immediately
        app.logger.info("Starting background data fetch loop...")
        while True:
            app.logger.info("Executing periodic data fetch...")
            fetch_all_data()
            app.logger.info("Data fetch complete. Waiting 24 hours...")
            time.sleep(86400) 
    thread = threading.Thread(target=run, daemon=True)
    thread.start()

start_background_fetch()

# --- SYSTEM INSTRUCTION ---
def get_system_instruction():
    store_list = [f"- {s['name']}: {s['address']}" for s in STORE_CONTEXT["stores"] if not s['is_online']]
    store_text = "\n".join(store_list)
    
    promo_text = "\n".join(STORE_CONTEXT["promotions"]) if STORE_CONTEXT["promotions"] else "Hiện không có chương trình khuyến mãi nào."
    product_text = "\n".join(STORE_CONTEXT["products"])
    
    brand_list = ", ".join(STORE_CONTEXT["brands"])
    top_selling_text = "\n".join(STORE_CONTEXT["top_selling_products"]) if STORE_CONTEXT["top_selling_products"] else "Chưa có dữ liệu."
    top_brand_text = "\n".join(STORE_CONTEXT["top_brands"]) if STORE_CONTEXT["top_brands"] else "Chưa có dữ liệu."
    
    policy_text = STORE_CONTEXT["policy"]
    
    return f"""
    Bạn là AI Assistant thông minh của hệ thống cửa hàng giày 'ShoeStore'.
    
    DỮ LIỆU THỜI GIAN THỰC (Đã được cập nhật từ hệ thống):
    
    1. DANH SÁCH CỬA HÀNG VẬT LÝ:
    {store_text}
    
    2. CÁC THƯƠNG HIỆU ĐANG KINH DOANH:
    {brand_list}
    
    3. TOP SẢN PHẨM BÁN CHẠY (TRENDING):
    {top_selling_text}
    
    4. THƯƠNG HIỆU ĐƯỢC ƯA CHUỘNG NHẤT:
    {top_brand_text}
    
    5. CHƯƠNG TRÌNH KHUYẾN MÃI HIỆN CÓ:
    {promo_text}
    
    6. DANH SÁCH SẢN PHẨM, GIÁ & TÌNH TRẠNG KHO:
    {product_text}
    
    7. CHÍNH SÁCH CHUNG:
    {policy_text}
    
    NHIỆM VỤ CỦA BẠN:
    - Trả lời các câu hỏi về sản phẩm, giá cả, tình trạng còn hàng.
    - ĐẶC BIỆT CHÚ Ý VỀ GIÁ: Dữ liệu số 6 có ghi rõ "GIÁ GỐC -> GIẢM CÒN". Nếu thấy dòng này, bạn BẮT BUỘC phải thông báo cho khách: "Sản phẩm này đang được giảm giá từ X xuống còn Y, áp dụng tại [Cửa hàng/Online]". KHÔNG ĐƯỢC chỉ đưa giá gốc.
    - Nếu khách hỏi sản phẩm cụ thể, hãy kiểm tra danh sách số 6. Nếu có, cung cấp link mua hàng.
    - Nếu khách hỏi chung chung, hãy dùng dữ liệu số 3 và 4 để gợi ý.
    
    YÊU CẦU TRẢ LỜI:
    - Luôn dùng tiếng Việt, giọng điệu chuyên nghiệp, thân thiện.
    - Định dạng câu trả lời rõ ràng, dùng in đậm (**text**) cho tên sản phẩm và GIÁ GIẢM (nếu có).
    - Chỉ tư vấn sản phẩm có trong danh sách.
    """

@app.route("/chat", methods=["POST"])
def chat():
    try:
        # Lazy load if data is missing (handles first request or worker startup)
        if not STORE_CONTEXT["products"]:
             app.logger.info("Context empty. Triggering immediate fetch...")
             fetch_all_data()

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

@app.route("/debug", methods=["GET"])
def debug_data():
    """Debug endpoint to check what data the AI actually has"""
    try:
        # Trigger an immediate fetch if empty
        if not STORE_CONTEXT["products"]:
            fetch_all_data()

        status = {
            "products_count": len(STORE_CONTEXT["products"]),
            "stores_count": len(STORE_CONTEXT["stores"]),
            # Show actual list names for debugging
            "stores_list": [s['name'] for s in STORE_CONTEXT["stores"]],
            "promotions_count": len(STORE_CONTEXT["promotions"]),
            "promotions_list": STORE_CONTEXT["promotions"], 
            "brands_list": STORE_CONTEXT["brands"],
            "sample_product": STORE_CONTEXT["products"][0] if STORE_CONTEXT["products"] else "None",
            "backend_url": BASE_API_URL,
            "last_error": "Check logs"
        }
        return jsonify(status), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    fetch_all_data()
    app.run(host="0.0.0.0", port=5000, debug=True)
