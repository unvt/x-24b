# x-24b

Martin from Cloudflare Tunnel with multiple PMTiles support  
Cloudflare Tunnelを使った複数PMTiles対応のMartin

## Overview / 概要

x-24b is a generalized version of [gel-tunnel](https://github.com/optgeo/gel-tunnel), designed to host multiple PMTiles in a data directory. It simplifies the process of downloading, verifying, and hosting PMTiles files with enterprise-grade reliability and CORS support for web mapping applications.

x-24bは[gel-tunnel](https://github.com/optgeo/gel-tunnel)の汎用版で、データディレクトリ内の複数のPMTilesをホストするように設計されています。PMTilesファイルのダウンロード、検証、ホスティングのプロセスを、エンタープライズグレードの信頼性とWebマッピングアプリケーション向けのCORSサポートにより簡素化します。

## Why the name x-24b? / なぜx-24bという名前？

The name "x-24b" is a playful nod to the Martin tile server and its connection to Cloudflare. Just like the experimental X-24B aircraft, which was produced by Martin and used flares during landing, this project "lands" PMTiles with the help of Martin and Cloudflare. In aviation, a "flare" is a small nose-up operation performed just before landing to ensure a smooth touchdown. Similarly, this project ensures a smooth and efficient "landing" of PMTiles into your data directory. While we don't have actual flares, we do have blazing-fast tile hosting and a touch of humor to keep things grounded! For more about the X-24B aircraft, visit [this reference](https://www.nationalmuseum.af.mil/Visit/Museum-Exhibits/Fact-Sheets/Display/Article/195762/martin-x-24b/) and [this NASA image article](https://www.nasa.gov/image-article/x-24b-lifting-body/).

「x-24b」という名前は、Martinタイルサーバーとその Cloudflare との接続への楽しい敬意です。Martin社によって製造され、着陸時にフレアを使用した実験機X-24Bのように、このプロジェクトはMartinとCloudflareの助けを借りてPMTilesを「着陸」させます。航空において「フレア」とは、スムーズな着陸を確実にするために着陸直前に行われる小さな機首上げ操作です。同様に、このプロジェクトはPMTilesのデータディレクトリへのスムーズで効率的な「着陸」を確実にします。実際のフレアはありませんが、超高速のタイル配信と、物事を地に足をつけて保つためのユーモアのタッチがあります！X-24B航空機についての詳細は、[この参考資料](https://www.nationalmuseum.af.mil/Visit/Museum-Exhibits/Fact-Sheets/Display/Article/195762/martin-x-24b/)および[このNASA画像記事](https://www.nasa.gov/image-article/x-24b-lifting-body/)をご覧ください。

## Features / 機能

- **Multiple PMTiles hosting** - Hosts multiple PMTiles files listed in `urls.txt`
- **複数PMTilesホスティング** - `urls.txt`にリストされた複数のPMTilesファイルをホスト
- **Batch downloading** - Downloads PMTiles files using `aria2c` for efficient batch processing
- **バッチダウンロード** - 効率的なバッチ処理のため`aria2c`を使用してPMTilesファイルをダウンロード
- **File verification** - Validates downloaded PMTiles files using `pmtiles verify`
- **ファイル検証** - `pmtiles verify`を使用してダウンロードしたPMTilesファイルを検証
- **Makefile automation** - Controlled entirely via a `Makefile` with intuitive commands
- **Makefile自動化** - 直感的なコマンドで`Makefile`により完全制御
- **CORS support** - Full CORS compliance for web mapping applications
- **CORSサポート** - Webマッピングアプリケーション向けの完全CORS準拠
- **HTTPS consistency** - Reliable HTTPS URL generation through Cloudflare Tunnel
- **HTTPS一貫性** - Cloudflare Tunnel経由の信頼性の高いHTTPS URL生成

### Available Commands / 利用可能なコマンド

- `make download` - Fetch PMTiles files / PMTilesファイルを取得
- `make verify` - Validate downloaded PMTiles files / ダウンロードしたPMTilesファイルを検証
- `make clean` - Remove unnecessary files / 不要なファイルを削除
- `make host` - Serve PMTiles files using Martin / Martinを使用してPMTilesファイルを配信
- `make tunnel` - Establish a Cloudflare Tunnel / Cloudflare Tunnelを確立

## Usage / 使用方法

> **Note:** All documentation uses English first, then Japanese for clarity and consistency.
> **注:** すべてのドキュメントは英語→日本語の順で記載しています。

1. **Populate `urls.txt`** with PMTiles file details:
   **`urls.txt`にPMTilesファイルの詳細を記入**:
   ```
   https://server/directory/xyz.pmtiles
       output=data/xyz.pmtiles
   ```

2. **Use the `Makefile`** to manage the process:
   **プロセス管理に`Makefile`を使用**:
   ```bash
   make download   # Download files / ファイルをダウンロード
   make verify     # Verify integrity / 整合性を検証
   make martin     # Start Martin server / Martinサーバーを開始
   make caddy      # Start Caddy server / Caddyサーバーを開始
   make tunnel     # Start Cloudflare tunnel / Cloudflare tunnelを開始
   make clean      # Remove unnecessary files / 不要なファイルを削除
   ```

3. **Access your tiles** via the tunnel:
   **tunnel経由でタイルにアクセス**:
   - TileJSON: `https://tunnel.optgeo.org/martin/[tileset-name]`
   - Tiles: `https://tunnel.optgeo.org/martin/[tileset-name]/{z}/{x}/{y}`

## Technical Architecture / 技術アーキテクチャ

This project solves complex URL generation and CORS issues that occur when serving tiles through multiple proxy layers:

このプロジェクトは、複数のプロキシ層を通してタイルを配信する際に発生する複雑なURL生成とCORSの問題を解決します：

```
Web Browser ←→ Cloudflare Tunnel ←→ Caddy (Reverse Proxy) ←→ Martin (PMTiles Server)
Webブラウザ ←→ Cloudflare Tunnel ←→ Caddy (リバースプロキシ) ←→ Martin (PMTilesサーバー)
```

**Key innovations / 主要な革新:**
- **X-Rewrite-URL header** for consistent HTTPS URL generation
- **X-Rewrite-URLヘッダー** による一貫したHTTPS URL生成
- **Centralized CORS handling** to prevent header conflicts  
- **集中CORS処理** によるヘッダー競合の防止
- **Path-specific OPTIONS handling** for proper preflight support
- **パス固有のOPTIONS処理** による適切なプリフライトサポート

For detailed technical documentation, see [`SETUP.md`](SETUP.md).
詳細な技術ドキュメントについては、[`SETUP.md`](SETUP.md)をご覧ください。

## Notes / 注意事項

- **Repository cleanliness** - Ensure the repository remains clean
- **リポジトリの清潔さ** - リポジトリを清潔に保つ
- **Documentation updates** - Regularly update `README.md` and `NOTES.md` to reflect changes
- **ドキュメント更新** - 変更を反映するため`README.md`と`NOTES.md`を定期的に更新
- **Tunnel configuration** - The Cloudflare tunnel name is configurable via the `tunnel_name` variable in the `Makefile`
- **Tunnel設定** - Cloudflare tunnelの名前は`Makefile`の`tunnel_name`変数で設定可能

## Related Documentation / 関連ドキュメント

- [`SETUP.md`](SETUP.md) - Detailed technical setup and troubleshooting / 詳細な技術セットアップとトラブルシューティング
- [`SERVICES.md`](SERVICES.md) - Available services and endpoints / 利用可能なサービスとエンドポイント
- [`NOTES.md`](NOTES.md) - Development notes and changelog / 開発ノートと変更履歴
- [`OPERATION.md`](OPERATION.md) - Basic operation procedure for x-24b / x-24bの基礎的な運用手順

## Historical Note / 歴史的記録

The x-24b system successfully operated for the first time on **2025-07-27**. This marks the beginning of its journey as a reliable and experimental web map server.

x-24bシステムは、**2025年7月27日**に初めて正常に稼働しました。これは、信頼性の高い実験的なウェブ地図サーバーとしての旅の始まりを示しています。

## Name Significance / 名前の意味

The name "x-24b" not only refers to the Martin tile server and its connection to Cloudflare but may also stand for "experimental 24-hour business." This could symbolize the goal of achieving 24/7 stable operation as a portable web map server, potentially running on devices like the Raspberry Pi 4B.

"x-24b"という名前は、MartinタイルサーバーとCloudflareとの接続を指すだけでなく、「experimental 24-hour business」の略でもあるかもしれません。これは、Raspberry Pi 4Bのようなデバイスで24時間365日安定稼働するポータブルなウェブ地図サーバーを目指すことを象徴している可能性があります。
