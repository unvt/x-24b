# Makefile for x-24b

# Variables
data_dir := data
urls_file := urls.txt
sprite_dir := sprite
font_dir := font
tunnel_name := gel-tunnel

# Targets
download:
	@echo "Downloading PMTiles files as .part..."
	@mkdir -p $(data_dir)
	@aria2c --conditional-get=true --max-download-limit=5242880 --max-concurrent-downloads=2 --split=2 --max-tries=10 --retry-wait=5 -i $(urls_file)

verify:
	@echo "Verifying PMTiles files..."
	@for file in $(data_dir)/*.part; do \
		if pmtiles verify $$file; then \
			echo "Valid PMTiles: $$file"; \
			mv $$file $${file%.part}; \
		else \
			echo "Invalid PMTiles: $$file"; \
		fi; \
	done

clean:
	@echo "Cleaning up..."
	@rm -rf $(data_dir)

martin:
	RUST_LOG=debug martin --config martin.yml

caddy:
	@echo "Starting Caddy server..."
	@caddy run --config Caddyfile

# Tunnel setup
tunnel:
	@echo "Setting up Cloudflare Tunnel..."
	@cloudflared tunnel run $(tunnel_name)

services:
	@echo "Generating SERVICES.md from martin.yml..."
	@ruby scripts/generate_services_md.rb --output SERVICES.md
	@echo "SERVICES.md updated."

monitor:
	ruby monitor.rb

download-mapterhorn:
	@echo "Downloading Mapterhorn PMTiles (large file)..."
	@mkdir -p $(data_dir)
	@cd $(data_dir) && aria2c -x 4 -s 4 --file-allocation=none --console-log-level=notice "https://download.mapterhorn.com/planet.pmtiles" -o mapterhorn.pmtiles

.PHONY: download verify clean martin tunnel caddy services monitor download-mapterhorn
