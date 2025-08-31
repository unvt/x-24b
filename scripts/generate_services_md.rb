#!/usr/bin/env ruby
require 'yaml'
require 'optparse'
require 'pathname'

martin_yml = Pathname.new(__dir__).join('..', 'martin.yml')
default_output_md = Pathname.new(__dir__).join('..', 'SERVICES.md')

output_md = default_output_md
OptionParser.new do |opts|
  opts.on('--output FILE', 'Output file') { |v| output_md = Pathname.new(__dir__).join('..', v) }
end.parse!(ARGV)

config = YAML.load_file(martin_yml)
pmtiles = config['pmtiles'] || {}
paths = pmtiles['paths'] || []

service_names = {
  'experimental-dili-beta' => 'Experimental Dili Beta / 実験的ディリベータ',
  'bvmap' => 'BVMap / BVマップ',
  'planet' => 'Planet / プラネット',
  'gel' => 'Gel / ジェル',
  'terrain22' => 'Terrain22 / 地形22',
  'addresses' => 'Addresses / 住所',
}

header = <<~EOS
# Services by x-24b / x-24b提供サービス

> See also: [README.md](README.md) / [SETUP.md](SETUP.md) / [OPERATION.md](OPERATION.md) / [NOTES.md](NOTES.md)
> 参照: [README.md](README.md) / [SETUP.md](SETUP.md) / [OPERATION.md](OPERATION.md) / [NOTES.md](NOTES.md)

---

> **Note:** All documentation uses English first, then Japanese for clarity and consistency.
> **注:** すべてのドキュメントは英語→日本語の順で記載しています。

## Current Services / 現在のサービス
EOS

service_block = <<~EOS
### %{name}

**TileJSON Endpoint / TileJSONエンドポイント:**  
%{tilejson_url}
- Retrieve a TileJSON response describing the %{name_en} PMTiles source
- %{name_en} PMTilesソースを記述するTileJSONレスポンスを取得

**Tile Access / タイルアクセス:**  
%{tile_url}
- Access individual map tiles for the %{name_en} dataset
- %{name_en}データセット用の個々のマップタイルにアクセス

**Features / 機能:**
- ✅ **HTTPS URLs** - Consistent HTTPS URL generation / 一貫したHTTPS URL生成
- ✅ **CORS Support** - Full cross-origin request support / 完全なクロスオリジンリクエストサポート  
- ✅ **Production Ready** - Enterprise-grade reliability / エンタープライズグレードの信頼性
EOS

future_services = <<~EOS
## Future Services / 今後のサービス

### Gel / ジェル
**TileJSON Endpoint / TileJSONエンドポイント:**  
https://tunnel.optgeo.org/martin/gel
- Retrieve a TileJSON response describing the Gel PMTiles source
- Gel PMTilesソースを記述するTileJSONレスポンスを取得

**Tile Access / タイルアクセス:**  
https://tunnel.optgeo.org/martin/gel/{z}/{x}/{y}
- Access individual map tiles for the Gel dataset
- Gelデータセット用の個々のマップタイルにアクセス
EOS

footer = <<~EOS
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
EOS

File.open(output_md, 'w') do |f|
  f.write(header)
  paths.each do |path|
    basename = File.basename(path)
    name_key = basename.sub(/\.pmtiles$/, '')
    name = service_names[name_key] || name_key
    name_en = name.include?(' / ') ? name.split(' / ').first : name
    tilejson_url = "https://tunnel.optgeo.org/martin/#{name_key}"
    tile_url = "https://tunnel.optgeo.org/martin/#{name_key}/{z}/{x}/{y}"
    f.write(service_block % {name: name, name_en: name_en, tilejson_url: tilejson_url, tile_url: tile_url})
  end
  f.write(future_services)
  f.write(footer)
end
