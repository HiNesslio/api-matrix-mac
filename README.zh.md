# API Matrix — macOS

一個原生 macOS 選單列小工具，用於管理 API key。是 [API Matrix](https://github.com/HiNesslio/apikey-vault) iOS app 的桌面伴侶。

**簡潔白色 UI · 原生 Keychain 同步 · 選單列快速存取**

## 功能

- **選單列快速存取** — 從狀態列直接檢視與複製 API key
- **完整管理視窗** — 側欄 + 詳細面板的完整管理體驗
- **iCloud Keychain 同步** — 與 iOS app 透過共享 Keychain 自動同步
- **安全可靠** — 金鑰儲存在 macOS Keychain 中，絕不寫入硬碟
- **即時搜尋** — 跨所有 key 的即時搜尋
- **複製與匯出** — 複製金鑰、產生 curl 指令、.env 片段與 JSON 匯出
- **隱私保護** — 金鑰預設遮蔽，10 秒自動隱藏，支援自動鎖定

## 系統需求

- macOS 14.0 (Sonoma) 或更新版本
- Xcode 15.4+ (從原始碼編譯時需要)

## 安裝方式

### 下載預先編譯版本

```bash
curl -L https://github.com/HiNesslio/api-matrix-mac/releases/latest/download/API-Matrix.zip -o API-Matrix.zip
unzip API-Matrix.zip
open API\ Matrix.app
```

> **注意：** 預先編譯版本使用 ad-hoc 簽署。若 Gatekeeper 阻擋開啟，請右鍵點擊 App 後選擇「打開」。

### 從原始碼編譯

```bash
git clone https://github.com/HiNesslio/api-matrix-mac.git
cd api-matrix-mac
make build
make app-bundle
open Build/API\ Matrix.app
```

## 使用方式

1. 啟動 App — 選單列會出現鑰匙圖示
2. 點擊圖示展開選單，檢視你的 API key（透過 Keychain 從 iOS 自動同步）
3. 點擊 **Copy** 複製金鑰，**Add Key** 新增金鑰
4. 點擊 **Open Full App** 開啟完整管理視窗

## 與 iOS 同步

金鑰可透過兩種方式在 macOS 與 iOS 之間同步：

### 自動同步（需要 Apple Developer 帳號）

兩個 App 使用相同的 Keychain Access Group（`com.apimatrix.app`）。若使用同一 Apple Developer Team ID 簽署，金鑰會透過 iCloud Keychain 自動同步。

### 手動同步（無需開發者帳號）

1. 在 iOS：開啟設定 → 匯出備份 → 將 JSON 複製到剪貼簿
2. 在 macOS：開啟設定 → Data → Import Keys → 從剪貼簿貼上

反向操作也同樣可行。

## 授權

MIT
