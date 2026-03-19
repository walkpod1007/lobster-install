---
vcard_id: 一鍵複製安裝包
created: 2026-03-17
author: pm
status: planning
---

# 一鍵複製安裝包 — 規劃書

## 目標

讓有 Mac Mini 的朋友，用最簡單優雅的方式下載並啟動龍蝦系統（最小可運作版本）。

---

## 語音定義（2026-03-17 人類口述）

### 最小可運作單位 v1（Gemini 版）
- 1 台 Mac Mini
- 1 把 Gemini API Key（涵蓋主腦思考 + 對話）
- LINE@ 帳號 + Webhook 開通 + Token
- 龍蝦技能包（智慧居家 + LINE + Google 全家桶）
- Google OAuth（個人必要，可選）
- 不做：LINE Rich Menu、LIFF（初版）

### 最小可運作單位 v2（GPT 訂閱版，推薦先做）
- 1 台 Mac Mini
- ChatGPT 訂閱制（吃訂閱額度）
  - 主聊天：GPT-5.2 instant
  - 深度思考：GPT-5.3 / 5.2 正式版
  - 廣泛用途：GPT-4o
- LINE@ 帳號 + Token
- 龍蝦技能包 + 靈魂文件 + 記憶機制
- 移除：Google 全家桶、生圖娛樂功能
- 分享方式：Google Drive 分享 or GitHub

### 設計原則
- N8N 無法取代：太死板，沒有自然聊天感
- OpenClaw 版本鎖定 2026.2.25（升版有 LINE 回傳疑慮）
- 朋友對程式不熟 → 最小單位、自己玩、不追求完整

---

## 市場調研摘要（sales-bizdev，2026-03-17）

### 業界參考案例

| 工具 | 安裝方式 | 特點 |
|------|----------|------|
| Ollama | curl \| bash / dmg | 最快，1分鐘起跑 |
| n8n | Docker Compose | 可視化但缺自然對話 |
| AnythingLLM | dmg | GUI 友善，非技術用戶可用 |
| Homebrew tap | brew install | 工程師友善 |
| Raycast Extension | 一鍵 Marketplace | 最低門檻但功能受限 |

### 最小依賴清單
- macOS 13.0 (Ventura) 以上，Apple Silicon 優先
- Node.js 20+、pnpm、FFmpeg（語音功能）、cloudflared
- API Key：1 個 LLM + LINE Token + LINE Secret

### 推薦安裝方案

**「單行指令 Bootstrapper + Web GUI 設定精靈」**

```bash
curl -fsSL https://install.life-os.work | bash
```

流程：
1. 自動安裝 Node.js + cloudflared（若未安裝）
2. 自動啟動 localhost 設定網頁
3. 用戶在瀏覽器填寫 LLM Key + LINE Token
4. 自動轉為 launchd 背景常駐服務

優點：開發成本低於原生 dmg，但對非技術用戶直覺友善

---

## 兩方案比較

| | 方案 A（Gemini） | 方案 B（GPT 訂閱）|
|--|--|--|
| 入門成本 | 需要 Gemini API Key | 只需 ChatGPT 訂閱 |
| 模型完整性 | 高（多模型） | 中（OpenAI 全家桶）|
| 生圖 | ✅ Imagen | ❌ 需另接 API |
| 安裝門檻 | 略高 | 低 |
| 推薦對象 | 進階朋友 | 一般朋友（先做這個）|

---

## 待設計

- [ ] install.sh 腳本骨架
- [ ] Web GUI 設定精靈（localhost wizard）
- [ ] 技能包打包方式（哪些 skills 必帶）
- [ ] 靈魂文件標準化（移除個人資訊）
- [ ] Cloudflare Tunnel 自動化設定
- [ ] GitHub repo 結構設計

---

## Vault URL

`https://vault.life-os.work/90_System/Inbox/一鍵複製安裝包-規劃書.md`

---

## MVP v2 修訂（2026-03-17 語音更新）

### 重新定義：LINE 版 Gemini

**核心原則：最輕量、最穩定、不燒額度**

| 項目 | 決策 |
|------|------|
| 模型 | Gemini API（Google 帳號 NT$9000 免費額度） |
| LINE key | 由你代為申請，直接交給朋友 |
| Push 額度管理 | 嚴格 200 則/月上限，每輪最多回覆 1 則，禁多發 |
| 心跳/哨兵/watchdog | ❌ 全部移除 |
| n8n | ❌ 不需要 |
| 自我改進技能 | ❌ 不需要 |
| 記憶 | ✅ 基礎 session memory（輕量，可銜接上下文） |
| 技能包 | 最小化：LINE 對話、基礎查詢、weather、youtube-summarizer |
| 智慧居家 | ❌ 移除（太個人化）|

### 技術選型

ChatGPT OAuth 不穩 → 改回 **Gemini API**
- 一個 Google 帳號 + API Key
- 免費額度夠朋友初期測試
- 模型：Gemini 2.5 Flash（對話） + Gemini 2.5 Pro（深度思考）

### 安裝流程（更新後）

1. 朋友收到你準備好的：Gemini API Key + LINE Token + LINE Secret
2. 跑一行指令安裝
3. 填入 3 個 Key → 完成
4. 打開 LINE 開始聊

**不需要**：Cloudflare 設定精靈（你可以預設好 Tunnel）、OAuth 流程、任何額外帳號

### 解決紅隊 P0 問題

| 原問題 | 新解法 |
|--------|--------|
| ChatGPT OAuth 不穩 | 改 Gemini API Key，無 OAuth 問題 |
| Cloudflare 複雜 | 你預設好 Tunnel 子網域，朋友不需要操作 |
| LINE 信用卡 | 你代申請，朋友只填 Token |
| curl \| bash 信任 | 改為 git clone 方案，朋友可先看腳本 |

---

## MVP v3 最終定義（2026-03-17 第三次語音更新）

### 核心定位：純聊天機器人（零外部 API）

**原則：最小可運作，之後按需疊功能**

| 項目 | v3 決定 |
|------|---------|
| 核心功能 | 純 LINE 聊天（Gemini API） |
| Token 重啟機制 | ✅ 保留：12-15 萬 token 自動重啟（靜默，不推送） |
| 記憶銜接 | ✅ 基礎 session memory |
| 外部 API | ❌ 全部移除（包含 GOG、博物館 API、持頭機器人 API）|
| 掃頻/哨兵 | ❌ 移除 |
| n8n/watchdog | ❌ 移除 |
| Push 通知 | ❌ 幾乎不用（只用 Reply）|
| 初版技能 | 僅：LINE 對話行為規則、line-output 格式選擇 |

### 功能擴展路徑（v3 之後）

加功能方式：從現有技能包挑，逐步疊加
可用技能（你可提供）：
- 博物館 API（免費）
- 持頭機器人 API
- weather
- youtube-summarizer
- link-capture
- GOG（需 Google OAuth）

### Token 重啟規格

- 觸發閾值：12-15 萬 token（不推送 LINE 通知）
- 重啟方式：watchdog sessions.reset（靜默）
- 重啟後：memory 自動銜接，使用者幾乎無感
- watchdog 冷卻：重啟後 10 分鐘不再觸發（防雙重重啟）

