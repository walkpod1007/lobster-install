#!/usr/bin/env node
'use strict';

const express = require('express');
const path = require('path');
const fs = require('fs');
const { execSync, spawn } = require('child_process');

const app = express();
const PORT = 3456;
const OPENCLAW_HOME = process.env.OPENCLAW_HOME || path.join(process.env.HOME, '.openclaw');
const INSTALL_DIR = process.env.INSTALL_DIR || path.dirname(__dirname);

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// ─── 系統檢查 ───────────────────────────

app.get('/api/syscheck', (req, res) => {
  const checks = [];

  // macOS
  try {
    const ver = execSync('sw_vers -productVersion').toString().trim();
    const major = parseInt(ver.split('.')[0]);
    checks.push({ name: 'macOS', ok: major >= 13, detail: ver });
  } catch {
    checks.push({ name: 'macOS', ok: false, detail: '無法偵測' });
  }

  // Node.js
  try {
    const ver = process.version;
    const major = parseInt(ver.slice(1).split('.')[0]);
    checks.push({ name: 'Node.js', ok: major >= 20, detail: ver });
  } catch {
    checks.push({ name: 'Node.js', ok: false, detail: '未安裝' });
  }

  // cloudflared
  try {
    const ver = execSync('cloudflared --version 2>&1').toString().trim().split('\n')[0];
    checks.push({ name: 'cloudflared', ok: true, detail: ver });
  } catch {
    checks.push({ name: 'cloudflared', ok: false, detail: '未安裝' });
  }

  // ffmpeg
  try {
    execSync('ffmpeg -version 2>&1');
    checks.push({ name: 'ffmpeg', ok: true, detail: '已安裝' });
  } catch {
    checks.push({ name: 'ffmpeg', ok: false, detail: '未安裝（語音功能需要）' });
  }

  // openclaw
  try {
    const ver = execSync('openclaw --version 2>/dev/null').toString().trim();
    checks.push({ name: 'OpenClaw', ok: true, detail: ver });
  } catch {
    checks.push({ name: 'OpenClaw', ok: false, detail: '未安裝' });
  }

  res.json({ checks });
});

// ─── 寫入設定 ────────────────────────────

app.post('/api/config', (req, res) => {
  const { lineToken, lineSecret, openaiKey } = req.body;

  if (!lineToken || !lineSecret) {
    return res.status(400).json({ error: 'LINE Token 和 LINE Secret 為必填' });
  }

  // 讀取模板
  const templatePath = path.join(INSTALL_DIR, 'config', 'openclaw.json.template');
  if (!fs.existsSync(templatePath)) {
    return res.status(500).json({ error: '找不到設定模板檔案' });
  }

  let config = JSON.parse(fs.readFileSync(templatePath, 'utf8'));

  // 填入用戶資料
  config.channels.line.channelAccessToken = lineToken;
  config.channels.line.channelSecret = lineSecret;

  if (openaiKey && openaiKey.trim()) {
    config.env = config.env || {};
    config.env.OPENAI_API_KEY = openaiKey.trim();
  }

  // 寫入 openclaw.json
  const configPath = path.join(OPENCLAW_HOME, 'openclaw.json');
  fs.mkdirSync(OPENCLAW_HOME, { recursive: true });
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2));

  res.json({ ok: true, path: configPath });
});

// ─── 啟動 Gateway ────────────────────────

app.post('/api/start', (req, res) => {
  try {
    // 先停現有的
    try { execSync('openclaw gateway stop 2>/dev/null'); } catch {}

    // 背景啟動
    const proc = spawn('openclaw', ['gateway', 'start'], {
      detached: true,
      stdio: 'ignore',
      env: { ...process.env, HOME: process.env.HOME }
    });
    proc.unref();

    res.json({ ok: true });

    // 3 秒後自行退出（launchd 設定完成後 install.sh 會接手）
    setTimeout(() => process.exit(0), 3000);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ─── 啟動 Server ─────────────────────────

app.listen(PORT, '127.0.0.1', () => {
  console.log(`🦞 設定精靈已啟動：http://localhost:${PORT}`);
});
