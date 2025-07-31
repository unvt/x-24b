# Services by x-24b / x-24b提供サービス

> See also: [README.md](README.md) / [SETUP.md](SETUP.md) / [OPERATION.md](OPERATION.md) / [NOTES.md](NOTES.md)
> 参照: [README.md](README.md) / [SETUP.md](SETUP.md) / [OPERATION.md](OPERATION.md) / [NOTES.md](NOTES.md)

---

> **Note:** All documentation uses English first, then Japanese for clarity and consistency.
> **注:** すべてのドキュメントは英語→日本語の順で記載しています。

## Current Services / 現在のサービス

### Experimental Dili Beta / 実験的ディリベータ

**TileJSON Endpoint / TileJSONエンドポイント:**  
[https://tunnel.optgeo.org/martin/experimental-dili-beta](https://tunnel.optgeo.org/martin/experimental-dili-beta)
- Retrieve a TileJSON response describing available PMTiles sources, including metadata and tile access URLs
- メタデータとタイルアクセスURLを含む、利用可能なPMTilesソースを記述するTileJSONレスポンスを取得

**Tile Access / タイルアクセス:**  
[https://tunnel.optgeo.org/martin/experimental-dili-beta/{z}/{x}/{y}](https://tunnel.optgeo.org/martin/experimental-dili-beta/{z}/{x}/{y})
- Access individual map tiles using the `{z}/{x}/{y}` format for zoom, x, and y coordinates
- ズーム、x、y座標の`{z}/{x}/{y}`形式を使用して個々のマップタイルにアクセス

**Features / 機能:**
- ✅ **HTTPS URLs** - Consistent HTTPS URL generation / 一貫したHTTPS URL生成
- ✅ **CORS Support** - Full cross-origin request support / 完全なクロスオリジンリクエストサポート  
- ✅ **Production Ready** - Enterprise-grade reliability / エンタープライズグレードの信頼性

### BVMap / BVマップ

**TileJSON Endpoint / TileJSONエンドポイント:**  
[https://tunnel.optgeo.org/martin/bvmap](https://tunnel.optgeo.org/martin/bvmap)
- Retrieve a TileJSON response describing the BVMap PMTiles source
- BVMap PMTilesソースを記述するTileJSONレスポンスを取得

**Tile Access / タイルアクセス:**  
[https://tunnel.optgeo.org/martin/bvmap/{z}/{x}/{y}](https://tunnel.optgeo.org/martin/bvmap/{z}/{x}/{y})
- Access individual map tiles for the BVMap dataset
- BVMapデータセット用の個々のマップタイルにアクセス

**Features / 機能:**
- ✅ **HTTPS URLs** - Consistent HTTPS URL generation / 一貫したHTTPS URL生成
- ✅ **CORS Support** - Full cross-origin request support / 完全なクロスオリジンリクエストサポート  
- ✅ **Production Ready** - Enterprise-grade reliability / エンタープライズグレードの信頼性

### Planet / プラネット

**TileJSON Endpoint / TileJSONエンドポイント:**  
[https://tunnel.optgeo.org/martin/planet](https://tunnel.optgeo.org/martin/planet)
- Retrieve a TileJSON response describing the Planet PMTiles source
- Planet PMTilesソースを記述するTileJSONレスポンスを取得

**Tile Access / タイルアクセス:**  
[https://tunnel.optgeo.org/martin/planet/{z}/{x}/{y}](https://tunnel.optgeo.org/martin/planet/{z}/{x}/{y})
- Access individual map tiles for the Planet dataset
- Planetデータセット用の個々のマップタイルにアクセス

**Features / 機能:**
- ✅ **HTTPS URLs** - Consistent HTTPS URL generation / 一貫したHTTPS URL生成
- ✅ **CORS Support** - Full cross-origin request support / 完全なクロスオリジンリクエストサポート  
- ✅ **Production Ready** - Enterprise-grade reliability / エンタープライズグレードの信頼性

## Future Services / 今後のサービス

### Gel / ジェル
**TileJSON Endpoint / TileJSONエンドポイント:**  
[https://tunnel.optgeo.org/martin/gel](https://tunnel.optgeo.org/martin/gel)
- Retrieve a TileJSON response describing the Gel PMTiles source
- Gel PMTilesソースを記述するTileJSONレスポンスを取得

**Tile Access / タイルアクセス:**  
[https://tunnel.optgeo.org/martin/gel/{z}/{x}/{y}](https://tunnel.optgeo.org/martin/gel/{z}/{x}/{y})
- Access individual map tiles for the Gel dataset
- Gelデータセット用の個々のマップタイルにアクセス

## Technical Specifications / 技術仕様

**All services provide / すべてのサービスが提供:**
- **CORS Headers** - `Access-Control-Allow-Origin: *` for cross-domain access
- **CORSヘッダー** - クロスドメインアクセス用の`Access-Control-Allow-Origin: *`
- **HTTPS URLs** - Consistent HTTPS URL generation in all TileJSON responses
- **HTTPS URL** - すべてのTileJSONレスポンスで一貫したHTTPS URL生成
- **OPTIONS Support** - Proper preflight handling for complex CORS requests
- **OPTIONSサポート** - 複雑なCORSリクエスト用の適切なプリフライト処理
- **High Performance** - Optimized tile serving through Cloudflare CDN
- **高性能** - Cloudflare CDN経由の最適化されたタイル配信

**For Developers / 開発者向け:**
- Use these endpoints directly in your web mapping applications (OpenLayers, Leaflet, Mapbox GL JS, etc.)
- これらのエンドポイントをWebマッピングアプリケーション（OpenLayers、Leaflet、Mapbox GL JSなど）で直接使用
- All endpoints support standard PMTiles specifications
- すべてのエンドポイントは標準のPMTiles仕様をサポート
- Reliable for production use with enterprise-grade infrastructure
- エンタープライズグレードのインフラで本番環境での使用に信頼性

Enjoy seamless and efficient tile hosting with x-24b!  
x-24bでシームレスで効率的なタイルホスティングをお楽しみください！

