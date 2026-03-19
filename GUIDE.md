# 龍蝦 AI 助理 — 安裝引導語句手冊

> 這份文件是給「引導者」看的，不是給新手看的。
> 引導者照著這份手冊，一步一步帶新手完成安裝。
> 所有語句都是純文字，LINE 可讀，不用 Markdown。

---

## 開場

你需要準備：
1. 一台 Mac（macOS 13 以上）
2. ChatGPT 付費訂閱（Plus 或 Pro）
3. 一個 LINE 官方帳號的兩組金鑰（等等教你怎麼拿）

都有了嗎？有的話回我「準備好了」，還沒有的話告訴我缺哪個，我帶你弄。

---

## 分支：LINE 金鑰還沒有

> 如果對方還沒有 LINE 官方帳號和金鑰，走這段。有的話跳過。

### 建立 LINE 官方帳號

1. 用手機或電腦打開 https://developers.line.biz
2. 用你的 LINE 帳號登入
3. 點「Create a new provider」，名字隨便取（例如你的名字）
4. 點「Create a Messaging API Channel」
5. 填寫：
   - Channel name：你的 AI 助理名字（例如「小蝦」）
   - Channel description：隨便寫
   - Category / Subcategory：隨便選
6. 建好後進入 Channel 頁面

### 拿 Channel Secret

在 Channel 頁面的「Basic settings」分頁，往下找到 Channel secret，複製起來，貼給我。

### 拿 Channel Access Token

切到「Messaging API」分頁，往最下面找到 Channel access token，按「Issue」產生，複製起來，貼給我。

### 開啟 Webhook

同一個「Messaging API」分頁，找到 Webhook settings：
- 把 Use webhook 打開
- Webhook URL 先空著，等等裝好再填

拿到 Token 和 Secret 後跟我說「準備好了」。

---

## 步驟一：打開終端機

> 等對方說「準備好了」再開始。

第一步：打開「終端機」

按 Command + 空白鍵，輸入 Terminal，按 Enter。

打開後畫面會出現一行字尾巴有個 % 符號，那就對了。看到了跟我說。

---

## 步驟二：下載並執行安裝腳本

> 等對方說「看到了」再繼續。

貼上這整段，按 Enter：

cd ~ && rm -rf lobster-install && curl -sL https://github.com/walkpod1007/lobster-install/archive/refs/heads/master.zip -o lobster.zip && unzip -o lobster.zip && cd lobster-install-master && bash install.sh

貼完它會自動開始跑，把畫面結果貼給我。

---

## 步驟二：等待安裝

> 安裝過程可能會出現幾種狀況，根據對方回報判斷。

### 正常進行中

畫面會一行一行跑，前面有 ✓ 或 ▶ 符號。正常的話大概 5-10 分鐘。看到有東西在跑就不用管它，等它跑完再貼給我。

### 卡在要求輸入密碼

如果畫面問你 Password，輸入你的 Mac 開機密碼，按 Enter。打字時畫面不會顯示，這是正常的。

### 報錯停住了

把畫面最後幾行貼給我，我幫你看。

---

## 步驟三：安裝完成確認

> 對方回報畫面跑完後。

跑這行確認版本：

openclaw --version

應該會顯示 2026.2.25。有看到嗎？

---

## 步驟四：設定精靈填入金鑰

> 設定精靈（瀏覽器頁面）會自動開啟，引導填入 LINE Token 和 Secret。

畫面上會有兩個欄位，把你準備好的金鑰貼進去：
- Channel Access Token（那串很長的）
- Channel Secret（32 碼那個）

填完按下一步。

> ⚠️ 引導者注意：如果對方直接把 Token/Secret 貼給你，不用幫組指令了，wizard 有 UI 直接貼。

---

## 步驟五：登入 ChatGPT 帳號

> 設定精靈完成後，終端機會提示登入 ChatGPT。

畫面會說「接下來會開啟瀏覽器，請用你的 ChatGPT 帳號登入」。

瀏覽器打開後，用你的 ChatGPT 帳號登入就好。登入完回到終端機按 Enter。

---

## 步驟六：設定 LINE Webhook

> 終端機會自動產生一個網址，顯示在畫面上。

畫面會出現一個框框，裡面有一行網址，長得像：
https://xxx-xxx.trycloudflare.com/line/webhook

把這行網址完整複製，然後：
1. 打開 https://developers.line.biz/console/
2. 點進你的 Channel，切到 Messaging API 分頁
3. 找到 Webhook URL，按 Edit
4. 貼上剛才那行網址
5. 按 Update，再按 Verify
6. 看到 Success 就成功了

設定完回到終端機按 Enter。

重要：不要關掉終端機視窗！關掉 LINE 就斷線了。

---

## 步驟七：開始聊天

打開 LINE，找到你剛建的官方帳號，傳一句話試試。

有回覆就代表裝好了。恭喜！

---

## 常見問題處理

### Q: Verify 失敗
- 確認 cloudflared 那個終端機視窗還開著，沒有關掉
- 確認 URL 最後有加 /line/webhook
- 確認 Gateway 有在跑：開新的終端機視窗，跑 openclaw gateway status

### Q: LINE 沒回覆
- 確認 Webhook 的 Use webhook 有打開
- 確認 Auto-reply 有關掉（在 LINE Official Account Manager 裡）
- 跑 openclaw gateway status 確認 Gateway 在跑

### Q: 重開機後 LINE 不回了
- cloudflared tunnel 會斷掉，需要重跑步驟五
- Gateway 如果有設 launchd 會自動重啟，不用管

### Q: 想換成永久網址
- 需要一個域名 + Cloudflare 帳號
- 這是進階設定，之後再處理

---

## 引導者備註

- 全程不要丟連結叫新手自己看文件
- 每次只給一個動作，等對方回報再下一步
- 對方貼 Token/Secret 過來時，幫他組好完整指令
- 不要用任何 Markdown 格式，LINE 看不到
- 不要給時間預估
- 出錯時不要慌，叫對方把畫面貼過來就好
