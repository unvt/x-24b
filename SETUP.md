# PMTiles Server Setup Documentation / PMTilesサーバーセットアップドキュメント

> See also: [README.md](README.md) / [SERVICES.md](SERVICES.md) / [OPERATION.md](OPERATION.md) / [NOTES.md](NOTES.md)
> 参照: [README.md](README.md) / [SERVICES.md](SERVICES.md) / [OPERATION.md](OPERATION.md) / [NOTES.md](NOTES.md)

---

> **Note:** All documentation uses English first, then Japanese for clarity and consistency.
> **注:** すべてのドキュメントは英語→日本語の順で記載しています。

## Problem Statement / 問題の概要

When serving PMTiles files through Martin behind a reverse proxy (Caddy) and accessed via a Cloudflare Tunnel, several critical issues emerged that prevented proper web map functionality:

Martin を Caddy のリバースプロキシ経由で配信し、Cloudflare Tunnel でアクセスする際に、Webマップの正常な機能を妨げるいくつかの重大な問題が発生しました：

### Issues Encountered / 発生した問題

1. **Incorrect URL Generation / 不正なURL生成**
   - **Expected / 期待値**: `https://tunnel.optgeo.org/martin/experimental-dili-beta/{z}/{x}/{y}`
   - **Got / 実際の結果**: `http://localhost:8080/experimental-dili-beta/{z}/{x}/{y}`
   - **Impact / 影響**: Web maps cannot load tiles due to mixed content errors (HTTPS page trying to load HTTP resources)
   - **影響**: Mixed Contentエラーにより、Webマップがタイルをロードできない（HTTPSページがHTTPリソースをロードしようとする）

2. **CORS Header Conflicts / CORSヘッダーの競合**
   - **Problem / 問題**: Duplicate CORS headers when both Martin and Caddy add them
   - **問題**: MartinとCaddyの両方がCORSヘッダーを追加することで重複が発生
   - **Impact / 影響**: Browser CORS errors blocking web map access from different domains
   - **影響**: ブラウザのCORSエラーにより、異なるドメインからのWebマップアクセスがブロックされる

3. **OPTIONS Preflight Failures / OPTIONSプリフライトの失敗**
   - **Problem / 問題**: Martin returns 405 Method Not Allowed for OPTIONS requests
   - **問題**: MartinがOPTIONSリクエストに対して405 Method Not Allowedを返す
   - **Impact / 影響**: Complex CORS requests fail during preflight phase
   - **影響**: 複雑なCORSリクエストがプリフライト段階で失敗する

## Solution Overview / 解決策の概要

The solution implements a three-layer architecture with precise header management and URL rewriting:

この解決策は、正確なヘッダー管理とURL書き換えを伴う3層アーキテクチャを実装しています：

### Architecture / アーキテクチャ

```
Web Browser ←→ Cloudflare Tunnel ←→ Caddy (Reverse Proxy) ←→ Martin (PMTiles Server)
Webブラウザ ←→ Cloudflare Tunnel ←→ Caddy (リバースプロキシ) ←→ Martin (PMTilesサーバー)
```

### Key Solutions / 主要な解決策

1. **X-Rewrite-URL Header / X-Rewrite-URLヘッダー**
   - **Purpose / 目的**: Provides complete external URL structure to Martin
   - **目的**: Martinに完全な外部URL構造を提供
   - **Result / 結果**: Consistent HTTPS URLs in all TileJSON responses
   - **結果**: すべてのTileJSONレスポンスで一貫したHTTPS URLを生成

2. **Centralized CORS Handling / 集中CORS処理**
   - **Implementation / 実装**: CORS handled only at Caddy level, disabled in Martin
   - **実装**: CORSはCaddyレベルでのみ処理、Martinでは無効化
   - **Result / 結果**: Single, clean CORS headers without conflicts
   - **結果**: 競合のない単一で清潔なCORSヘッダー

3. **Path-Specific Preflight Handling / パス固有のプリフライト処理**
   - **Implementation / 実装**: OPTIONS handling within Martin path block
   - **実装**: Martinパスブロック内でのOPTIONS処理
   - **Result / 結果**: Proper CORS preflight support for complex requests
   - **結果**: 複雑なリクエストに対する適切なCORSプリフライトサポート

## Key Configuration Files / 主要な設定ファイル

### Martin Configuration (martin.yml) / Martin設定 (martin.yml)

**Final Working Configuration / 最終的な動作設定:**
```yaml
pmtiles: 
  paths: 
    - data/experimental-dili-beta.pmtiles
web_ui: enable-for-all
base_url: "https://tunnel.optgeo.org/martin"
cors: false
```

**Key Points / 重要なポイント:**
- `cors: false` - Prevents duplicate CORS headers (handled by Caddy)
- `cors: false` - 重複CORSヘッダーを防ぐ（Caddyで処理）
- `base_url` - Ensures consistent HTTPS URL generation
- `base_url` - 一貫したHTTPS URL生成を保証
- `web_ui: enable-for-all` - Enables Martin's web interface
- `web_ui: enable-for-all` - MartinのWebインターフェースを有効化

### Caddy Configuration (Caddyfile) / Caddy設定 (Caddyfile)

**Final Working Configuration / 最終的な動作設定:**
```caddyfile
:8080 {
    # Serve static files from the data folder
    root * ./data
    file_server

    # Enable debug logging
    log {
        output stdout
        level DEBUG
    }

    # Add CORS headers to all responses
    header Access-Control-Allow-Origin "*"
    header Access-Control-Allow-Methods "GET, POST, OPTIONS"
    header Access-Control-Allow-Headers "*"

    # Reverse-proxy requests to martin
    handle_path /martin/* {
        # Handle OPTIONS preflight requests for martin paths
        @martin_preflight method OPTIONS
        handle @martin_preflight {
            header Access-Control-Allow-Origin "*"
            header Access-Control-Allow-Methods "GET, POST, OPTIONS"
            header Access-Control-Allow-Headers "*"
            header Access-Control-Max-Age "86400"
            respond 204
        }
        
        uri strip_prefix /martin
        reverse_proxy localhost:3000 {
            # Force HTTPS URL structure
            header_up X-Rewrite-URL "https://tunnel.optgeo.org/martin{http.request.uri}"
            # Additional insurance headers
            header_up X-Forwarded-Proto "https"
            header_up X-Forwarded-Host "tunnel.optgeo.org"
            header_up X-Forwarded-Port "443"
            header_up X-Scheme "https"
        }
    }
}
```

**Key Features / 主要機能:**
- **Path Stripping / パス除去**: `uri strip_prefix /martin` removes `/martin` from URLs before forwarding
- **パス除去**: `uri strip_prefix /martin` でURLから `/martin` を除去してから転送
- **X-Rewrite-URL**: Provides complete external URL structure to Martin
- **X-Rewrite-URL**: Martinに完全な外部URL構造を提供
- **Preflight Handling / プリフライト処理**: Dedicated OPTIONS handling for CORS compliance
- **プリフライト処理**: CORS準拠のための専用OPTIONS処理
- **Multiple Headers / 複数ヘッダー**: Insurance against Cloudflare header modifications
- **複数ヘッダー**: Cloudflareのヘッダー変更に対する保険

## Testing and Validation / テストと検証

### URL Consistency Test / URL一貫性テスト

**Test Commands / テストコマンド:**
```bash
# Test via localhost / localhost経由でテスト
curl -s localhost:8080/martin/experimental-dili-beta | jq '.tiles[0]'

# Test via tunnel / tunnel経由でテスト  
curl -s tunnel.optgeo.org/martin/experimental-dili-beta | jq '.tiles[0]'
```

**Expected Result / 期待される結果:**
Both should return: `"https://tunnel.optgeo.org/martin/experimental-dili-beta/{z}/{x}/{y}"`
両方とも以下を返すべき: `"https://tunnel.optgeo.org/martin/experimental-dili-beta/{z}/{x}/{y}"`

### CORS Header Test / CORSヘッダーテスト

**Test Commands / テストコマンド:**
```bash
# Test CORS headers / CORSヘッダーをテスト
curl -I localhost:8080/martin/experimental-dili-beta
curl -I tunnel.optgeo.org/martin/experimental-dili-beta

# Test OPTIONS preflight / OPTIONSプリフライトをテスト
curl -X OPTIONS -I localhost:8080/martin/experimental-dili-beta
curl -X OPTIONS -I tunnel.optgeo.org/martin/experimental-dili-beta
```

**Expected Results / 期待される結果:**
- Single `Access-Control-Allow-Origin: *` header (no duplicates)
- 単一の `Access-Control-Allow-Origin: *` ヘッダー（重複なし）
- OPTIONS requests return `204 No Content` with proper CORS headers
- OPTIONSリクエストは適切なCORSヘッダーと共に `204 No Content` を返す

### Tile Access Test / タイルアクセステスト

**Test Command / テストコマンド:**
```bash
# Test actual tile request / 実際のタイルリクエストをテスト
curl -I "https://tunnel.optgeo.org/martin/experimental-dili-beta/10/853/384"
```

**Expected Result / 期待される結果:**
- `200 OK` response with tile data
- `200 OK` レスポンスとタイルデータ
- Proper CORS headers for cross-origin access
- クロスオリジンアクセス用の適切なCORSヘッダー

## What This Achieves / これによって実現されること

### For Developers / 開発者向け
- **Reliable tile serving** from any web mapping application
- **信頼性の高いタイル配信** を任意のWebマッピングアプリケーションから
- **Consistent HTTPS URLs** regardless of access method (localhost vs tunnel)
- **一貫したHTTPS URL** をアクセス方法に関係なく（localhost vs tunnel）
- **Full CORS compliance** for cross-origin requests
- **完全なCORS準拠** でクロスオリジンリクエストに対応

### For End Users / エンドユーザー向け
- **Fast, reliable map loading** without mixed content errors
- **高速で信頼性の高いマップ読み込み** でMixed Contentエラーなし
- **Seamless experience** across different domains and applications
- **シームレスな体験** を異なるドメインとアプリケーション間で
- **Production-ready tile hosting** with enterprise-grade reliability
- **本番環境対応のタイル配信** でエンタープライズグレードの信頼性

## Troubleshooting History / トラブルシューティング履歴

This solution evolved through several iterations to address specific issues:
この解決策は、特定の問題に対処するためにいくつかの反復を経て進化しました：

1. **Initial attempt**: Used `base_path` in Martin - caused path conflicts
   **初期の試み**: Martinで `base_path` を使用 - パスの競合が発生

2. **Second attempt**: Used individual forwarded headers - inconsistent results
   **2回目の試み**: 個別の転送ヘッダーを使用 - 一貫性のない結果

3. **Third attempt**: Global CORS in both Martin and Caddy - duplicate headers
   **3回目の試み**: MartinとCaddyの両方でグローバルCORS - ヘッダーの重複

4. **Final solution**: X-Rewrite-URL + Caddy-only CORS + path-specific preflight
   **最終解決策**: X-Rewrite-URL + CaddyのみのCORS + パス固有のプリフライト

Each iteration taught us something important about the interaction between reverse proxies, tile servers, and browser CORS requirements.
各反復により、リバースプロキシ、タイルサーバー、ブラウザのCORS要件間の相互作用について重要なことを学びました。

## The Critical Solution: X-Rewrite-URL

The key breakthrough was using the `X-Rewrite-URL` header:

```
header_up X-Rewrite-URL "https://tunnel.optgeo.org/martin{http.request.uri}"
```

This tells Martin exactly what the complete external URL should be, including:
- HTTPS scheme
- External hostname (tunnel.optgeo.org)
- Full path with /martin prefix

## Request Flow

1. Client requests: `https://tunnel.optgeo.org/martin/experimental-dili-beta`
2. Cloudflare Tunnel forwards to: `http://localhost:8080/martin/experimental-dili-beta`
3. Caddy processes:
   - Strips `/martin` prefix
   - Adds headers including X-Rewrite-URL
   - Forwards to Martin: `http://localhost:3000/experimental-dili-beta`
4. Martin generates TileJSON with correct URLs using X-Rewrite-URL

## Testing Commands

```bash
# Test endpoints
curl -s http://localhost:8080/martin/experimental-dili-beta | jq .tiles[0]
curl -s https://tunnel.optgeo.org/martin/experimental-dili-beta | jq .tiles[0]

# Both should return:
# "https://tunnel.optgeo.org/martin/experimental-dili-beta/{z}/{x}/{y}"
```

## Troubleshooting History

- Initial attempts with only X-Forwarded-Proto and X-Forwarded-Host failed
- Martin did not respect individual forwarded headers
- X-Rewrite-URL with complete URL structure was the solution
- Path stripping in Caddy eliminated need for base_path in Martin

This configuration ensures proper HTTPS URL generation in TileJSON responses for PMTiles served through a reverse proxy setup.

---

For more information, see [README.md](README.md), [OPERATION.md](OPERATION.md), [SERVICES.md](SERVICES.md), [NOTES.md](NOTES.md).
詳細は [README.md](README.md)、[OPERATION.md](OPERATION.md)、[SERVICES.md](SERVICES.md)、[NOTES.md](NOTES.md) をご覧ください。
