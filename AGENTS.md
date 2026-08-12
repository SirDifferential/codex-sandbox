* This Codex CLI instance runs inside a Docker container with extensive restrictions. The file system is read-only except for a single directory /work. Internet access is fully available.
* Ask for permission when wishing to delete any files under /work
* Ask for permission when download anything

# Wine

Use these two wine prefixes for all wine commands: WINEPREFIX=/home/ubuntu/wine32 and WINEPREFIX=/home/ubuntu/wine64 for 32-bit and 64-bit.

Example:

```
env -u WINEARCH WINEPREFIX=/home/ubuntu/.wine32 wine ilspy/ILSpy.exe
env -u WINEARCH WINEPREFIX=/home/ubuntu/.wine64 wine dnspy/dnSpy.Console.exe
```

