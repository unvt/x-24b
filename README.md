# x-24b
Martin from Cloudflare Tunnel with multiple PMTiles support

# Development instructions
- This is a generalized version of https://github.com/optgeo/gel-tunnel.
- The basic structure is based on https://github.com/optgeo/gel-tunnel.
- x-24b can host multiple PMTiles in data directory.
- The list of PMTiles files are in list.csv
  - First column is the name of the PMTiles file.
  - Second column is the URL from which x-24b downloads them.
  - abc,https://server/directory/xyz.pmtiles means that x-24b downloads https://server/directory/xyz.pmtiles and save it as data/abc.pmtiles.
  - list.csv should be populated with gel.pmtiles.
- All the process is controlled by Makefile.
  - Makefile should have download, verify, clean, host, tunnel.
- Keep the repository clean.
- Create and update README.md and NOTES.md.
- 
