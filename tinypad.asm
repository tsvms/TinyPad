global Start

extern GetModuleHandleA, ExitProcess
extern RegisterClassExA, CreateWindowExA
extern GetMessageA, TranslateMessage, DispatchMessageA
extern DefWindowProcA, PostQuitMessage
extern GetClientRect, MoveWindow, SendMessageA, GetAsyncKeyState
extern GetSaveFileNameA, GetCommandLineA, lstrcpyA
extern CreateFileA, ReadFile, WriteFile, CloseHandle

section .bss
    hInstance resd 1
    hwndMain resd 1
    hwndEdit resd 1
    msg resb 28
    wc resb 48
    rect resb 16
    ofn resb 76
    szFile resb 260
    textBuffer resb 64000
    bytesRW resd 1
    hFile resd 1

section .text
    className db 'TinyPadClass', 0
    windowTitle db 'TinyPad', 0
    editClass db 'EDIT', 0
    filter db 'Text Files', 0, '*.txt', 0, 'All Files', 0, '*.*', 0, 0
    defExt db 'txt', 0

Start:
    push 0
    call GetModuleHandleA
    mov [hInstance], eax

    mov dword [wc], 48
    mov dword [wc+4], 3
    mov dword [wc+8], WindowProc
    mov dword [wc+12], 0
    mov dword [wc+16], 0
    mov eax, [hInstance]
    mov dword [wc+20], eax
    mov dword [wc+24], 0
    mov dword [wc+28], 0
    mov dword [wc+32], 5
    mov dword [wc+36], 0
    mov dword [wc+40], className
    mov dword [wc+44], 0

    push wc
    call RegisterClassExA

    push 0
    push dword [hInstance]
    push 0
    push 0
    push 480
    push 640
    push 0x80000000
    push 0x80000000
    push 0x10CF0000
    push windowTitle
    push className
    push 0
    call CreateWindowExA
    mov [hwndMain], eax

    mov dword [ofn], 76
    mov eax, [hwndMain]
    mov dword [ofn+4], eax
    mov dword [ofn+12], filter
    mov dword [ofn+28], szFile
    mov dword [ofn+32], 260
    mov dword [ofn+60], defExt
    mov dword [ofn+52], 0x00000002

    call GetCommandLineA
    mov esi, eax
    cmp byte [esi], '"'
    je .skip_quoted
.skip_unquoted:
    cmp byte [esi], ' '
    je .found_space
    cmp byte [esi], 0
    je msg_loop
    inc esi
    jmp .skip_unquoted
.skip_quoted:
    inc esi
    cmp byte [esi], '"'
    je .found_quote
    cmp byte [esi], 0
    je msg_loop
    jmp .skip_quoted
.found_quote:
    inc esi
.found_space:
    cmp byte [esi], ' '
    jne .check_arg
    inc esi
    jmp .found_space
.check_arg:
    cmp byte [esi], 0
    je msg_loop
    cmp byte [esi], '"'
    jne .do_copy
    inc esi
    mov edi, esi
.find_trailing:
    cmp byte [edi], '"'
    je .cut_quote
    cmp byte [edi], 0
    je .do_copy
    inc edi
    jmp .find_trailing
.cut_quote:
    mov byte [edi], 0

.do_copy:
    push esi
    push szFile
    call lstrcpyA

.open_file:
    push 0
    push 0x80
    push 3
    push 0
    push 0
    push 0x80000000
    push szFile
    call CreateFileA
    cmp eax, -1
    je msg_loop
    mov [hFile], eax

    push 0
    push bytesRW
    push 64000
    push textBuffer
    push dword [hFile]
    call ReadFile

    push dword [hFile]
    call CloseHandle

    push textBuffer
    push 0
    push 0x000C
    push dword [hwndEdit]
    call SendMessageA

msg_loop:
    push 0
    push 0
    push 0
    push msg
    call GetMessageA
    cmp eax, 0
    je end_app

    cmp dword [msg+4], 0x0100
    jne do_trans
    cmp dword [msg+8], 0x53
    jne do_trans
    
    push 0x11
    call GetAsyncKeyState
    test ax, 0x8000
    jz do_trans

    cmp byte [szFile], 0
    jne save_direct

    push ofn
    call GetSaveFileNameA
    test eax, eax
    jz do_trans

save_direct:
    push textBuffer
    push 64000
    push 0x000D
    push dword [hwndEdit]
    call SendMessageA
    mov ebx, eax

    push 0
    push 0x80
    push 2
    push 0
    push 0
    push 0x40000000
    push szFile
    call CreateFileA
    mov [hFile], eax
    cmp eax, -1
    je do_trans

    push 0
    push bytesRW
    push ebx
    push textBuffer
    push dword [hFile]
    call WriteFile

    push dword [hFile]
    call CloseHandle
    jmp msg_loop

do_trans:
    push msg
    call TranslateMessage
    push msg
    call DispatchMessageA
    jmp msg_loop

end_app:
    push 0
    call ExitProcess

WindowProc:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+12]
    cmp eax, 1
    je .wm_create
    cmp eax, 5
    je .wm_size
    cmp eax, 2
    je .wm_destroy
    
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call DefWindowProcA
    jmp .done

.wm_create:
    push 0
    push dword [hInstance]
    push 0
    push dword [ebp+8]
    push 0
    push 0
    push 0
    push 0
    push 0x50A01044
    push 0
    push editClass
    push 0
    call CreateWindowExA
    mov [hwndEdit], eax
    xor eax, eax
    jmp .done

.wm_size:
    push rect
    push dword [ebp+8]
    call GetClientRect

    push 1
    push dword [rect+12]
    push dword [rect+8]
    push 0
    push 0
    push dword [hwndEdit]
    call MoveWindow
    xor eax, eax
    jmp .done

.wm_destroy:
    push 0
    call PostQuitMessage
    xor eax, eax

.done:
    mov esp, ebp
    pop ebp
    ret 16