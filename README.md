# TinyPad: A Bare-Metal Win32 Text Editor

TinyPad is a brutalist, zero-dependency graphical text editor for Windows, written entirely from scratch in pure x86 Assembly. Clocking in at roughly **~3.5 KB**, it represents an absolute rejection of modern software bloat. There are no web wrappers, no heavy virtual machines, and no C Runtime Library (CRT) linking. It communicates strictly and exclusively with the raw Win32 API.

While modern text editors consume gigabytes of RAM to render simple ASCII text, TinyPad operates at the kernel's edge. It provides an uncompromised, lightning-fast text editing environment by aggressively optimizing its memory footprint, instruction set, and system integration.

## Architectural Philosophy & Core Mechanics

The entire application is constructed around a single, highly optimized source file (`TinyPad.asm`). Every byte has been accounted for, and every abstraction layer has been stripped away.

*   **Section Merging & Alignment:** To eliminate the standard padding and alignment waste introduced by modern linkers, TinyPad merges its static data (`.data`) directly into the code segment (`.text`). This structural compression allows the PE32 (Portable Executable) headers to remain pure and readable, achieving a microscopic file size without relying on aggressive demoscene executable packers like Crinkler or UPX.
*   **Static Memory Allocation:** TinyPad utilizes a calculated, statically allocated **64 KB buffer** (`textBuffer resb 64000`) at startup. This guarantees zero heap fragmentation during runtime, bypassing the overhead of dynamic memory managers (like `HeapAlloc`). It flawlessly handles thousands of words of pure text, managing End-Of-File (EOF) states and byte streams directly at the pointer level.
*   **Instant Context Switching:** Startup time is virtually zero, constrained exclusively by the operating system's internal thread context-switching speed.

## Feature Breakdown: How It Works

TinyPad maintains all the fundamental features required for pure text manipulation without yielding a single CPU clock cycle to unnecessary background processing.

| Feature Area | Implementation Details |
| :--- | :--- |
| **Direct UI Control** | Bypasses bulky UI frameworks. The editor is a single `EDIT` class window (`CreateWindowExA`), handling its own message loop. Resizing is handled via raw `GetClientRect` and `MoveWindow` calls. |
| **Instantaneous I/O** | File loading and saving bypass standard I/O streams. Operations utilize raw `CreateFileA`, `ReadFile`, and `WriteFile` handles, directly instructing the disk controller. |
| **Key Interception** | Instead of relying on slow accelerator tables, the message loop directly polls keyboard states via `GetAsyncKeyState`. `Ctrl+S` triggers a direct memory-to-disk write. |
| **Zero-Byte Icon Integration** | Registry injection dynamically points to internal Windows system libraries (`imageres.dll,-102`), forcing the OS to render an authentic native text icon at zero byte cost. |

## Aggressive System Integration

The deployment strategy is as ruthless as the code itself. Instead of bloated MSI installers, TinyPad utilizes raw batch scripts to interact directly with the Windows Registry.

*   **Context Menu Hijacking:** The `install.bat` script surgically modifies `HKCU\Software\Classes`, replacing the default `.txt` file associations. It binds TinyPad directly to the native Windows right-click "New" menu.
*   **Instant Environment Refresh:** Upon installation or teardown, the script executes `taskkill /f /im explorer.exe` followed by a restart. This forces the Windows Shell to immediately flush its Icon Cache and recognize the new registry entries on the spot, bypassing the need for a system reboot.
*   **Absolute Cleanup:** The `uninstall.bat` strictly purges every registry key and shortcut path (Desktop & AppData Start Menu), leaving absolutely zero trace of the application on the host machine.

## Building from Source

TinyPad is built utilizing the Netwide Assembler (NASM) and GoLink. Ensure both are in your system's `PATH`.

```powershell
# 1. Assemble the raw x86 machine code
nasm.exe -f win32 TinyPad.asm -o TinyPad.obj

# 2. Link directly against core Windows DLLs (No CRT)
golink.exe /entry Start TinyPad.obj kernel32.dll user32.dll comdlg32.dll

Disclaimer
Because TinyPad is an ultra-minimalist, unsigned assembly executable that manipulates the registry, hyper-aggressive heuristic scanners (like Windows SmartScreen) may flag it. This is the expected behavior for pure, bare-metal machine code. Inspect the source and compile it yourself.
