# 安裝引導測試備註（2026-03-19 辦公室實測）

## 已發現的問題

### 1. 私有 repo → 新手卡在 git clone 登入
- 原本：git clone 私有 repo，需要 GitHub 帳號 + 認證
- 修正：repo 改公開，下載方式改 curl zip
- 狀態：✅ 已改

### 2. 預設對方有 GitHub 帳號
- 原本：README 寫 git clone，必備清單沒提 GitHub
- 修正：改用 curl 下載 zip，不需要 GitHub 帳號
- 狀態：✅ 已改

### 3. 引導流程不存在
- 原本：只有 README 和 install.sh，沒有引導式 SOP
- 修正：需要一份新手友善的步驟文件，語氣像有人帶著走
- 狀態：⏳ 跑完實測後根據備註重寫

### 4. 必備清單漏 ChatGPT 訂閱
- 原本：README 寫 OpenAI API Key（選填），但 SPEC 定義 v2 是 GPT 訂閱制
- 修正：必備清單改成「ChatGPT 付費訂閱（Plus 或 Pro）」
- 狀態：⏳ 待回寫 README

### 5. 我（龍蝦）搞混模型
- 引導時說成 Anthropic API Key，實際 SPEC 和 template 都寫 openai/gpt-5
- 原因：沒讀 SPEC 就憑印象回答
- 教訓：引導流程必須照文件走，不能靠記憶

---

## 實測進度

- [ ] curl 下載 zip 能跑
- [ ] install.sh 環境檢查通過
- [ ] Homebrew / Node / pnpm 自動安裝
- [ ] cloudflared 安裝 + tunnel 設定
- [ ] openclaw.json 填入 Token/Secret
- [ ] Gateway 啟動
- [ ] LINE webhook 連通
- [ ] 第一則對話成功

---

## 跑完後待辦

- 根據以上備註重寫 README.md
- 補寫新手引導 SOP（純文字，LINE 可讀）
- install.sh 修正發現的 bug
- 建 CHANGELOG.md（這是一個 skill 的迭代）

### 6. OPENCLAW_VERSION 寫 latest
- 原本：latest（會裝到最新版）
- 修正：鎖定 2026.2.25（SPEC 明確要求）
- 狀態：✅ 已改

### 7. npm → pnpm
- 原本：npm install -g openclaw
- 修正：pnpm install -g openclaw（跟我們家裡環境一致）
- 狀態：✅ 已改

### 8. unbound variable
- 原本：CURRENT_VER? 語法錯誤（bash set -u 下報錯）
- 修正：加大括號 ${CURRENT_VER}
- 狀態：✅ 已改

### 9. pnpm vs npm 安裝衝突
- 原本：install.sh 統一用 pnpm install -g
- 問題：如果對方之前用 npm 裝的 openclaw（在 /opt/homebrew/lib/node_modules/），pnpm 會報 ERR_PNPM_NO_GLOBAL_BIN_DIR
- 修正方向：先偵測 openclaw 裝在哪，用同一個 package manager 升級；或先 npm uninstall -g 再 pnpm install -g
- 狀態：⏳ 待修

### 10. npm 才是正解
- pnpm 全域目錄在新手機器上反覆失敗
- 結論：放棄 pnpm，統一用 npm install -g（Node.js 自帶，零設定）
- 狀態：✅ 已改

### 11. 設定精靈成功啟動
- install.sh 跑完後自動開啟 localhost:3456
- 系統環境檢查全過（macOS 26.2, Node v25.6.1, cloudflared, ffmpeg, OpenClaw 2026.2.25）
- wizard UI 正常顯示三步驟：系統檢查 → 填入設定 → 完成啟動
- 狀態：✅ 通過

### 12. 設定精靈全程通過
- 三步驟（系統檢查→填入設定→完成啟動）全部順利
- Gateway 成功啟動
- 狀態：✅ 通過

### 13. Webhook 設定是最大斷點
- 新手不知道怎麼打開 LINE Developers Console
- 「打開 Messaging API 分頁」這句話對新手來說太難
- 需要：直接給 URL（https://developers.line.biz/console/）
- 更好的做法：wizard 第二步就引導填 webhook，或自動用 cloudflared quick tunnel 產生 URL 並顯示在完成頁面讓使用者複製貼上
- 狀態：⏳ 下次迭代處理

### 14. 整體評估
- install.sh 從下載到啟動大約 5-10 分鐘（環境已有的情況下更快）
- 卡點集中在：pnpm 全域目錄（已修）、webhook 設定（待改善）
- wizard UI 品質不錯，新手友善
- 下一版重點：webhook 自動化 + GUIDE.md 補 LINE Developers 操作截圖

### 15. LINE Developers Console 直連
- 格式：https://developers.line.biz/console/channel/{CHANNEL_ID}/messaging-api
- CHANNEL_ID 每個人不同，wizard 如果能從 Token 反查就能自動產生直連
- 退而求其次：引導語給 https://developers.line.biz/console/ 讓使用者自己點進去
- 狀態：⏳ 待處理

### 16. 辦公室那台的 webhook 現況
- Webhook URL：https://bot2.life-os.work/line/webhook
- 這是之前設的自有域名，cloudflared tunnel "claw" 有在跑但 DNS 可能沒指對
- 新手場景應該用 cloudflared quick tunnel 自動產生 URL
- 狀態：⏳ 下次迭代

### 17. Webhook 引導完整流程（待寫進 GUIDE）
- install.sh 跑完後，wizard 完成頁應該要：
  1. 自動啟動 cloudflared quick tunnel（背景跑）
  2. 顯示產生的 trycloudflare.com URL
  3. 告訴使用者：複製這個網址，後面加 /line/webhook
  4. 貼到 LINE Developers Console 的 Webhook URL
  5. 按 Verify 確認 Success
  6. 警告：不要關閉終端機，關掉就斷線了
- 或者 install.sh 結束前自動跑 cloudflared tunnel --url http://localhost:18789 &
  把 URL 印在終端機上

### 18. 終端機不能關
- cloudflared quick tunnel 跑在前景，關掉終端機就斷
- 新手一定會關掉
- 長期解法：用 launchd 把 cloudflared 變成背景服務
- install.sh 應該自動處理這件事
- 狀態：⏳ 下次迭代

### 19. GPT 訂閱制需要 OAuth 登入
- 原本 SPEC 寫「ChatGPT 訂閱制（吃訂閱額度）」以為不用填 key
- 實際：OpenClaw 要用 OpenAI 模型，訂閱制也需要走 OAuth 認證流程
- 類似 Gemini CLI 的 Google OAuth 登入
- wizard 第二步或 install.sh 要加一步：引導使用者跑 OpenAI OAuth 登入
- 需要確認：openclaw 有沒有內建 openai auth 指令？還是要另外處理？
- 狀態：⏳ 待確認流程
