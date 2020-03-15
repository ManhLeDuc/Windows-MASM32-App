


.386
.model flat,stdcall
option casemap:none
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib

; initialized data
.data
    AppName db 'Boucing Ball', 0
    ClassName db 'BasicWinClass', 0

; uninitialized data
.data?
    hInstance HINSTANCE ?
    wc WNDCLASSEX <?>
    msg MSG <?>
    hWnd HWND ?
    hBitmap HWND ?
		hdc HWND ?
		hdcMem HWND ?
		cxClient dword ?						; Width of window
		cyClient dword ?						; Height of window
		xCenter dword ?						; x of the ball
		yCenter dword ?						; y of the ball
		cxTotal dword ?						; x radius + x move
		cyTotal dword ?						; y radius + y move
		cxRadius dword ?
		cyRadius dword ?
		cxMove dword ?
		cyMove dword ?

		
.code
start:
    push NULL
    call GetModuleHandle    ; get instance handle of program
    mov hInstance, eax

    mov wc.cbSize, sizeof WNDCLASSEX        
    mov wc.style, CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc, offset WndProc
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, NULL
    push hInstance
    pop wc.hInstance
    mov wc.hbrBackground, COLOR_WINDOW+1
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset ClassName
    push IDI_APPLICATION
    push NULL
    call LoadIconA
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    push IDC_ARROW
    push NULL
    call LoadCursorA
    mov wc.hCursor, eax     ; fill window class structure
    push offset wc
    call RegisterClassExA   ; register window class

    push NULL
    push hInstance
    push NULL
    push NULL
    push 400
    push 600
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push WS_OVERLAPPEDWINDOW
    push offset AppName
    push offset ClassName
    push NULL
    call CreateWindowExA    ; create window

    mov hWnd, eax           ; new window handle

	
    push SW_NORMAL
    push hWnd
    call ShowWindow         ; set window to normal, so it is visible
    
    push hWnd
    call UpdateWindow       ; display window

		push NULL
		push 50
		push 1
		push hWnd
		call SetTimer						; Set redraw frequency
messageLoop:
    push 0
    push 0
    push NULL
    push offset msg
    call GetMessageA        ; get message from message loop
    or eax, eax
    jle endLoop
    push offset msg
    call TranslateMessage   ; translate virtual-key messages into character messages
    push offset msg
    call DispatchMessageA
    jmp messageLoop
endLoop:
    mov eax, msg.wParam
    push eax
    call ExitProcess

WndProc proc
    push ebp
    mov ebp, esp
    cmp dword ptr[ebp+12], WM_DESTROY
    jz WMDESTROY
    cmp dword ptr[ebp+12], WM_SIZE
    jz WMSIZE
    cmp dword ptr[ebp+12], WM_TIMER
    jz WMTIMER

FINISH:
    push dword ptr[ebp+20]
    push dword ptr[ebp+16]
    push dword ptr[ebp+12]
    push dword ptr[ebp+8]
    call DefWindowProc
    jmp EXIT_PROC

WMSIZE:
    xor edx, edx
		xor ecx, ecx
		mov ebx, 2
		mov cx, word ptr[ebp+20]
		mov eax, ecx
		mov cxClient, eax
		div ebx
		mov xCenter, eax
		mov cx, word ptr[ebp+20]+2
		mov eax, ecx
		mov cyClient, eax
		div ebx
		mov yCenter, eax
		
		mov cxRadius, 20
		mov cyRadius, 20
		mov cxMove, 4
		mov cyMove, 4
		mov eax, cxMove
		add eax, cxRadius
		imul eax, 2
		mov cxTotal, eax
		mov eax, cyMove
		add eax, cyRadius
		imul eax, 2
		mov cyTotal, eax
		
		push hBitmap
		call DeleteObject
	
		push dword ptr[ebp+8]
		call GetDC
		mov hdc, eax
		push hdc
		call CreateCompatibleDC
		mov hdcMem, eax
		push cyTotal
		push cxTotal
		push hdc
		call CreateCompatibleBitmap
		mov hBitmap, eax
		push hdc
		push dword ptr[ebp+8]
		call ReleaseDC
		push hBitmap
		push hdcMem
		call SelectObject
		mov ecx, cyTotal
		inc ecx
		push ecx
		mov ecx, cxTotal
		inc ecx
		push ecx
		push -1
		push -1
		push hdcMem
		call Rectangle
		mov ecx, cyTotal
		sub ecx, cyMove
		push ecx
		mov ecx, cxTotal
		sub ecx, cxMove
		push ecx
		push cyMove
		push cxMove
		push hdcMem
		call Ellipse
		push hdcMem
		call DeleteDC
		
WMTIMER:
    push dword ptr[ebp+8]
		call GetDC
		mov hdc, eax
		push hdc
		call CreateCompatibleDC
		mov hdcMem, eax
		push hBitmap
		push hdcMem
		call SelectObject
		push SRCCOPY
		push 0
		push 0
		push hdcMem
		push cyTotal
		push cxTotal
		mov eax, cyTotal
		xor edx, edx
		mov ebx, 2
		div ebx
		mov ecx, yCenter
		sub ecx, eax
		push ecx
		mov eax, cxTotal
		xor edx, edx
		mov ebx, 2
		div ebx
		mov ecx, xCenter
		sub ecx, eax
		push ecx
		push hdc
		call BitBlt
		push hdc
		push dword ptr[ebp+8]
		call ReleaseDC
		push hdcMem
		call DeleteDC

		mov eax, xCenter
		add eax, cxMove
		mov xCenter, eax
		mov eax, yCenter
		add eax, cyMove
		mov yCenter, eax

		mov eax, xCenter
		add eax, cxRadius
		cmp eax, cxClient
		jge changex
		mov eax, xCenter
		sub eax, cxRadius
		cmp eax, 0
		jle changex
		mov eax, yCenter
		add eax, cyRadius
		cmp eax, cyClient
		jge changey
		mov eax, yCenter
		sub eax, cyRadius
		cmp eax, 0
		jle changey
		jmp FINISH
		changex:
		mov eax, cxMove
		imul eax, -1
		mov cxMove, eax
		mov eax, yCenter
		add eax, cyRadius
		cmp eax, cyClient
		jge changey
		mov eax, yCenter
		sub eax, cyRadius
		cmp eax, 0
		jle changey
		jmp FINISH
		changey:
		mov eax, cyMove
		imul eax, -1
		mov cyMove, eax
		jmp FINISH
WMDESTROY:
    push 0
    call PostQuitMessage
    xor eax, eax

EXIT_PROC:
    pop ebp
    ret 4*4
WndProc endp

end start