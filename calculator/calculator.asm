; build with follow commands:
;d:/masm32/bin/ml /c /Cp /coff calculator.asm
;d:/masm32/bin/Link /subsystem:windows calculator.obj
;

.386
.model flat, stdcall
option casemap:none

; include prototype function and library
include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\user32.inc
include D:\masm32\include\gdi32.inc
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\gdi32.lib

; initialized data
.data
    AppName db 'Calculator', 0
    ClassName db 'BasicWinClass', 0
    ButtonClassName db 'Button', 0
    BoxClassName db 'Edit', 0
    Error_Message db 'Are you dump???', 0

    ButtonName0 db '0', 0
    ButtonName1 db '1', 0
    ButtonName2 db '2', 0
    ButtonName3 db '3', 0
    ButtonName4 db '4', 0
    ButtonName5 db '5', 0
    ButtonName6 db '6', 0
    ButtonName7 db '7', 0
    ButtonName8 db '8', 0
    ButtonName9 db '9', 0
    ButtonName_plus db '+', 0
    ButtonName_minus db '-', 0
    ButtonName_mul db '*', 0
    ButtonName_div db '/', 0
    ButtonName_equ db '=', 0
    ButtonName_c db 'C', 0
    ButtonName_ce db 'CE', 0
    ButtonName_back db '<=', 0
    ButtonName_neg db '-/+', 0

    value_0 db '0'
    value_9 db '9'
    value_minus db '-'
    value_plus db '+'
    value_mul db '*'
    value_div db '/'

; uninitialized data
.data?
    hInstance HINSTANCE ?
    wc WNDCLASSEX <?>
    msg MSG <?>
    hWnd HWND ?
    hWndButton1 HWND ?
    hWndButton2 HWND ?
    hWndButton3 HWND ?
    hWndButton4 HWND ?
    hWndButton5 HWND ?
    hWndButton6 HWND ?
    hWndButton7 HWND ?
    hWndButton8 HWND ?
    hWndButton9 HWND ?
    hWndButton0 HWND ?
    hWndButton_plus HWND ?
    hWndButton_minus HWND ?
    hWndButton_mul HWND ?
    hWndButton_div HWND ?
    hWndButton_equ HWND ?
    hWndButton_c HWND ?
    hWndButton_ce HWND ?
    hWndButton_back HWND ?
    hWndButton_neg HWND ?
    hWndEdit HWND ?
    hWndEdit2 HWND ?
    hFontEdit HFONT ?
    hFontButton HFONT ?
    hWndBuffer HWND ?
    expression db 1000 dup(?)
    temp db 1000 dup(?)
    buffer db 1000 dup(?)
    curr_operator db 3 dup (?)
    curr_number_text db 100 dup(?)
    curr_number_value dword ?
    not_just_finish dword ?
    curr_result dword ?
    curr_result_text db 100 dup(?)
    first_number dword ?
    enter_number dword ?

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
    push 500
    push 334
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
    cmp dword ptr[ebp+12], WM_CREATE
    jz WMCREATE
    cmp dword ptr[ebp+12], WM_COMMAND
    jz WMCOMMAND
    cmp dword ptr[ebp+12], WM_KEYDOWN
    jz WMKEYDOWN

    push dword ptr[ebp+20]
    push dword ptr[ebp+16]
    push dword ptr[ebp+12]
    push dword ptr[ebp+8]
    call DefWindowProc
    jmp EXIT_PROC

FINISH:
    push hWnd
    call SetFocus
    push dword ptr[ebp+20]
    push dword ptr[ebp+16]
    push dword ptr[ebp+12]
    push dword ptr[ebp+8]
    call DefWindowProc
    jmp EXIT_PROC

WMCREATE:
    ; create button window
    push 0
    push hInstance
    push 1
    push dword ptr[ebp+8]
    push 50
    push 80
    push 350
    push 0
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName1
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton1, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 350
    push 80
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName2
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton2, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 350
    push 160
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName3
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton3, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 300
    push 0
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName4
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton4, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 300
    push 80
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName5
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton5, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 300
    push 160
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName6
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton6, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 250
    push 0
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName7
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton7, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 250
    push 80
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName8
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton8, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 250
    push 160
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName9
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton9, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 350
    push 240
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName_plus
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton_plus, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 300
    push 240
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName_minus
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton_minus, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 250
    push 240
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName_mul
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton_mul, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 200
    push 240
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName_div
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton_div, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 400
    push 240
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName_equ
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton_equ, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 400
    push 0
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName_neg
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton_neg, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 400
    push 80
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName0
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton0, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 200
    push 0
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName_ce
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton_ce, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 200
    push 80
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName_c
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton_c, eax

    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 80
    push 200
    push 160
    push WS_CHILD or BS_DEFPUSHBUTTON or WS_VISIBLE or WS_TABSTOP
    push offset ButtonName_back
    push offset ButtonClassName
    push 0
    call CreateWindowExA
    mov hWndButton_back, eax
    
    ; create first edit window
    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 30
    push 320
    push 60
    push 0
    push WS_CHILD or WS_VISIBLE or WS_BORDER or WS_TABSTOP or ES_READONLY or ES_RIGHT
    push NULL
    push offset BoxClassName
    push 0
    call CreateWindowExA
    mov hWndEdit, eax

    ; create second edit window
    push 0
    push hInstance
    push 0
    push dword ptr[ebp+8]
    push 50
    push 320
    push 90
    push 0
    push WS_CHILD or WS_VISIBLE or WS_BORDER or WS_TABSTOP or ES_READONLY or ES_RIGHT
    push NULL
    push offset BoxClassName
    push 0
    call CreateWindowExA
    mov hWndEdit2, eax

    push NULL
    push FF_DONTCARE
    push DEFAULT_QUALITY
    push CLIP_DEFAULT_PRECIS
    push OUT_DEFAULT_PRECIS
    push DEFAULT_CHARSET
    push FALSE
    push FALSE
    push FALSE
    push 0
    push 0
    push 0
    push 17
    push 40
    call CreateFontA
    mov hFontEdit, eax

    push TRUE
    push hFontEdit
    push WM_SETFONT
    push hWndEdit2
    call SendMessage

    call init

    jmp FINISH

WMCOMMAND:
    mov eax, hWndButton0
    cmp dword ptr [ebp+20], eax
    je Button0

    mov eax, hWndButton1
    cmp dword ptr [ebp+20], eax
    je Button1

    mov eax, hWndButton2
    cmp dword ptr [ebp+20], eax
    je Button2

    mov eax, hWndButton3
    cmp dword ptr [ebp+20], eax
    je Button3

    mov eax, hWndButton4
    cmp dword ptr [ebp+20], eax
    je Button4

    mov eax, hWndButton5
    cmp dword ptr [ebp+20], eax
    je Button5

    mov eax, hWndButton6
    cmp dword ptr [ebp+20], eax
    je Button6

    mov eax, hWndButton7
    cmp dword ptr [ebp+20], eax
    je Button7

    mov eax, hWndButton8
    cmp dword ptr [ebp+20], eax
    je Button8

    mov eax, hWndButton9
    cmp dword ptr [ebp+20], eax
    je Button9

    mov eax, hWndButton_plus
    cmp dword ptr [ebp+20], eax
    je Button_plus

    mov eax, hWndButton_minus
    cmp dword ptr [ebp+20], eax
    je Button_minus

    mov eax, hWndButton_mul
    cmp dword ptr [ebp+20], eax
    je Button_mul

    mov eax, hWndButton_div
    cmp dword ptr [ebp+20], eax
    je Button_div

    mov eax, hWndButton_equ
    cmp dword ptr [ebp+20], eax
    je Button_equ

    mov eax, hWndButton_c
    cmp dword ptr [ebp+20], eax
    je Button_c
    
    mov eax, hWndButton_ce
    cmp dword ptr [ebp+20], eax
    je Button_ce

    mov eax, hWndButton_neg
    cmp dword ptr [ebp+20], eax
    je Button_neg

    mov eax, hWndButton_back
    cmp dword ptr [ebp+20], eax
    je Button_back

    jmp FINISH

Button0:
    cmp not_just_finish, 0
    jne not_reset_operator0
    mov [curr_operator], 0
not_reset_operator0:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new0
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new0:
    mov eax, curr_number_value
    cmp eax, 0
    jge positive0
    neg eax
    imul eax, 10
    jo FINISH
    neg eax
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive0:
    imul eax, 10
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button1:
    cmp not_just_finish, 0
    jne not_reset_operator1
    mov [curr_operator], 0
not_reset_operator1:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new1
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new1:
    mov eax, curr_number_value
    cmp eax,0
    jge positive1
    neg eax
    imul eax, 10
    jo FINISH
    add eax, 1
    jo FINISH
    neg eax
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive1:
    imul eax, 10
    jo FINISH
    add eax, 1
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button2:
    cmp not_just_finish, 0
    jne not_reset_operator2
    mov [curr_operator], 0
not_reset_operator2:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new2
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new2:
    mov eax, curr_number_value
    cmp eax,0
    jge positive2
    neg eax
    imul eax, 10
    jo FINISH
    add eax, 2
    jo FINISH
    neg eax
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive2:
    imul eax, 10
    jo FINISH
    add eax, 2
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button3:
    cmp not_just_finish, 0
    jne not_reset_operator3
    mov [curr_operator], 0
not_reset_operator3:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new3
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new3:
    mov eax, curr_number_value
    cmp eax,0
    jge positive3
    neg eax
    imul eax, 10
    jo FINISH
    add eax, 3
    jo FINISH
    neg eax
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive3:
    imul eax, 10
    jo FINISH
    add eax, 3
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button4:
    cmp not_just_finish, 0
    jne not_reset_operator4
    mov [curr_operator], 0
not_reset_operator4:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new4
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new4:
    mov eax, curr_number_value
    cmp eax,0
    jge positive4
    neg eax
    imul eax, 10
    jo FINISH
    add eax, 4
    jo FINISH
    neg eax
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive4:
    imul eax, 10
    jo FINISH
    add eax, 4
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button5:
    cmp not_just_finish, 0
    jne not_reset_operator5
    mov [curr_operator], 0
not_reset_operator5:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new5
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new5:
    mov eax, curr_number_value
    cmp eax,0
    jge positive5
    neg eax
    imul eax, 10
    jo FINISH
    add eax, 5
    jo FINISH
    neg eax
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive5:
    imul eax, 10
    jo FINISH
    add eax, 5
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button6:
    cmp not_just_finish, 0
    jne not_reset_operator6
    mov [curr_operator], 0
not_reset_operator6:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new6
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new6:
    mov eax, curr_number_value
    cmp eax,0
    jge positive6
    neg eax
    imul eax, 10
    jo FINISH
    add eax, 6
    jo FINISH
    neg eax
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive6:
    imul eax, 10
    jo FINISH
    add eax, 6
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button7:
    cmp not_just_finish, 0
    jne not_reset_operator7
    mov [curr_operator], 0
not_reset_operator7:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new7
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new7:
    mov eax, curr_number_value
    cmp eax,0
    jge positive7
    neg eax
    imul eax, 10
    jo FINISH
    add eax, 7
    jo FINISH
    neg eax
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive7:
    imul eax, 10
    jo FINISH
    add eax, 7
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button8:
    cmp not_just_finish, 0
    jne not_reset_operator8
    mov [curr_operator], 0
not_reset_operator8:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new8
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new8:
    mov eax, curr_number_value
    cmp eax,0
    jge positive8
    neg eax
    imul eax, 10
    jo FINISH
    add eax, 8
    jo FINISH
    neg eax
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive8:
    cmp not_just_finish, 0
    jne not_reset_operator9
    mov [curr_operator], 0
not_reset_operator9:
    imul eax, 10
    jo FINISH
    add eax, 8
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button9:
    mov eax, enter_number
    add eax, not_just_finish
    cmp eax, 2
    je not_new9
    mov enter_number, 1
    push offset temp
    push offset expression
    call lstrcpyA
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    mov curr_number_value, 0
    mov not_just_finish, 1
not_new9:
    mov eax, curr_number_value
    cmp eax,0
    jge positive9
    neg eax
    imul eax, 10
    jo FINISH
    add eax, 9
    jo FINISH
    neg eax
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

positive9:
    imul eax, 10
    jo FINISH
    add eax, 9
    jo FINISH
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button_plus:
    mov not_just_finish, 1
    mov eax, first_number
    cmp eax, 1
    jne not_first_number_plus
    mov eax, curr_number_value
    mov curr_result, eax
    mov first_number, 0 
    push offset curr_result_text
    push offset curr_result
    call convert_number
    mov eax, enter_number
    cmp eax, 1
    jne save_temp_plus
    push offset curr_number_text
    push offset expression
    call lstrcatA
    mov enter_number, 0
    jmp save_temp_plus
    
not_first_number_plus:
    mov eax, enter_number
    cmp eax, 1
    jne save_temp_plus
    push offset curr_number_text
    push offset expression
    call lstrcatA
    mov enter_number, 0
    mov al, byte ptr[curr_operator]
    cmp al, '+'
    je plus_plus
    cmp al, '-'
    je minus_plus
    cmp al, '*'
    je mul_plus
    cmp al, '/'
    je div_plus
    jmp save_temp_plus

plus_plus:
    mov eax, curr_result
    add eax, curr_number_value
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_plus

minus_plus:
    mov eax, curr_result
    sub eax, curr_number_value
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_plus

mul_plus:
    mov eax, curr_result
    mov edx, curr_number_value
    imul eax, edx
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_plus

div_plus:
    mov ebx, curr_number_value
    cmp ebx, 0
    je error_alert
    xor edx, edx
    mov eax, curr_result
    cdq
    idiv ebx
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_plus
save_temp_plus:
    mov [curr_operator], '+'
    push offset expression
    push offset temp
    call lstrcpyA
    push offset curr_operator
    push offset temp
    call lstrcatA
    push offset temp
    push hWndEdit
    call SetWindowText
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button_div:
    mov not_just_finish, 1
    mov eax, first_number
    cmp eax, 1
    jne not_first_number_div
    mov eax, curr_number_value
    mov curr_result, eax
    mov first_number, 0 
    push offset curr_result_text
    push offset curr_result
    call convert_number
    mov eax, enter_number
    cmp eax, 1
    jne save_temp_div
    push offset curr_number_text
    push offset expression
    call lstrcatA
    mov enter_number, 0
    jmp save_temp_div
    
not_first_number_div:
    mov eax, enter_number
    cmp eax, 1
    jne save_temp_div
    push offset curr_number_text
    push offset expression
    call lstrcatA
    mov enter_number, 0
    mov al, byte ptr[curr_operator]
    cmp al, '+'
    je plus_div
    cmp al, '-'
    je minus_div
    cmp al, '*'
    je mul_div
    cmp al, '/'
    je div_div
    jmp save_temp_div

plus_div:
    mov eax, curr_result
    add eax, curr_number_value
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_div

minus_div:
    mov eax, curr_result
    sub eax, curr_number_value
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_div

mul_div:
    mov eax, curr_result
    mov edx, curr_number_value
    imul eax, edx
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_div

div_div:
    mov ebx, curr_number_value
    cmp ebx, 0
    je error_alert
    xor edx, edx
    mov eax, curr_result
    cdq
    idiv ebx
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_div
save_temp_div:
    mov [curr_operator], '/'
    push offset expression
    push offset temp
    call lstrcpyA
    push offset curr_operator
    push offset temp
    call lstrcatA
    push offset temp
    push hWndEdit
    call SetWindowText
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button_minus:
    mov not_just_finish, 1
    mov eax, first_number
    cmp eax, 1
    jne not_first_number_minus
    mov eax, curr_number_value
    mov curr_result, eax
    mov first_number, 0 
    push offset curr_result_text
    push offset curr_result
    call convert_number
    mov eax, enter_number
    cmp eax, 1
    jne save_temp_minus
    push offset curr_number_text
    push offset expression
    call lstrcatA
    mov enter_number, 0
    jmp save_temp_minus
    
not_first_number_minus:
    mov eax, enter_number
    cmp eax, 1
    jne save_temp_minus
    push offset curr_number_text
    push offset expression
    call lstrcatA
    mov enter_number, 0
    mov al, byte ptr[curr_operator]
    cmp al, '+'
    je plus_minus
    cmp al, '-'
    je minus_minus
    cmp al, '*'
    je mul_minus
    cmp al, '/'
    je div_minus
    jmp save_temp_minus

plus_minus:
    mov eax, curr_result
    add eax, curr_number_value
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_minus

minus_minus:
    mov eax, curr_result
    sub eax, curr_number_value
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_minus

mul_minus:
    mov eax, curr_result
    mov edx, curr_number_value
    imul eax, edx
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_minus

div_minus:
    mov ebx, curr_number_value
    cmp ebx, 0
    je error_alert
    xor edx, edx
    mov eax, curr_result
    cdq
    idiv ebx
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_minus
save_temp_minus:
    mov [curr_operator], '-'
    push offset expression
    push offset temp
    call lstrcpyA
    push offset curr_operator
    push offset temp
    call lstrcatA
    push offset temp
    push hWndEdit
    call SetWindowText
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button_mul:
    mov not_just_finish, 1
    mov eax, first_number
    cmp eax, 1
    jne not_first_number_mul
    mov eax, curr_number_value
    mov curr_result, eax
    mov first_number, 0 
    push offset curr_result_text
    push offset curr_result
    call convert_number
    mov eax, enter_number
    cmp eax, 1
    jne save_temp_mul
    push offset curr_number_text
    push offset expression
    call lstrcatA
    mov enter_number, 0
    jmp save_temp_mul
    
not_first_number_mul:
    mov eax, enter_number
    cmp eax, 1
    jne save_temp_mul
    push offset curr_number_text
    push offset expression
    call lstrcatA
    mov enter_number, 0
    mov al, byte ptr[curr_operator]
    cmp al, '+'
    je plus_mul
    cmp al, '-'
    je minus_mul
    cmp al, '*'
    je mul_mul
    cmp al, '/'
    je div_mul
    jmp save_temp_mul

plus_mul:
    mov eax, curr_result
    add eax, curr_number_value
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_mul

minus_mul:
    mov eax, curr_result
    sub eax, curr_number_value
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_mul

mul_mul:
    mov eax, curr_result
    mov edx, curr_number_value
    imul eax, edx
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_mul

div_mul:
    mov ebx, curr_number_value
    cmp ebx, 0
    je error_alert
    xor edx, edx
    mov eax, curr_result
    cdq
    idiv ebx
    mov curr_result, eax
    push offset curr_result_text
    push offset curr_result
    call convert_number
    jmp save_temp_mul
save_temp_mul:
    mov [curr_operator], '*'
    push offset expression
    push offset temp
    call lstrcpyA
    push offset curr_operator
    push offset temp
    call lstrcatA
    push offset temp
    push hWndEdit
    call SetWindowText
    push offset curr_result_text
    push hWndEdit2
    call SetWindowText
    jmp FINISH

Button_equ:
    mov eax, first_number
    cmp eax, 1
    jne not_first_number_equ
    mov edx, curr_number_value
    mov curr_result, edx
    mov first_number, 0
not_first_number_equ:
    mov al, byte ptr[curr_operator]
    cmp al, '+'
    je plus_equ
    cmp al, '-'
    je minus_equ
    cmp al, '*'
    je mul_equ
    cmp al, '/'
    je div_equ
    jmp save_temp_equ

plus_equ:
    mov eax, curr_result
    add eax, curr_number_value
    mov curr_result, eax
    jmp save_temp_equ

minus_equ:
    mov eax, curr_result
    sub eax, curr_number_value
    mov curr_result, eax
    jmp save_temp_equ

mul_equ:
    mov eax, curr_result
    mov edx, curr_number_value
    imul eax, edx
    mov curr_result, eax
    jmp save_temp_equ

div_equ:
    mov ebx, curr_number_value
    cmp ebx, 0
    je error_alert
    xor edx, edx
    mov eax, curr_result
    cdq
    idiv ebx
    mov curr_result, eax
    jmp save_temp_equ

save_temp_equ:

    mov edx, curr_result
    mov curr_number_value, edx
    mov [expression], 0
    mov [temp], 0
    mov first_number, 1
    mov enter_number, 1
    ;mov [curr_operator], 0
    push offset curr_number_text
    push offset curr_result
    call convert_number
    push offset expression
    push hWndEdit
    call SetWindowText
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
    mov not_just_finish, 0
    jmp FINISH

Button_c:
    call init
    jmp FINISH

Button_back:
    mov eax, enter_number
    cmp eax, 1
    jne done_back
    xor edx, edx
    mov ebx, 10
    mov eax, curr_number_value
    cdq
    idiv ebx
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
done_back:
    jmp FINISH

Button_neg:
    mov eax, enter_number
    cmp eax, 1
    jne done_neg
    mov eax, curr_number_value
    neg eax
    mov curr_number_value, eax
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
done_neg:
    jmp FINISH

Button_ce:
    mov eax, enter_number
    cmp eax, 1
    jne done_ce
    mov curr_number_value, 0
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText
done_ce:
    jmp FINISH

error_alert:
    call init
    push offset Error_Message
    push hWndEdit2
    call SetWindowText
    jmp FINISH

WMKEYDOWN:
    cmp dword ptr [ebp+16], 48
    jz KEYDOWN0
    cmp dword ptr [ebp+16], 49
    jz KEYDOWN1
    cmp dword ptr [ebp+16], 50
    jz KEYDOWN2
    cmp dword ptr [ebp+16], 51
    jz KEYDOWN3
    cmp dword ptr [ebp+16], 52
    jz KEYDOWN4
    cmp dword ptr [ebp+16], 53
    jz KEYDOWN5
    cmp dword ptr [ebp+16], 54
    jz KEYDOWN6
    cmp dword ptr [ebp+16], 55
    jz KEYDOWN7
    cmp dword ptr [ebp+16], 56
    jz KEYDOWN8
    cmp dword ptr [ebp+16], 57
    jz KEYDOWN9
    cmp dword ptr [ebp+16], VK_ADD
    jz KEYDOWN_PLUS
    cmp dword ptr [ebp+16], VK_OEM_PLUS
    jz KEYDOWN_PLUS
    cmp dword ptr [ebp+16], VK_SUBTRACT
    jz KEYDOWN_MINUS
    cmp dword ptr [ebp+16], VK_OEM_MINUS
    jz KEYDOWN_MINUS
    cmp dword ptr [ebp+16], VK_MULTIPLY
    jz KEYDOWN_MUL
    cmp dword ptr [ebp+16], VK_DIVIDE
    jz KEYDOWN_DIV
    cmp dword ptr [ebp+16], VK_OEM_2
    jz KEYDOWN_DIV
    cmp dword ptr [ebp+16], VK_ESCAPE
    jz KEYDOWN_C
    cmp dword ptr [ebp+16], VK_RETURN
    jz KEYDOWN_EQU
    cmp dword ptr [ebp+16], VK_BACK
    jz KEYDOWN_CE
    cmp dword ptr [ebp+16], 86
    jz KEYDOWN_PASTE
    jmp FINISH

KEYDOWN0:
    push hWndButton0
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH

KEYDOWN1:
    push hWndButton1
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH

KEYDOWN2:
    push hWndButton2
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN3:
    push hWndButton3
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN4:
    push hWndButton4
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN5:
    push hWndButton5
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN6:
    push hWndButton6
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN7:
    push hWndButton7
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN8:
    push VK_LSHIFT
    call GetKeyState
    cmp ax, 0
    jl KEYDOWN_MUL
    push VK_RSHIFT
    call GetKeyState
    cmp ax, 0
    jl KEYDOWN_MUL
    push hWndButton8
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN9:
    push hWndButton9
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN_PLUS:
    push hWndButton_plus
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN_MINUS:
    push hWndButton_minus
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN_MUL:
    push hWndButton_mul
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN_DIV:
    push hWndButton_div
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN_EQU:
    push hWndButton_equ
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN_C:
    push hWndButton_c
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN_CE:
    push hWndButton_back
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    jmp FINISH
KEYDOWN_PASTE:
    push VK_LCONTROL
    call GetKeyState
    cmp ax, 0
    jge FINISH
    push hWndButton_ce
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    push hWnd
    call OpenClipboard
    cmp eax, 0
    je error_alert
    push CF_TEXT
    call GetClipboardData
    mov hWndBuffer, eax
    mov esi, hWndBuffer
paste_loop:
    mov cl, [esi]
    cmp cl, '0'
    jz PASTE0
    cmp cl, '1'
    jz PASTE1
    cmp cl, '2'
    jz PASTE2
    cmp cl, '3'
    jz PASTE3
    cmp cl, '4'
    jz PASTE4
    cmp cl, '5'
    jz PASTE5
    cmp cl, '6'
    jz PASTE6
    cmp cl, '7'
    jz PASTE7
    cmp cl, '8'
    jz PASTE8
    cmp cl, '9'
    jz PASTE9
    cmp cl, '+'
    jz PASTE_PLUS
    cmp cl, '-'
    jz PASTE_MINUS
    cmp cl, '*'
    jz PASTE_MUL
    cmp cl, '/'
    jz PASTE_DIV
    cmp cl, '='
    jz PASTE_EQU
    cmp cl, 0
    jz PASTE_FINISH
    jmp PASTE_ERROR
    ;push hWndBuffer
    ;push hWndEdit2
    ;call SetWindowText
    ;call CloseClipboard
    ;jmp FINISH

PASTE0:
    push hWndButton0
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop

PASTE1:
    push hWndButton1
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop

PASTE2:
    push hWndButton2
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE3:
    push hWndButton3
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE4:
    push hWndButton4
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE5:
    push hWndButton5
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE6:
    push hWndButton6
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE7:
    push hWndButton7
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE8:
    push hWndButton8
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE9:
    push hWndButton9
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE_PLUS:
    push hWndButton_plus
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE_MINUS:
    push hWndButton_minus
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE_MUL:
    push hWndButton_mul
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE_DIV:
    push hWndButton_div
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE_EQU:
    push hWndButton_equ
    push NULL
    push WM_COMMAND
    push hWnd
    call SendMessage
    inc esi
    jmp paste_loop
PASTE_FINISH:
    call CloseClipboard
    jmp FINISH
PASTE_ERROR:
    call CloseClipboard
    jmp error_alert

WMDESTROY:
    push 0
    call PostQuitMessage
    xor eax, eax

EXIT_PROC:
    pop ebp
    ret 4*4
WndProc endp

init proc
    push ebp
    mov ebp, esp
    mov curr_number_value, 0
    mov [expression], 0
    mov [temp], 0
    mov [curr_operator], 0
    mov [curr_operator]+1, 0
    mov [curr_number_text], 0
    mov [curr_result_text], 0
    mov curr_result, 0
    mov first_number, 1
    mov enter_number, 1
    mov not_just_finish, 0
    
    push offset curr_number_text
    push offset curr_number_value
    call convert_number
    push offset expression
    push hWndEdit
    call SetWindowText
    push offset curr_number_text
    push hWndEdit2
    call SetWindowText

    pop ebp
    ret
init endp

convert_number proc
    push ebp
    mov ebp, esp
    xor ecx, ecx
    xor esi, esi
    mov ecx, dword ptr[ebp+8]
    mov ecx, [ecx]
    cmp ecx, 0
    jl negative_case
    jmp convert_loop
negative_case:
    neg ecx
    mov dh, '-'
    mov eax, dword ptr[ebp+12]
    mov [eax], dh
    inc eax
    mov dword ptr[ebp+12], eax
convert_loop:
    xor edi, edi
    xor edx, edx
	xor eax, eax
	mov ebx, 10
	mov eax, ecx
	div ebx
    mov ecx, eax
    add dl, '0'
    mov edi, dword ptr[ebp+12]
    mov [edi+esi], dl
    inc esi
    cmp ecx, 0
    je reverse_string
    jmp convert_loop
    
reverse_string:
    mov dl, 0
    mov [edi+esi], dl
    xor edi, edi
    xor esi, esi
    mov esi, [ebp+12]
    mov edi, [ebp+12]
    dec edi
findLastString:
    inc edi
    mov al, [edi]
    cmp al, 0
    jnz findLastString
    dec edi

reverseLoop:
    cmp esi, edi
    jge reverse_done

    mov bl, [esi]
    mov al, [edi]
    mov [esi], al
    mov [edi], bl

    inc esi
    dec edi
    jmp reverseLoop

    ; show string reversed to second edit window
reverse_done:
    pop ebp
    ret 2*4

convert_number endp   
end start