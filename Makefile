.PHONY: help
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: skillsaw
skillsaw: ## Run skillsaw linter on skills and plugins
	@echo "Running skillsaw..."
	@if [ -n "$${SKILLSAW_BIN:-}" ]; then \
		"$${SKILLSAW_BIN}"; \
	else \
		uvx skillsaw; \
	fi

.PHONY: skillsaw-fix
skillsaw-fix: ## Auto-fix fixable skillsaw issues
	@echo "Fixing skillsaw issues..."
	@if [ -n "$${SKILLSAW_BIN:-}" ]; then \
		"$${SKILLSAW_BIN}" fix; \
	else \
		uvx skillsaw fix; \
	fi

.PHONY: lint
lint: ## Run all linters
	@$(MAKE) skillsaw

ARCH_ANALYZER_VERSION ?= v0.1.0
ARCH_ANALYZER_REPO := ugiordan/architecture-analyzer
ARCH_ANALYZER_SHA256_darwin_arm64 := 6d57c439bf0562276cda00f8d7e321b5819e3de1e01831246af475b03187580a
ARCH_ANALYZER_SHA256_linux_amd64  := 0d30cd39080fd771540bf404f86088d73c6db74e1a276f81a5c4597db05351f5

.PHONY: install-arch-analyzer
install-arch-analyzer: ## Download arch-analyzer binary to bin/
	@mkdir -p bin
	@OS=$$(uname -s | tr '[:upper:]' '[:lower:]'); \
	ARCH=$$(uname -m); \
	case "$$ARCH" in x86_64) ARCH=amd64;; aarch64|arm64) ARCH=arm64;; esac; \
	BINARY="arch-analyzer-$${OS}-$${ARCH}"; \
	EXPECTED=$$(eval echo "\$$ARCH_ANALYZER_SHA256_$${OS}_$${ARCH}"); \
	if [ -z "$$EXPECTED" ]; then \
		echo "ERROR: no pinned checksum for $${OS}-$${ARCH}"; exit 1; \
	fi; \
	URL="https://github.com/$(ARCH_ANALYZER_REPO)/releases/download/$(ARCH_ANALYZER_VERSION)/$${BINARY}"; \
	echo "Downloading $${BINARY} $(ARCH_ANALYZER_VERSION)..."; \
	curl -fsSL "$$URL" -o bin/arch-analyzer && chmod +x bin/arch-analyzer; \
	ACTUAL=$$(shasum -a 256 bin/arch-analyzer | awk '{print $$1}'); \
	if [ "$$EXPECTED" = "$$ACTUAL" ]; then \
		echo "OK: bin/arch-analyzer (sha256:$$ACTUAL)"; \
	else \
		echo "ERROR: checksum mismatch"; \
		echo "  expected: $$EXPECTED"; \
		echo "  got:      $$ACTUAL"; \
		rm -f bin/arch-analyzer; exit 1; \
	fi

.DEFAULT_GOAL := help
