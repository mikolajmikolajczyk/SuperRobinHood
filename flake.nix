{
  description = "NES reverse engineering and development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Python environment with RE-useful libraries
        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          # Binary analysis / scripting
          capstone       # disassembly framework (supports 6502)
          # Data wrangling
          numpy
          pillow         # CHR tile / sprite sheet manipulation
        ]);

      in {
        devShells.default = pkgs.mkShell {
          name = "nes-re";

          packages = with pkgs; [
            # === Assembler / Linker / Compiler ===
            cc65               # ca65 assembler, ld65 linker, da65 disassembler, cc65 C compiler

            # === Emulators / Debuggers ===
            mesen              # primary: breakpoints, CDL, trace logger, memory viewer
            fceux              # secondary: Lua scripting, hex editor, CDL, PPU viewer

            # === Reverse Engineering ===
            ghidra-bin         # Ghidra with Sleigh 6502 support
            radare2            # CLI disassembler / hex editor (r2 -a 6502)
            rizin              # radare2 fork, modern tooling

            # === Hex / Binary Utilities ===
            xxd                # hex dump / patch
            hexyl              # colorized hex viewer
            binutils           # objdump, objcopy, strings
            diffutils          # diff / cmp for ROM comparison

            # === Scripting ===
            pythonEnv

            # === Rust ===
            cargo
            rustc

            # === Web (pp1web) ===
            nodejs

            # === Build / Automation ===
            gnumake
            just               # command runner (justfile)

            # === General Dev ===
            git
          ];

          shellHook = ''
            echo "=== NES RE Environment ==="
            echo "  Assembler:     ca65 / ld65 / da65  (cc65 suite)"
            echo "  Emulators:     mesen, fceux"
            echo "  RE tools:      ghidra, radare2, rizin"
            echo "  Hex:           xxd, hexyl"
            echo "  Scripting:     python3 + capstone + pillow
            echo "  Rust:          cargo + rustc""
            echo ""
            echo "  ROMs dir:      roms/"
            echo "  Quick start:   mesen roms/released.nes"
            echo ""

            # Convenient aliases
            alias disasm='da65'
            alias r2-nes='radare2 -a 6502 -b 8'
            alias rz-nes='rizin -a 6502 -b 8'
          '';
        };
      }
    );
}
