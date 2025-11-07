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
	@echo "Starting Martin server with daily 2AM JST restart..."
	@while true; do \
		martin --config martin.yml & \
		MARTIN_PID=$$!; \
		NOW_JST=$$(TZ=Asia/Tokyo date +%s); \
		TODAY_2AM=$$(TZ=Asia/Tokyo date -d "today 02:00:00" +%s 2>/dev/null || echo 0); \
		TOMORROW_2AM=$$(TZ=Asia/Tokyo date -d "tomorrow 02:00:00" +%s 2>/dev/null || echo $$(($$NOW_JST + 86400))); \
		if [ $$TODAY_2AM -gt $$NOW_JST ]; then \
			SLEEP_SEC=$$(($$TODAY_2AM - $$NOW_JST)); \
		else \
			SLEEP_SEC=$$(($$TOMORROW_2AM - $$NOW_JST)); \
		fi; \
		echo "Martin started (PID: $$MARTIN_PID). Next restart in $$(($$SLEEP_SEC / 3600)) hours."; \
		sleep $$SLEEP_SEC; \
		echo "Restarting Martin at 2AM JST..."; \
		kill $$MARTIN_PID 2>/dev/null || true; \
		wait $$MARTIN_PID 2>/dev/null || true; \
		sleep 2; \
	done

martin-debug:
	@echo "Starting Martin server (debug mode)..."
	@RUST_LOG=debug martin --config martin.yml

caddy:
	@echo "Starting Caddy server (quiet mode)..."
	@caddy run --config Caddyfile --adapter caddyfile 2>/dev/null

caddy-debug:
	@echo "Starting Caddy server (debug mode)..."
	@caddy run --config Caddyfile

# Tunnel setup
tunnel:
	@echo "Setting up Cloudflare Tunnel (quiet mode)..."
	@cloudflared tunnel run $(tunnel_name) 2>/dev/null

tunnel-debug:
	@echo "Setting up Cloudflare Tunnel (debug mode)..."
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

.PHONY: download verify clean martin martin-debug caddy caddy-debug tunnel tunnel-debug services monitor download-mapterhorn
