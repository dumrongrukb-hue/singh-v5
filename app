# ========== สิงห์ 1 ===========
# เซียนจัด v.5 FULL GOLD/SILVER
# WebApp เวอร์ชันไฟล์เดียว (Mobile Ready)
# ==============================

import streamlit as st
import pandas as pd
import random
import numpy as np
from collections import Counter, defaultdict

# =======================
# CONFIG
# =======================
CHECK_N = 5
MAX_PER_PATTERN = 500

st.set_page_config(
    page_title="🦁 เซียนจัด v.5",
    page_icon="🦁",
    layout="centered"
)

st.title("🦁 เซียนจัด v.5 FULL GOLD / SILVER")
st.caption("เวอร์ชัน WebApp • ใช้ได้บนมือถือ")

# =======================
# 📱 INPUT 6 งวด
# =======================
st.subheader("📥 กรอกผลหวยย้อนหลัง 6 งวด")

tops = []
bots = []

for i in range(6):
    c1, c2 = st.columns(2)
    with c1:
        t = st.text_input(
            f"บน งวดที่ {i+1}",
            max_chars=3,
            placeholder="เช่น 461",
            key=f"top{i}"
        )
    with c2:
        b = st.text_input(
            f"ล่าง งวดที่ {i+1}",
            max_chars=2,
            placeholder="เช่น 41",
            key=f"bot{i}"
        )
    tops.append(t)
    bots.append(b)

# =======================
# ENGINE
# =======================
def get_vars(df, i):
    t = df.loc[i, "บน"]
    b = df.loc[i, "ล่าง"]
    return {
        "r": int(t[0]),
        "a": int(t[1]),
        "b": int(t[2]),
        "c": int(b[0]),
        "d": int(b[1]),
        "บน": t,
        "ล่าง": b
    }

def calc(expr, v):
    try:
        return abs(eval(expr, {}, v))
    except Exception:
        return None

def last_digit(val):
    return int(str(val)[-1])

def random_term():
    return f"({random.choice(['r','a','b','c','d'])}{random.choice(['+','-','*'])}{random.randint(2,9)})"

def random_formula(depth=5):
    if depth == 1:
        return random_term()
    return f"({random_formula(depth-1)}{random.choice(['+','-','*'])}{random_term()})"

def normalize_formula(expr):
    s = expr.replace(" ", "")
    if "*0" in s or "*1" in s or s.count("*") >= 2:
        return None
    return s

def strict_check(df, expr):
    pattern = []
    for i in range(CHECK_N):
        v = get_vars(df, i)
        raw = calc(expr, v)
        if raw is None:
            return False, None, None
        res = last_digit(raw)
        nxt = get_vars(df, i + 1)
        if res in map(int, nxt["บน"][1:]):
            side = "B"
        elif res in map(int, nxt["ล่าง"]):
            side = "L"
        else:
            return False, None, None
        pattern.append(side)
    v_next = get_vars(df, CHECK_N)
    return True, "".join(pattern), last_digit(calc(expr, v_next))

def run_engine_v5(df, target=1000):  # ลด target กันมือถือค้าง
    seen = set()
    pattern_map = defaultdict(list)

    with st.spinner("⏳ กำลังคำนวณสูตรสายดุ..."):
        while sum(len(v) for v in pattern_map.values()) < target:
            f = random_formula()
            nf = normalize_formula(f)
            if nf in seen:
                continue
            ok, pat, p = strict_check(df, f)
            if not ok:
                continue
            seen.add(nf)
            pattern_map[pat].append(p)

    final_focus = Counter()
    for v in pattern_map.values():
        for n in v:
            final_focus[n] += 1

    return final_focus

# =======================
# ▶️ RUN
# =======================
st.divider()

if st.button("🚀 เริ่มคำนวณ", use_container_width=True):
    try:
        tops_f = [x.zfill(3) for x in tops]
        bots_f = [x.zfill(2) for x in bots]

        if not all(x.isdigit() for x in tops_f + bots_f):
            st.error("❌ ต้องกรอกตัวเลขให้ครบทุกช่อง")
        else:
            df = pd.DataFrame({
                "บน": tops_f,
                "ล่าง": bots_f
            })

            st.success("✅ ข้อมูลพร้อมคำนวณ")
            st.dataframe(df, use_container_width=True)

            result = run_engine_v5(df)

            st.subheader("📊 สรุปเลขเด่นทั้งหมด")
            for n, c in result.most_common():
                st.write(f"🔸 เลข {n} → {c} ครั้ง")

       except Exception as e:
        st.error(f"เกิดข้อผิดพลาด: {e}")

st.caption("© สิงห์ 1 • v.5 Mobile WebApp")


