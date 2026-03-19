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
