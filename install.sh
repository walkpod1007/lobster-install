#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────
# 🦞 龍蝦 AI 助理 — 一鍵安裝腳本
# ─────────────────────────────────────────

OPENCLAW_VERSION="2026.2.25"
WIZARD_PORT=3456
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_HOME="$HOME/.openclaw"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1"; exit 1; }
step() { echo -e "\n${YELLOW}▶ $1${NC}"; }

# ─── 系統檢查 ─────────────────────────────

step "檢查系統環境"

# macOS 版本
if [[ "$OSTYPE" != "darwin"* ]]; then
  err "此腳本僅支援 macOS。"
fi

MACOS_VER=$(sw_vers -productVersion)
MACOS_MAJOR=$(echo "$MACOS_VER" | cut -d. -f1)
if [[ "$MACOS_MAJOR" -lt 13 ]]; then
  err "需要 macOS 13 (Ventura) 以上，目前是 $MACOS_VER"
fi
log "macOS $MACOS_VER ✓"

# ─── Homebrew ─────────────────────────────

if ! command -v brew &>/dev/null; then
  step "安裝 Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon path
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi
log "Homebrew ✓"

# ─── Node.js ──────────────────────────────

NODE_OK=false
if command -v node &>/dev/null; then
  NODE_VER=$(node -e "process.stdout.write(process.version.slice(1).split('.')[0])")
  if [[ "$NODE_VER" -ge 20 ]]; then
    NODE_OK=true
    log "Node.js v$(node -v | tr -d 'v') ✓"
  fi
fi

if [[ "$NODE_OK" == false ]]; then
  step "安裝 Node.js 22 (LTS)"
  brew install node@22
  brew link node@22 --force --overwrite
  log "Node.js $(node -v) 已安裝"
fi

# ─── pnpm ─────────────────────────────────

if ! command -v pnpm &>/dev/null; then
  step "安裝 pnpm"
  npm install -g pnpm
fi
log "pnpm ✓"

# ─── cloudflared ──────────────────────────

if ! command -v cloudflared &>/dev/null; then
  step "安裝 cloudflared（LINE Webhook 隧道）"
  brew install cloudflared
fi
log "cloudflared ✓"

# ─── ffmpeg ───────────────────────────────

if ! command -v ffmpeg &>/dev/null; then
  step "安裝 ffmpeg（語音處理）"
  brew install ffmpeg
fi
log "ffmpeg ✓"

# ─── pnpm 全域目錄（跳過，統一用 npm）────

# ─── OpenClaw ─────────────────────────────

step "安裝 OpenClaw ${OPENCLAW_VERSION}"

# 偵測舊版安裝方式，先清除再統一用 pnpm
if command -v openclaw &>/dev/null; then
  CURRENT_VER=$(openclaw --version 2>/dev/null || echo "unknown")
  OPENCLAW_PATH=$(which openclaw 2>/dev/null || echo "")
  
  if [[ "${CURRENT_VER}" == "${OPENCLAW_VERSION}" ]]; then
    log "OpenClaw ${OPENCLAW_VERSION} 已是正確版本，跳過"
  else
    warn "發現舊版 OpenClaw（${CURRENT_VER}），升級至 ${OPENCLAW_VERSION}..."
    
    # 如果是 npm 全域安裝（路徑含 /opt/homebrew 或 /usr/local）
    if [[ "$OPENCLAW_PATH" == */opt/homebrew/* ]] || [[ "$OPENCLAW_PATH" == */usr/local/* ]]; then
      warn "舊版透過 npm 安裝，先移除..."
      npm uninstall -g openclaw 2>/dev/null || true
    fi
    
    npm install -g openclaw@${OPENCLAW_VERSION}
  fi
else
  npm install -g openclaw@${OPENCLAW_VERSION}
fi
log "OpenClaw $(openclaw --version 2>/dev/null || echo '') 已安裝"

# ─── 建立目錄結構 ─────────────────────────

step "建立 OpenClaw 目錄"
mkdir -p "$OPENCLAW_HOME"/{skills,workspace,sessions}

# ─── 複製 skills ──────────────────────────

step "複製技能包"
SKILLS_SRC="$INSTALL_DIR/skills"
SKILLS_DST="$OPENCLAW_HOME/skills"

if [[ -d "$SKILLS_SRC" ]]; then
  cp -r "$SKILLS_SRC/." "$SKILLS_DST/"
  log "技能包已複製到 $SKILLS_DST"
else
  warn "找不到 skills 目錄，跳過"
fi

# ─── 複製 workspace config ────────────────

WORKSPACE_DIR="$OPENCLAW_HOME/workspace-lobster"
mkdir -p "$WORKSPACE_DIR"

for f in SOUL.md AGENTS.md; do
  if [[ -f "$SKILLS_SRC/$f" ]]; then
    cp "$SKILLS_SRC/$f" "$WORKSPACE_DIR/$f"
    log "已複製 $f 到 workspace"
  fi
done

# ─── 安裝 Wizard 依賴 ─────────────────────

step "安裝設定精靈依賴套件"
cd "$INSTALL_DIR/wizard"
if [[ ! -f package.json ]]; then
  npm init -y --quiet
fi
npm install express --save --quiet 2>/dev/null || true
cd "$INSTALL_DIR"

# ─── 啟動設定精靈 ─────────────────────────

step "啟動設定精靈"

# 檢查 port 是否已被佔用
if lsof -Pi :$WIZARD_PORT -sTCP:LISTEN -t &>/dev/null; then
  warn "Port $WIZARD_PORT 已被佔用，嘗試關閉..."
  kill $(lsof -Pi :$WIZARD_PORT -sTCP:LISTEN -t) 2>/dev/null || true
  sleep 1
fi

echo ""
echo "  🦞 設定精靈即將在瀏覽器開啟"
echo "  如果沒有自動開啟，請手動前往：http://localhost:$WIZARD_PORT"
echo ""

# 傳遞 INSTALL_DIR 給 wizard
export OPENCLAW_HOME
export INSTALL_DIR

node "$INSTALL_DIR/wizard/server.js" &
WIZARD_PID=$!

# 等待 server 啟動
sleep 2

# 開啟瀏覽器
open "http://localhost:$WIZARD_PORT" 2>/dev/null || true

# 等待 wizard 完成（server.js 完成設定後會自行退出，或用戶 ctrl+c）
echo "  等待設定完成...（完成後請關閉瀏覽器分頁）"
wait $WIZARD_PID 2>/dev/null || true

# ─── OpenAI OAuth 登入 ────────────────────

step "登入 ChatGPT 帳號"
echo ""
echo "  接下來會開啟瀏覽器，請用你的 ChatGPT 帳號登入。"
echo "  這是讓龍蝦助理用你的 ChatGPT 訂閱來思考。"
echo ""

openclaw onboard --auth-choice openai-codex 2>/dev/null || {
  warn "自動登入失敗，請手動執行：openclaw onboard"
  read -rp "  按 Enter 繼續..."
}

log "ChatGPT 認證完成"

# ─── Cloudflared Tunnel ───────────────────

step "建立 LINE Webhook 通道"
echo ""
echo "  正在產生對外網址..."
echo ""

# 用 quick tunnel 背景跑，擷取 URL
cloudflared tunnel --url http://localhost:18789 2>&1 &
CF_PID=$!

# 等待 URL 產生（最多 15 秒）
TUNNEL_URL=""
for i in $(seq 1 15); do
  sleep 1
  TUNNEL_URL=$(curl -s http://localhost:18789/.well-known/tunnel 2>/dev/null | grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' || true)
  if [[ -z "$TUNNEL_URL" ]]; then
    # 從 cloudflared 輸出擷取
    TUNNEL_URL=$(jobs -l 2>/dev/null; cat /tmp/cf-tunnel-$$.log 2>/dev/null | grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' | head -1 || true)
  fi
  [[ -n "$TUNNEL_URL" ]] && break
done

if [[ -z "$TUNNEL_URL" ]]; then
  # 備用方案：從 log 檔撈
  sleep 3
  TUNNEL_URL=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' /tmp/openclaw/openclaw-*.log 2>/dev/null | tail -1 || true)
fi

if [[ -n "$TUNNEL_URL" ]]; then
  WEBHOOK_URL="${TUNNEL_URL}/line/webhook"
  log "Webhook 通道建立成功"
  echo ""
  echo "  ╔══════════════════════════════════════════════╗"
  echo "  ║  你的 Webhook URL：                          ║"
  echo "  ║  $WEBHOOK_URL"
  echo "  ╚══════════════════════════════════════════════╝"
  echo ""
  echo "  請完成以下步驟："
  echo "  1. 打開 https://developers.line.biz/console/"
  echo "  2. 點進你的 Channel → Messaging API"
  echo "  3. 在 Webhook URL 按 Edit，貼上上面的網址"
  echo "  4. 按 Update，再按 Verify，看到 Success 就成功了"
  echo ""
  echo "  ⚠️ 重要：不要關閉這個終端機視窗！關掉會斷線。"
  echo ""
else
  warn "無法自動產生 Webhook URL"
  echo "  請手動執行：cloudflared tunnel --url http://localhost:18789"
  echo "  然後把產生的網址後面加 /line/webhook 填到 LINE Webhook 設定"
fi

read -rp "  Webhook 設定完成了嗎？按 Enter 繼續..."

# ─── 設定 launchd 常駐 ────────────────────

PLIST_PATH="$HOME/Library/LaunchAgents/work.life-os.openclaw.plist"

if [[ -f "$OPENCLAW_HOME/openclaw.json" ]]; then
  step "設定開機自動啟動（launchd）"

  OPENCLAW_BIN=$(which openclaw)

  cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>work.life-os.openclaw</string>
    <key>ProgramArguments</key>
    <array>
        <string>$OPENCLAW_BIN</string>
        <string>gateway</string>
        <string>start</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>$HOME</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$OPENCLAW_HOME/gateway.log</string>
    <key>StandardErrorPath</key>
    <string>$OPENCLAW_HOME/gateway-error.log</string>
</dict>
</plist>
EOF

  launchctl unload "$PLIST_PATH" 2>/dev/null || true
  launchctl load "$PLIST_PATH"
  log "launchd 服務已啟動"

  echo ""
  echo "  ✅ 安裝完成！"
  echo ""
  echo "  🦞 龍蝦助理已啟動，打開 LINE 開始聊天吧"
  echo ""
  echo "  管理指令："
  echo "    停止服務：launchctl unload ~/Library/LaunchAgents/work.life-os.openclaw.plist"
  echo "    重啟服務：openclaw gateway restart"
  echo "    查看日誌：tail -f ~/.openclaw/gateway.log"
  echo ""
else
  warn "未偵測到 openclaw.json，跳過 launchd 設定"
  warn "請手動完成設定後執行：bash $INSTALL_DIR/setup-launchd.sh"
fi
