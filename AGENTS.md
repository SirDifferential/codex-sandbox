* This Codex CLI instance runs inside a Docker container with extensive restrictions. The file system is read-only except for a single directory /work. Internet access is fully available.
* Ask for permission when deleting any files under /work
* Ask for permission when downloading anything

# Installed software

Do not download new software without permission. Instead, use the software already installed into this environment. This includes:

## Compiling and toolchains

* GNU build toolchain (`build-essential`): `gcc`, `g++`, `make`, and standard development headers.
* LLVM toolchain (`llvm`): tools such as `llvm-objdump`, `llvm-readobj`, `llvm-nm`, `llvm-strings`, `llvm-dwarfdump`, `llvm-as`, `llvm-dis`, `llc`, and `opt`.
* GNU Binutils (`binutils`): `as`, `ld`, `ar`, `nm`, `objcopy`, `objdump`, `readelf`, `strings`, `strip`, `addr2line`, and related binary tools.
* OpenJDK 21 (`openjdk-21-jdk`): `java`, `javac`, `jar`, `javap`, `jdb`, and the rest of the JDK. `JAVA_HOME` for Ghidra is `/usr/lib/jvm/java-21-openjdk-amd64`.
* Node.js 20 and npm (`nodejs`): `node`, `npm`, and `npx`.
* Python 3 virtual-environment support (`python3-venv`): `python3 -m venv` and venv-local `pip`.

## Decompiling and reverse engineering

* Ghidra 12.1.3: `ghidra` for the GUI and `analyzeHeadless` for headless analysis. Both commands use the image's wrapper, which automatically configures Java 21 and a writable Ghidra home under `/tmp/ghidra-home`. Set `GHIDRA_USER_HOME` to override that directory.
* radare2 6.2.0: `r2`/`radare2`, plus companion tools including `rabin2`, `rasm2`, `rahash2`, `radiff2`, `rafind2`, `rarun2`, and `ragg2`.
* Cutter 2.5.0: `cutter`. The AppImage is extracted under `/opt/cutter`, so Cutter does not require FUSE at runtime.
* BinDiff 8: `bindiff`, including its Ghidra BinExport support for comparing disassemblies.
* Wine, 32-bit Wine, and Winetricks: `wine`, `wine64`, and `winetricks` for Windows reverse-engineering tools. Both Wine prefixes include .NET Framework 4.0.

## Malware analysis and file identification

* Detect It Easy 3.21: `diec` (console, GUI not available) for identifying executable formats, packers, and compilers.
* capa 9.4.0: `capa`, installed as `flare-capa` in `/opt/capa-venv`, for identifying executable capabilities. It is not the PyInstaller build, so it works when temporary filesystems prohibit executable mappings. 
* `file`: libmagic-based file type identification.
* `python3-pefile`: the `pefile` Python module and associated PE-analysis utilities.
* `python3-pil`: the Pillow Python imaging library for inspecting and transforming image data.

## Binary, text, and archive inspection

* `xxd`: hexadecimal dump creation and reversal.
* `jq`: JSON querying and transformation.
* `ripgrep`: fast recursive text search via `rg`.
* `cabextract`: Microsoft Cabinet archive extraction.
* `unzip`: ZIP archive listing, testing, and extraction.
* `poppler-utils`, `pdfplumber`, `pdftotext`, `pdfinfo`, `pypdf`: PDF parsing tools
* `tesseract`: OCR tooling

## Media and image analysis

* FFmpeg: `ffmpeg`, `ffprobe`, and related audio/video inspection and conversion tools.
* ImageMagick: `convert`, `identify`, `mogrify`, and related image inspection and conversion tools.

## Development and terminal utilities

* Git: `git` for version control and repository inspection.
* Vim: `vim` for terminal editing.
* tmux: `tmux` for persistent terminal sessions.
* Codex CLI: `codex`, installed globally through npm.

## Networking, signatures, and downloads

* curl: `curl` for HTTP and other URL transfers.
* Wget: `wget` for non-interactive downloads.
* GnuPG: `gpg` for signatures, encryption, and key management.
* CA certificates (`ca-certificates`) for TLS verification.

Downloads still require user permission under the container rules above.

## Isolation, virtual displays, and GUI support

* Bubblewrap: `bwrap` for filesystem/process sandbox construction, subject to the host container's namespace restrictions.
* X virtual framebuffer: `Xvfb` and `xvfb-run` for running GUI applications without a physical display.
* GUI runtime libraries: `libgl1`, `libopengl0`, `libxcb-cursor0`, `libxcb-xinerama0`, `libxcb-xkb1`, and `libxkbcommon-x11-0`. These support Detect It Easy, Cutter, Ghidra, and other graphical tools and are not standalone programs.

# Wine

Use these two Wine prefixes for all Wine commands: `WINEPREFIX=/home/ubuntu/.wine32` and `WINEPREFIX=/home/ubuntu/.wine64` for 32-bit and 64-bit.

Examples:

```
env -u WINEARCH WINEPREFIX=/home/ubuntu/.wine32 wine ilspy/ILSpy.exe
env -u WINEARCH WINEPREFIX=/home/ubuntu/.wine64 wine dnspy/dnSpy.Console.exe
```
