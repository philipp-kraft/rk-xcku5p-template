# xcku5p template. Run `make help` for targets.

TOP  ?= top
PART ?= xcku5p-ffvb676-2-i

BUILD := build
RUN   := scripts/vivado.sh
RTL   := $(wildcard rtl/*.sv)
XDC   := $(wildcard constraints/*.xdc)

# Vivado can exit 0 even when it fails (e.g. license or library errors at
# startup), so each stage deletes its output first and checks it was rewritten.
CHECK = test -f $@ || { echo "error: $@ not written, see the log in $(BUILD)/" >&2; exit 1; }

SYNTH_DCP := $(BUILD)/$(TOP)_synth.dcp
ROUTE_DCP := $(BUILD)/$(TOP)_route.dcp
BIT       := $(BUILD)/$(TOP).bit

.PHONY: all synth impl bitstream program gui clean help

all: bitstream

## synth     synthesize
synth: $(SYNTH_DCP)

## impl      opt, place, route
impl: $(ROUTE_DCP)

## bitstream write build/<top>.bit
bitstream: $(BIT)

## program   load the bitstream over JTAG
program: $(BIT)
	$(RUN) scripts/program.tcl $(TOP)

## gui       open the newest checkpoint in the Vivado GUI
gui:
	@dcp=$$(ls -t $(ROUTE_DCP) $(SYNTH_DCP) 2>/dev/null | head -n 1); \
	if [ -z "$$dcp" ]; then echo "no checkpoint, run 'make synth' first" >&2; exit 1; fi; \
	$(RUN) --gui "$$dcp"

$(SYNTH_DCP): $(RTL) $(XDC) scripts/synth.tcl
	@rm -f $@
	$(RUN) scripts/synth.tcl $(TOP) $(PART)
	@$(CHECK)

$(ROUTE_DCP): $(SYNTH_DCP) scripts/impl.tcl
	@rm -f $@
	$(RUN) scripts/impl.tcl $(TOP)
	@$(CHECK)

$(BIT): $(ROUTE_DCP) scripts/bit.tcl
	@rm -f $@
	$(RUN) scripts/bit.tcl $(TOP)
	@$(CHECK)

## clean     delete build/
clean:
	rm -rf $(BUILD)

## help      show this help
help:
	@echo "Targets:"
	@sed -n 's/^## /  /p' $(MAKEFILE_LIST)
	@echo
	@echo "Variables: TOP=$(TOP) PART=$(PART)"
