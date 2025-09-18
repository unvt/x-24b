# OPERATION.md

> See also: [README.md](README.md) / [SETUP.md](SETUP.md) / [SERVICES.md](SERVICES.md) / [NOTES.md](NOTES.md)
> 参照: [README.md](README.md) / [SETUP.md](SETUP.md) / [SERVICES.md](SERVICES.md) / [NOTES.md](NOTES.md)

---

> **Note:** All documentation uses English first, then Japanese for clarity and consistency.
> **注:** すべてのドキュメントは英語→日本語の順で記載しています。

## Basic Operation Procedure / 基礎的オペレーション手順

This document describes the recommended steps to operate the x-24b system on Raspberry Pi OS with GUI.
このドキュメントは、GUI付きRaspberry Pi OS上でx-24bシステムを運用するための推奨手順を記載します。

---

### 1. Start Raspberry Pi OS with GUI / GUI付きRaspberry Pi OSを起動
- Boot your Raspberry Pi and log in to the desktop environment.
- Raspberry Piを起動し、デスクトップ環境にログインします。

### 2. Launch LXTerminal / LXTerminalを起動
- Open LXTerminal from the application menu or desktop.
- アプリケーションメニューまたはデスクトップからLXTerminalを開きます。

### 3. Start xload for Load Monitoring / xloadで負荷状況を観測
- In the terminal, run the following command to launch xload:
  ```bash
  xload &
  ```
- Make the xload window as wide as possible to easily observe system load.
- xloadウィンドウをできるだけ横長にして、システム負荷を観測しやすくします。

### 4. Start tmux / tmuxを起動
- In LXTerminal, start tmux:
  ```bash
  tmux
  ```
- LXTerminalでtmuxを起動します。

### 5. Open Three tmux Sessions / tmuxで3つのセッションを開く
- For each session, run:
  ```bash
  cd x-24b
  ```
- 各セッションで次のコマンドを実行します：
  ```bash
  cd x-24b
  ```

### 6. Start Services in Order / サービスを順番に起動

#### Normal Operation (Quiet Mode) / 通常運用（静かなモード）
- In the first tmux session, start Martin in quiet mode:
  ```bash
  make martin
  ```
- 1つ目のtmuxセッションで静かなモードでMartinを起動：
  ```bash
  make martin
  ```
- In the second tmux session, start Caddy in quiet mode:
  ```bash
  make caddy
  ```
- 2つ目のtmuxセッションで静かなモードでCaddyを起動：
  ```bash
  make caddy
  ```
- In the third tmux session, start the Cloudflare Tunnel in quiet mode:
  ```bash
  make tunnel
  ```
- 3つ目のtmuxセッションで静かなモードでCloudflare Tunnelを起動：
  ```bash
  make tunnel
  ```

#### Troubleshooting (Debug Mode) / トラブルシューティング（デバッグモード）
- For detailed logs when troubleshooting issues, use the debug versions:
  ```bash
  make martin-debug
  make caddy-debug
  make tunnel-debug
  ```
- 問題のトラブルシューティング時に詳細なログを表示するには、デバッグバージョンを使用します：
  ```bash
  make martin-debug
  make caddy-debug
  make tunnel-debug
  ```

### 7. Monitor Services (Optional) / サービス監視（オプション）
- In a fourth tmux session, monitor service health:
  ```bash
  make monitor
  ```
- 4つ目のtmuxセッションでサービス健全性を監視：
  ```bash
  make monitor
  ```

---

## Notes / 注意事項
- Always monitor system load with xload during operation.
- 運用中は常にxloadでシステム負荷を監視してください。
- Use tmux to keep services running independently and to easily recover sessions.
- tmuxを使うことで、サービスを独立して稼働させたり、セッションの復旧が容易になります。
- Follow the order: martin → caddy → tunnel for reliable startup.
- martin → caddy → tunnel の順で起動することで、安定したサービス開始が可能です。
- When hosting multiple PMTiles files, ensure each file's metadata (tile_type, tile_compression, bounds, minzoom, maxzoom) is set correctly for Martin/go-pmtiles compatibility.
- 複数のPMTilesファイルをホストする場合、各ファイルのメタデータ（tile_type, tile_compression, bounds, minzoom, maxzoom）をMartin/go-pmtiles仕様に合わせて正しく設定してください。
- For WebP tiles, set tile_type: "webp" and tile_compression: "none". Martin does not support gzip-compressed WebP tiles.
- WebPタイルの場合は tile_type: "webp"、tile_compression: "none" を指定してください。Martinはgzip圧縮WebPタイルをサポートしません。
- You can list multiple PMTiles files in martin.yml under pmtiles.paths to host them all at once.
- martin.yml の pmtiles.paths 配列に複数ファイルを列挙することで、複数のPMTilesを同時にホストできます。
- Remote PMTiles URLs can be hosted directly without downloading - just add the HTTPS URL to martin.yml.
- リモートPMTiles URLはダウンロードせずに直接ホスト可能 - martin.ymlにHTTPS URLを追加するだけです。
- Use `make monitor` to track process health and resource usage in real-time.
- `make monitor`でプロセス健全性とリソース使用量をリアルタイムで追跡できます。
- Always monitor system load with xload during operation.
- 運用中は常にxloadでシステム負荷を監視してください。
- Use tmux to keep services running independently and to easily recover sessions.
- tmuxを使うことで、サービスを独立して稼働させたり、セッションの復旧が容易になります。
- Follow the order: martin → caddy → tunnel for reliable startup.
- martin → caddy → tunnel の順で起動することで、安定したサービス開始が可能です。

---

## Troubleshooting & FAQ / トラブルシューティング & よくある質問

### Q: Service does not start or shows error / サービスが起動しない・エラーが表示される
- Check if all dependencies (Martin, Caddy, Cloudflare Tunnel, tmux, x11-utils) are installed.
- すべての依存パッケージ（Martin, Caddy, Cloudflare Tunnel, tmux, x11-utils）がインストールされているか確認してください。
- Use debug mode to see detailed error messages:
  ```bash
  make martin-debug
  make caddy-debug
  make tunnel-debug
  ```
- デバッグモードを使用して詳細なエラーメッセージを確認：
  ```bash
  make martin-debug
  make caddy-debug
  make tunnel-debug
  ```
- Review logs in each tmux session for error messages.
- 各tmuxセッションのログでエラーメッセージを確認してください。

### Q: Cannot access tiles from browser / ブラウザからタイルにアクセスできない
- Confirm tunnel is running and public URL is correct.
- トンネルが稼働していて公開URLが正しいか確認してください。
- Check CORS headers using curl:
  ```bash
  curl -I https://tunnel.optgeo.org/martin/[tileset-name]
  ```
- curlでCORSヘッダーを確認：
  ```bash
  curl -I https://tunnel.optgeo.org/martin/[tileset-name]
  ```

### Q: How to download very large PMTiles / 非常に大きなPMTilesのダウンロード方法
- For PMTiles files over 100GB (like Mapterhorn planet.pmtiles):
- 100GB以上のPMTilesファイル（Mapterhornのplanet.pmtilesなど）の場合：
  ```bash
  make download-mapterhorn
  ```
- This uses optimized aria2c settings with reduced concurrency (-x 4 -s 4) to avoid memory issues on Raspberry Pi.
- これにより、Raspberry Piでのメモリ問題を回避するため、並列数を減らした最適化されたaria2c設定（-x 4 -s 4）が使用されます。
- Download may take several days depending on your internet connection.
- ダウンロードはインターネット接続によっては数日かかる場合があります。
- Progress can be monitored in the terminal.
- 進行状況はターミナルで監視できます。

### Q: How to restart a service / サービスの再起動方法
- Stop the tmux session (Ctrl+C), then rerun the make command.
- tmuxセッションを停止（Ctrl+C）し、再度makeコマンドを実行してください。

### Q: How to update PMTiles files / PMTilesファイルの更新方法
- Update `urls.txt` and rerun `make download` and `make verify`.
- `urls.txt`を更新し、`make download`と`make verify`を再実行してください。

### Q: How to fix PMTiles metadata errors / PMTilesメタデータエラーの修正方法
- If Martin shows "Format Unknown and compression Unknown are not yet supported":
- Martinが「Format Unknown and compression Unknown are not yet supported」を表示する場合：
  1. Create a header.json file with correct metadata:
     正しいメタデータでheader.jsonファイルを作成：
     ```json
     {
       "tile_type": "webp",
       "tile_compression": "none",
       "bounds": [-180.0, -85.05112878, 180.0, 85.05112878],
       "center": [0.0, 0.0, 2],
       "minzoom": 2,
       "maxzoom": 12
     }
     ```
  2. Apply the fix: / 修正を適用：
     ```bash
     pmtiles edit data/filename.pmtiles --header-json header.json
     ```

### Q: How to add remote PMTiles / リモートPMTilesの追加方法
- Add the HTTPS URL directly to martin.yml under pmtiles.paths:
- martin.ymlのpmtiles.pathsにHTTPS URLを直接追加：
  ```yaml
  pmtiles:
    paths:
      - https://example.com/remote.pmtiles
  ```
- `urls.txt`を更新し、`make download`と`make verify`を再実行してください。

---

This procedure ensures stable and observable operation of the x-24b portable web map server on Raspberry Pi OS.
この手順により、Raspberry Pi OS上でx-24bポータブルウェブ地図サーバーを安定的かつ観測可能に運用できます。

---

For more information, see [README.md](README.md), [SETUP.md](SETUP.md), [SERVICES.md](SERVICES.md), [NOTES.md](NOTES.md).
詳細は [README.md](README.md)、[SETUP.md](SETUP.md)、[SERVICES.md](SERVICES.md)、[NOTES.md](NOTES.md) をご覧ください。
