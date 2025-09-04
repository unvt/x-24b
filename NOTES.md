# NOTES / 開発ノート

> See also: [README.md](README.md) / [SETUP.md](SETUP.md) / [SERVICES.md](SERVICES.md) / [OPERATION.md](OPERATION.md)
> 参照: [README.md](README.md) / [SETUP.md](SETUP.md) / [SERVICES.md](SERVICES.md) / [OPERATION.md](OPERATION.md)

---

> **Note:** All documentation uses English first, then Japanese for clarity and consistency.
> **注:** すべてのドキュメントは英語→日本語の順で記載しています。

## Overview / 概要
This document contains supplementary notes for the x-24b project, including development insights and configuration details.

このドキュメントには、開発の洞察と設定の詳細を含む、x-24bプロジェクトの補足ノートが含まれています。

## Key Points / 主要なポイント

### PMTiles Metadata Editing / PMTilesメタデータ編集
- Use `pmtiles edit --header-json` to set tile_type, tile_compression, bounds, minzoom, maxzoom explicitly for each file.
- 各ファイルの tile_type, tile_compression, bounds, minzoom, maxzoom を `pmtiles edit --header-json` で明示的に設定してください。
- For WebP tiles, set tile_type: "webp", tile_compression: "none". Martin does not support gzip-compressed WebP tiles.
- WebPタイルの場合は tile_type: "webp"、tile_compression: "none" を指定してください。Martinはgzip圧縮WebPタイルをサポートしません。
- To host multiple PMTiles, list all files in the pmtiles.paths array in martin.yml.
- 複数のPMTilesをホストするには、martin.yml の pmtiles.paths 配列にすべてのファイルを列挙してください。

### PMTiles Hosting / PMTilesホスティング
- **Managed by Martin** - Dynamically serves tiles, sprites, and fonts
- **Martinによる管理** - タイル、スプライト、フォントを動的に配信
- **CORS Configuration** - Handled exclusively by Caddy to prevent header conflicts
- **CORS設定** - ヘッダー競合を防ぐためCaddyでのみ処理
- **URL Generation** - Uses X-Rewrite-URL header for consistent HTTPS URLs
- **URL生成** - 一貫したHTTPS URLのためX-Rewrite-URLヘッダーを使用
- **Large Files** - For very large PMTiles (>100GB), use aria2c with reduced concurrency (e.g., -x 4 -s 4)
- **大容量ファイル** - 非常に大きなPMTiles（>100GB）の場合、並列数を減らしたaria2c（例：-x 4 -s 4）を使用

### Makefile Tasks / Makefileタスク

**`make download`** - Fetch PMTiles files with parallel processing / 並列処理でPMTilesファイルを取得
- Uses `aria2c` with `--max-concurrent-downloads=2` and `--split=2` for parallel downloads
- 並列ダウンロードのため`aria2c`を`--max-concurrent-downloads=2`と`--split=2`で使用
- Speed limited to 1MB/s (`--max-download-limit=1048576`) to be respectful to servers
- サーバーに配慮して速度を1MB/s（`--max-download-limit=1048576`）に制限
- Files downloaded with `.part` extension during transfer
- 転送中は`.part`拡張子でファイルをダウンロード

**`make verify`** - Validate PMTiles integrity / PMTiles整合性を検証
- Uses `pmtiles verify` to check file validity
- ファイルの有効性確認のため`pmtiles verify`を使用
- Valid files renamed to remove `.part` extension
- 有効なファイルは`.part`拡張子を削除してリネーム

**`make clean`** - Remove all data files / すべてのデータファイルを削除
- Clears entire `data` directory
- `data`ディレクトリ全体をクリア

**`make martin`** - Start Martin server / Martinサーバーを開始
- Serves both local and remote PMTiles files
- ローカルとリモートの両方のPMTilesファイルを配信
- Supports direct remote URL hosting without local storage
- ローカルストレージなしでリモートURL直接ホスティングをサポート
- Excludes partially downloaded files (`.part` files)
- 部分的にダウンロードされたファイル（`.part`ファイル）を除外

**`make services`** - Generate SERVICES.md from martin.yml / martin.ymlからSERVICES.mdを生成
- Uses Ruby script `scripts/generate_services_md.rb`
- Rubyスクリプト`scripts/generate_services_md.rb`を使用
- Automatically lists all configured PMTiles sources
- 設定されたすべてのPMTilesソースを自動的にリスト

**`make monitor`** - Monitor service processes / サービスプロセスを監視
- Uses `monitor.rb` to track martin, caddy, and cloudflared processes
- `monitor.rb`を使用してmartin、caddy、cloudflaredプロセスを追跡
- Shows real-time CPU usage, memory, I/O, and runtime statistics
- リアルタイムCPU使用量、メモリ、I/O、実行時間統計を表示
- Aggregates stats across all child processes for accurate monitoring
- 正確な監視のため全子プロセスの統計を集約

**`make tunnel`** - Establish Cloudflare Tunnel / Cloudflare Tunnelを確立
- Configurable tunnel name via `tunnel_name` variable
- `tunnel_name`変数による設定可能なトンネル名

## Technical Notes / 技術ノート

### Remote PMTiles Support / リモートPMTilesサポート
- **Direct URL hosting** - Martin can serve remote PMTiles URLs without local storage
- **直接URL配信** - MartinはローカルストレージなしでリモートPMTiles URLを配信可能
- **HTTP range requests** - Only fetches the specific tile data needed from remote sources
- **HTTP範囲リクエスト** - リモートソースから必要な特定のタイルデータのみを取得
- **Mixed sources** - Combine local files and remote URLs in the same martin.yml configuration
- **混合ソース** - 同じmartin.yml設定でローカルファイルとリモートURLを組み合わせ

### CORS Implementation / CORS実装
- **Problem**: Duplicate CORS headers when both Martin and Caddy add them
- **問題**: MartinとCaddyの両方がCORSヘッダーを追加すると重複が発生
- **Solution**: Set `cors: false` in martin.yml, handle CORS only in Caddy
- **解決策**: martin.ymlで`cors: false`を設定、CaddyでのみCORSを処理

### URL Consistency / URL一貫性
- **Challenge**: Different URL schemes (http vs https) in TileJSON responses
- **課題**: TileJSONレスポンスでの異なるURLスキーム（http vs https）
- **Solution**: X-Rewrite-URL header provides complete external URL structure
- **解決策**: X-Rewrite-URLヘッダーが完全な外部URL構造を提供

### Path Handling / パス処理
- **Caddy strips** `/martin` prefix before forwarding to Martin
- **Caddyが除去** 転送前にMartinへ`/martin`プレフィックスを除去
- **Martin serves** files directly without path prefix complications
- **Martinが配信** パスプレフィックスの複雑さなしにファイルを直接配信

## Development Guidelines / 開発ガイドライン

- **Repository cleanliness** - Ensure the repository remains clean
- **リポジトリの清潔さ** - リポジトリを清潔に保つ
- **urls.txt formatting** - Ensure proper formatting before running `make download`
- **urls.txt形式** - `make download`実行前に適切な形式を確認
- **Documentation updates** - Update this document as the project evolves
- **ドキュメント更新** - プロジェクトの発展に合わせてこのドキュメントを更新
- **Configuration testing** - Always test configuration changes with both localhost and tunnel access
- **設定テスト** - 設定変更は常にlocalhostとtunnelアクセスの両方でテスト

---

For more information, see [README.md](README.md), [SETUP.md](SETUP.md), [SERVICES.md](SERVICES.md), [OPERATION.md](OPERATION.md).
詳細は [README.md](README.md)、[SETUP.md](SETUP.md)、[SERVICES.md](SERVICES.md)、[OPERATION.md](OPERATION.md) をご覧ください。
