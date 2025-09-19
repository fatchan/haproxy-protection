ESBUILD ?= esbuild
SRC_DIR := src/js
SRCS := $(filter-out $(addsuffix .min.js,$(basename $(wildcard $(SRC_DIR)/*.js))),$(wildcard $(SRC_DIR)/*.js))
MINS := $(SRCS:.js=.min.js)

.PHONY: all
all: $(MINS)

$(SRC_DIR)/%.min.js: $(SRC_DIR)/%.js
	@echo "minifying $< -> $@"
	$(ESBUILD) $< --minify --outfile=$@

.PHONY: file
# Usage: make file FILE=src/js/example.js
file:
	@if [ -z "$(FILE)" ]; then echo "set FILE=path/to/file.js"; exit 1; fi
	@outfile=$(printf "%s" "$(FILE)" | sed 's/\.js$/.min.js/'); \
	echo "minifying $(FILE) -> $outfile"; \
	$(ESBUILD) "$(FILE)" --minify --outfile="$outfile"

.PHONY: clean
clean:
	@rm -f $(MINS)
	@echo "removed $(MINS)"
