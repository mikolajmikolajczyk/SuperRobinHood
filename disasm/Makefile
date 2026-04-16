# Super Robin Hood NES disassembly build system
# Requires cc65 toolchain (ca65, ld65)

ROM     = ../roms/released.nes
ROM_ABS = ../roms/released.nes
TARGET  = build/game.nes

# SHA-256 of the Super Robin Hood (1990, Camerica) PRG cartridge dump.
# Lets users confirm they have the exact ROM this disassembly targets.
ROM_SHA256 = ae6c7a412732cba05490a4d355b7a619e201583b7f5b99d0148d888293a88076

RAWS    = raw/header.s raw/bank0.s raw/bank1.s raw/bank2.s raw/bank3.s
SRCS    = src/header.s src/bank0.s src/bank1.s src/bank2.s src/bank3.s
OBJS    = $(SRCS:src/%.s=build/%.o)
CFG     = game.cfg

DA65FLAGS =
CA65FLAGS = --cpu 6502
LD65FLAGS = -C $(CFG) -m build/game.map -Ln build/game.lbl

EMULATOR ?= fceux

.PHONY: all clean verify verify-rom run disasm extract-banks distclean

all: $(TARGET)

build/%.o: src/%.s | build
	ca65 $(CA65FLAGS) -o $@ $<

$(TARGET): $(OBJS) $(CFG) | build
	ld65 $(LD65FLAGS) -o $@ $(OBJS)

build:
	mkdir -p build

# Check that ../roms/released.nes is the expected dump before we rely on it.
verify-rom:
	@if [ ! -f "$(ROM_ABS)" ]; then \
	  echo "ERROR: $(ROM_ABS) not found."; \
	  echo "  Place a Super Robin Hood (Camerica, 1990) ROM at that path."; \
	  exit 1; \
	fi
	@actual=$$(sha256sum "$(ROM_ABS)" | awk '{print $$1}'); \
	if [ "$$actual" = "$(ROM_SHA256)" ]; then \
	  echo "ROM OK: $(ROM_ABS) sha256 matches."; \
	else \
	  echo "ERROR: $(ROM_ABS) sha256 mismatch."; \
	  echo "  expected: $(ROM_SHA256)"; \
	  echo "  actual:   $$actual"; \
	  echo "  This disassembly targets the Super Robin Hood (1990, Camerica) PRG-only dump."; \
	  exit 1; \
	fi

verify: $(TARGET) verify-rom
	cmp "$(ROM_ABS)" $(TARGET) && echo "MATCH: byte-identical!" || echo "MISMATCH"

verify-banks: $(TARGET)
	@echo "=== Header ==="
	@cmp -l -n 16 "$(ROM_ABS)" $(TARGET) 2>&1 | head -5 || echo "Header OK"
	@echo "=== Bank 0 (offset 16, 16384 bytes) ==="
	@cmp -l -i 16 -n 16384 "$(ROM_ABS)" $(TARGET) 2>&1 | head -5 || echo "Bank 0 OK"
	@echo "=== Bank 1 (offset 16400, 16384 bytes) ==="
	@cmp -l -i 16400 -n 16384 "$(ROM_ABS)" $(TARGET) 2>&1 | head -5 || echo "Bank 1 OK"
	@echo "=== Bank 2 (offset 32784, 16384 bytes) ==="
	@cmp -l -i 32784 -n 16384 "$(ROM_ABS)" $(TARGET) 2>&1 | head -5 || echo "Bank 2 OK"
	@echo "=== Bank 3 (offset 49168, 16384 bytes) ==="
	@cmp -l -i 49168 -n 16384 "$(ROM_ABS)" $(TARGET) 2>&1 | head -5 || echo "Bank 3 OK"

run: $(TARGET)
	$(EMULATOR) $(TARGET)

# Extract 4 × 16 KB PRG banks from the released ROM.
# Bank binaries are copyrighted and are NOT committed — regenerate here.
extract-banks: verify-rom | banks
	dd if="$(ROM_ABS)" of=banks/bank0.bin bs=16384 count=1 iflag=skip_bytes skip=16     status=none
	dd if="$(ROM_ABS)" of=banks/bank1.bin bs=16384 count=1 iflag=skip_bytes skip=16400  status=none
	dd if="$(ROM_ABS)" of=banks/bank2.bin bs=16384 count=1 iflag=skip_bytes skip=32784  status=none
	dd if="$(ROM_ABS)" of=banks/bank3.bin bs=16384 count=1 iflag=skip_bytes skip=49168  status=none

banks/bank%.bin: | extract-banks ;

# Regenerate raw/ from banks/ using da65 info files
disasm: extract-banks | raw
	da65 -i info/bank0.info -o raw/bank0.s banks/bank0.bin
	da65 -i info/bank1.info -o raw/bank1.s banks/bank1.bin
	da65 -i info/bank2.info -o raw/bank2.s banks/bank2.bin
	da65 -i info/bank3.info -o raw/bank3.s banks/bank3.bin
	@echo "raw/header.s is hand-written, already in raw/"

raw:
	mkdir -p raw

banks:
	mkdir -p banks

clean:
	rm -rf build

# Wipes everything that can be regenerated from released.nes
distclean: clean
	rm -rf banks
