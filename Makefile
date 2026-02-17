# init-agent Makefile
# Cross-platform build support

.PHONY: all build test clean install release help

# Default target
all: build

# Build for current platform
build:
	zig build -Doptimize=ReleaseFast

# Build debug version
debug:
	zig build

# Run tests
test:
	zig build test

# Clean build artifacts
clean:
	rm -rf zig-out zig-cache
	rm -rf dist
	rm -rf test-project*

# Install to /usr/local/bin (macOS/Linux)
install: build
	sudo cp zig-out/bin/init-agent /usr/local/bin/

# Install to ~/.local/bin (user install)
install-local: build
	mkdir -p ~/.local/bin
	cp zig-out/bin/init-agent ~/.local/bin/

# Cross-compilation targets
TARGETS := aarch64-macos x86_64-macos x86_64-linux aarch64-linux x86_64-windows

define build_target
release-$(1):
	@echo "Building for $(1)..."
	@mkdir -p dist
	zig build -Doptimize=ReleaseFast -Dtarget=$(1)
	cp zig-out/bin/init-agent dist/init-agent-$(1)
endef

$(foreach target,$(TARGETS),$(eval $(call build_target,$(target))))

# Build all release targets
release-all: $(addprefix release-,$(TARGETS))
	@echo "All releases built in dist/"

# Create release archives
package: release-all
	cd dist && for f in init-agent-*; do \
		if echo "$$f" | grep -q "windows"; then \
			zip "$$f.zip" "$$f"; \
		else \
			tar czf "$$f.tar.gz" "$$f"; \
		fi; \
	done
	@echo "Release packages created in dist/"

# Development helpers
run: debug
	./zig-out/bin/init-agent test-dev --lang python --no-git

dev-test: run
	@echo "--- Generated AGENTS.md ---"
	@cat test-dev/AGENTS.md | head -20
	@echo "..."
	@rm -rf test-dev

# Help
help:
	@echo "init-agent Makefile targets:"
	@echo ""
	@echo "  make build       - Build for current platform (release)"
	@echo "  make debug       - Build debug version"
	@echo "  make test        - Run tests"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make install     - Install to /usr/local/bin"
	@echo "  make install-local - Install to ~/.local/bin"
	@echo ""
	@echo "Cross-compilation:"
	@echo "  make release-aarch64-macos   - Build for Apple Silicon"
	@echo "  make release-x86_64-macos    - Build for Intel Mac"
	@echo "  make release-x86_64-linux    - Build for Linux x86_64"
	@echo "  make release-aarch64-linux   - Build for Linux ARM64"
	@echo "  make release-x86_64-windows  - Build for Windows"
	@echo "  make release-all             - Build all targets"
	@echo "  make package                 - Create release archives"
	@echo ""
	@echo "Development:"
	@echo "  make run         - Build and run test scaffold"
	@echo "  make dev-test    - Build, test, and clean up"
