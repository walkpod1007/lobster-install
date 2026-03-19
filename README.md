# 🦞 龍蝦 AI 助理 — 一鍵安裝

把 LINE 變成你的個人 AI 助理。三步驟搞定。

---

## 事前準備

你需要準備好這三樣：

1. **LINE Channel Access Token** — 到 [LINE Developers](https://developers.line.biz/) 建立 Messaging API Channel 取得
2. **LINE Channel Secret** — 同上頁面取得
3. **OpenAI API Key**（選填）— 如果你用 ChatGPT 訂閱制可以留空，系統會用訂閱帳戶

> 💡 LINE 免費方案每月 200 則回覆完全夠用個人使用。

---

## 安裝步驟

### 第一步：下載安裝包

```bash
git clone https://github.com/your-repo/lobster-install.git
cd lobster-install
```

### 第二步：執行安裝腳本

```bash
bash install.sh
```

腳本會自動：
- 檢查你的 Mac 環境（macOS 13+、Node.js 20+）
- 安裝缺少的工具（Homebrew、pnpm、cloudflared、ffmpeg）
- 安裝 OpenClaw
- 開啟設定精靈網頁

### 第三步：填入設定

瀏覽器會自動開啟 `http://localhost:3456`

填入你的 LINE Token、LINE Secret，按「啟動」就完成了。

---

## 啟動後怎麼用

打開 LINE，找到你的 Bot，開始聊天。

預設功能：
- 💬 自然語言對話（GPT-5）
- 🌤 天氣查詢（說「台北天氣」）
- 📺 YouTube 摘要（貼上 YouTube 連結）
- 🔗 網頁內容擷取（貼上任何網址）

---

## 常見問題

**Q: 安裝腳本要跑多久？**
A: 第一次約 5-10 分鐘（主要是下載工具）。

**Q: 重開機後還會自動啟動嗎？**
A: 會。安裝完成後已設定為開機自動常駐。

**Q: 怎麼更新？**
A: `npm install -g openclaw@latest` 然後重啟服務：`openclaw gateway restart`

**Q: 怎麼停止服務？**
A: `launchctl unload ~/Library/LaunchAgents/work.life-os.openclaw.plist`

---

## 技術規格

- OpenClaw 最新版
- 模型：openai/gpt-5（訂閱制）
- LINE：Webhook Reply API（零 Push，全 Reply）
- Token 上限自動重啟（15 萬 token 靜默重置）
- macOS launchd 常駐服務
