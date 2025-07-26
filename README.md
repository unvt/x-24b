# x-24b
Martin from Cloudflare Tunnel with multiple PMTiles support

## Overview
x-24b is a generalized version of [gel-tunnel](https://github.com/optgeo/gel-tunnel), designed to host multiple PMTiles in a data directory. It simplifies the process of downloading, verifying, and hosting PMTiles files.

## Why the name x-24b?
The name "x-24b" is a playful nod to the Martin tile server and its connection to Cloudflare. Just like the experimental X-24B aircraft, which was produced by Martin and used flares during landing, this project "lands" PMTiles with the help of Martin and Cloudflare. In aviation, a "flare" is a small nose-up operation performed just before landing to ensure a smooth touchdown. Similarly, this project ensures a smooth and efficient "landing" of PMTiles into your data directory. While we don't have actual flares, we do have blazing-fast tile hosting and a touch of humor to keep things grounded! For more about the X-24B aircraft, visit [this reference](https://www.nationalmuseum.af.mil/Visit/Museum-Exhibits/Fact-Sheets/Display/Article/195762/martin-x-24b/) and [this NASA image article](https://www.nasa.gov/image-article/x-24b-lifting-body/).

## Features
- Hosts multiple PMTiles files listed in `urls.txt`.
- Downloads PMTiles files using `aria2c` for batch processing.
- Controlled entirely via a `Makefile` with the following commands:
  - `download`: Fetch PMTiles files.
  - `verify`: Validate downloaded PMTiles files using `pmtiles verify`.
  - `clean`: Remove unnecessary files.
  - `host`: Serve PMTiles files using Martin.
  - `tunnel`: Establish a Cloudflare Tunnel.

## Usage
1. Populate `urls.txt` with PMTiles file details:
   - Example:
     ```
     https://server/directory/xyz.pmtiles
         output=data/xyz.pmtiles
     ```
2. Use the `Makefile` to manage the process.

## Notes
- Ensure the repository remains clean.
- Regularly update `README.md` and `NOTES.md` to reflect changes.
- See [SERVICES.md](SERVICES.md) for services by x-24b.
