# NOTES

## Overview
This document contains supplementary notes for the x-24b project.

## Key Points
- **PMTiles Hosting**: Managed by Martin, which dynamically serves tiles, sprites, and fonts.
- **Makefile Tasks**:
  - `download`: Fetch PMTiles files listed in `urls.txt` using `aria2c`. Files are downloaded with a `.part` extension.
  - `verify`: Validate the presence and integrity of PMTiles files using `pmtiles verify`. Valid files are renamed to remove the `.part` extension.
  - `clean`: Remove all files in the `data` directory.
  - `host`: Use Martin to serve PMTiles files along with sprites and fonts. Partially downloaded files are excluded.
  - `tunnel`: Set up a Cloudflare Tunnel.

## Notes
- Ensure `urls.txt` is properly formatted before running `make download`.
- Martin does not require explicit directory creation for hosting tasks.
- Update this document as the project evolves.
