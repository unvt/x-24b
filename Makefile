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
	@aria2c --conditional-get=true --max-download-limit=1048576 -i $(urls_file)

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
	@python3 scripts/generate_services_md.py --output SERVICES.md
	@echo "SERVICES.md updated."

monitor:
	ruby monitor.rb

.PHONY: download verify clean martin tunnel caddy services monitor
