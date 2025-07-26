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
	@aria2c --conditional-get=true -i $(urls_file)

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

host:
	@echo "Hosting PMTiles files with Martin..."
	@if [ -d $(font_dir) ] && [ "$(shell ls -A $(font_dir))" ]; then \
		martin $(data_dir) --sprite $(sprite_dir) --font $(font_dir) --webui enable-for-all; \
	else \
		echo "Warning: No font files found. Skipping font configuration."; \
		martin $(data_dir) --sprite $(sprite_dir) --webui enable-for-all; \
	fi

# Tunnel setup
tunnel:
	@echo "Setting up Cloudflare Tunnel..."
	@cloudflared tunnel run $(tunnel_name)

.PHONY: download verify clean host tunnel
