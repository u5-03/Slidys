# SlidysShare - App Store Screenshot Generation
SCRIPTS_DIR = Scripts

.PHONY: screenshots-ios screenshots-ipados screenshots-macos screenshots-visionos screenshots-all clean-screenshots

screenshots-ios:
	@bash $(SCRIPTS_DIR)/capture_screenshots.sh ios

screenshots-ipados:
	@bash $(SCRIPTS_DIR)/capture_screenshots.sh ipados

screenshots-macos:
	@bash $(SCRIPTS_DIR)/capture_screenshots.sh macos

screenshots-visionos:
	@bash $(SCRIPTS_DIR)/capture_screenshots.sh visionos

screenshots-all: screenshots-ios screenshots-ipados screenshots-macos screenshots-visionos
	@echo "=== Done ==="

clean-screenshots:
	@rm -rf screen_captures
	@echo "Cleaned"
