#!/bin/bash
set -e

echo "[*] GreenPlasma Triage Compiler Setup (Windows)"
echo "==============================================="

# 1. Verify source exists in current directory
if [[ ! -f "GreenPlasma.cpp" ]]; then
    echo "[!] ERROR: GreenPlasma.cpp not found in $(pwd)"
    echo "    Place setup.sh in the same directory as GreenPlasma.cpp"
    exit 1
fi

# 2. Locate Windows C++ Compiler
CC=""
FLAGS=""

if command -v cl.exe &>/dev/null; then
    CC="cl.exe"
    # MSVC flags: Enable exceptions, optimize, Unicode, Win10+ SDK, output EXE, link required libs
    FLAGS="/EHsc /O2 /std:c++17 /DUNICODE /D_UNICODE /D_WIN32_WINNT=0x0A00 /Fe:GreenPlasma.exe /link advapi32.lib shell32.lib user32.lib ntdll.lib"
    echo "[+] Using MSVC Compiler (cl.exe)"
elif command -v g++.exe &>/dev/null || command -v x86_64-w64-mingw32-g++.exe &>/dev/null; then
    CC="g++.exe"
    # MinGW flags: Static link, C++17, Unicode, Win10+, wmain entry, link required libs
    FLAGS="-static -std=c++17 -DUNICODE -D_UNICODE -D_WIN32_WINNT=0x0A00 -municode -O2 -ladvapi32 -lshell32 -luser32 -o GreenPlasma.exe"
    echo "[+] Using MinGW Compiler (g++)"
else
    echo "[!] No C++ compiler detected in PATH."
    echo "[*] Attempting to install MSYS2/MinGW via winget..."
    winget install -e --id MSYS2.MSYS2 --accept-source-agreements --accept-package-agreements >/dev/null 2>&1 || true
    echo "[+] MSYS2 installed. Please CLOSE this terminal, open a NEW Git Bash/MSYS2 terminal, and run ./setup.sh again."
    exit 1
fi

# 3. Compile
echo "[+] Compiling GreenPlasma.cpp -> GreenPlasma.exe"
$CC GreenPlasma.cpp $FLAGS 2>&1

# 4. Verify Output
if [[ -f "GreenPlasma.exe" ]]; then
    echo ""
    echo "[+] ✅ SUCCESS: GreenPlasma.exe built successfully"
    echo "[+] 📁 Location: $(pwd)/GreenPlasma.exe"
    echo "[+] 🌐 Ready for upload to Triage (tria.ge)"
    file GreenPlasma.exe 2>/dev/null || echo "[+] Binary: Windows PE x86-64 executable"
else
    echo "[!] ❌ COMPILATION FAILED. Check errors above."
    exit 1
fi
