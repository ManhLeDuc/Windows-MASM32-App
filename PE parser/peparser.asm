; build with follow commands:
;d:/masm32/bin/ml /c /Cp /coff peparser.asm
;d:/masm32/bin/rc peparser.rc
;d:/masm32/bin/Link /subsystem:windows peparser.obj peparser.RES

.386
.model flat,stdcall
option casemap:none

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comdlg32.inc
include \masm32\include\comctl32.inc
include \masm32\include\shlwapi.inc
include \masm32\include\shell32.inc
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\shlwapi.lib
includelib \masm32\lib\comctl32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comdlg32.lib

.const
IDM_TEST equ 1                   ; Menu IDs
IDM_OPEN equ 2
IDM_EXIT equ 3
EditID equ 4
MAXSIZE equ 260
OUTPUTSIZE equ 512
IDB_TREE equ 4006
MEMSIZE equ 65535
RGB macro red,green,blue
        xor eax,eax
        mov ah,blue
        shl eax,8
        mov ah,green
        mov al,red
endm

DODIV MACRO
    cmp ebx, 16
    jne @F
    mov edx, eax
    and edx, 01111b
    shr eax, 4
    jmp LL
  @@:
    cmp ebx, 2
    jne @F
    mov edx, eax
    and edx, 01b
    shr eax, 1
    jmp LL
  @@:
    idiv ebx
  LL:
ENDM

.data
ClassName db "SimpleWinClass",0
AppName db "PE-Parser",0
MenuName db "FirstMenu",0               ; The name of our menu in the resource file.
EditClass db "edit",0
Test_string db "You selected Test menu item",0
Hello_string db "Hello, my friend",0
Goodbye_string db "See you again, bye",0
ofn   OPENFILENAME <>
FilterString db "EXE Files",0,"*.exe",0,0
TreeViewClass  db "SysTreeView32",0
ListViewClassName db "SysListView32",0
OurTitle db "-=Our First Open File Dialog Box=-: Choose the file to open",0
FullPathName db "The Full Filename with Path is: ",0
FullName  db "The Filename is: ",0
ExtensionName db "The Extension is: ",0
header db "Header",0
dosheader db "Dos Header",0
ntheader db "NT Header",0
fileheader db "File Header",0
optionalheader db "Optional Header",0
datadir db "Data Directories",0
datadirexport db "Export Directory",0
datadirimport db "Import Directory",0
sectionheader db "Section Header",0
import db "Imports",0
Heading1 db "Value",0
Heading2 db "Meaning",0
Heading3 db "Funtion",0
CrLf db 0Dh,0Ah,0
e_magic db "Magic number",0
e_cblp db "Bytes on last page of file",0
e_cp db "Pages in file",0
e_crlc db "Relocations",0
e_cparhdr db "Size of header in paragraphs",0
e_minalloc db "Minimum extra paragraphs needed",0
e_maxalloc db "Maximum extra paragraphs needed",0
e_ss db "Initial (relative) SS value",0
e_sp db "Initial SP value",0
e_csum db "Checksum",0
e_ip db "Initial IP value",0
e_cs db "Initial (relative) CS value",0
e_lfarlc db "File address of relocation table",0
e_ovno db "Overlay number",0
e_oemid db "OEM identifier (for e_oeminfo)",0
e_oeminfo db "OEM information; e_oemid specific",0
e_lfanew db "File address of new exe header",0
ntSignature db "Signature",0
fhmachine db "Machine",0
fhnumberofsections db "Number of Sections",0
fhtimedatestamp db "Time Stamp",0
fhpointertosymboltable db "Pointer to Symbol Table",0
fhnumberofsymbols db "Number of Symbols",0
fhsizeofoptionalheader db "Size of Optional Header",0
fhcharacteristics db "Characteristics",0
ohmagic db "Maigc",0
ohMajorLinkerVersion db "Major Linker Version",0
ohMinorLinkerVersion db "Minor Linker Version",0
ohSizeOfCode db "Size Of Code",0
ohSizeOfInitializedData db "Size Of Initialized Data",0
ohSizeOfUninitializedData db "Size Of UnInitialized Data",0
ohAddressOfEntryPoint db "Address Of Entry Point (.text)",0
ohBaseOfCode db "Base Of Code",0
ohBaseOfData db "Base Of Data",0
ohImageBase db "Image Base",0
ohSectionAlignment db "Section Alignment",0
ohFileAlignment db "File Alignment",0
ohMajorOperatingSystemVersion db "Major Operating System Version",0
ohMinorOperatingSystemVersion db "Minor Operating System Version",0
ohMajorImageVersion db "Major Image Version",0
ohMinorImageVersion db "Minor Image Version",0
ohMajorSubsystemVersion db "Major Subsystem Version",0
ohMinorSubsystemVersion db "Minor Subsystem Version",0
ohWin32VersionValue db "Win32 Version Value",0
ohSizeOfImage db "Size of Image",0
ohSizeOfHeaders db "Size of Headers",0
ohCheckSum db "CheckSum",0
ohSubsystem db "Subsystem",0
ohDllCharacteristics db "DllCharacteristics",0
ohSizeOfStackReserve db "Size Of Stack Reserve",0
ohSizeOfStackCommit db "Size Of Stack Commit",0
ohSizeOfHeapReserve db "Size Of Heap Reserve",0
ohSizeOfHeapCommit db "Size Of Heap Commit",0
ohLoaderFlags db "Loader Flags",0
ohNumberOfRvaAndSizes db "Number Of Rva And Sizes",0
dirVirtualAddress db "Virtual Adress",0
dirSize db "Size",0
secMisc db "Virtual Size",0
secVirtualAddress db "Virtual Address",0
secSizeOfRawData db "Size Of Raw Data",0
secPointerToRawData db "Pointer To Raw Data",0
secPointerToRelocations db "Pointer To Relocations",0
secPointerToLinenumbers db "Pointer To Line Numbers",0
secNumberOfRelocations db "Number Of Relocations",0
secNumberOfLinenumbers db "Number Of Line Numbers",0
secCharacteristics db "Characteristics",0
failmessage db "Could not read file",0
importByOrdinal db "Imported by Oridinal",0
exeextension db ".exe",0

.data?
buffer db MAXSIZE dup (?)
hInstance HINSTANCE ?
CommandLine LPSTR ?
hwndTreeView dd ?
hList  dd  ?
hImageList	dd ?
hParent		dd ?
hItem dd ?
himport dd ?
hSection dd ?
pSection dd ?
importDirectoryRVA dd ?
pImport dword ?
pimageNTHeaders dd ?
hFile HANDLE ?
hwndEdit HWND ?
hMemory HANDLE ?
pMemory DWORD ?
SizeReadWrite DWORD ?
temp db MAXSIZE dup(?)
importVirtualAddress dd ?
sectionheadertemp dd ?
numsectionheaders dd ?
sizeoh dd ?
rawOffset dd ?
importDescriptor dd ?
thunk dd ?
thunkData dd ?
.code
start:
   invoke GetModuleHandle, NULL
   mov   hInstance,eax
   invoke GetCommandLine
    mov CommandLine,eax
   invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
   invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
   LOCAL wc:WNDCLASSEX
   LOCAL msg:MSG
   LOCAL hwnd:HWND
   mov  wc.cbSize,SIZEOF WNDCLASSEX
   mov  wc.style, CS_HREDRAW or CS_VREDRAW
   mov  wc.lpfnWndProc, OFFSET WndProc
   mov  wc.cbClsExtra,NULL
   mov  wc.cbWndExtra,NULL
   push hInst
   pop  wc.hInstance
   mov  wc.hbrBackground,COLOR_WINDOW
   mov  wc.lpszMenuName,OFFSET MenuName       ; Put our menu name here
   mov  wc.lpszClassName,OFFSET ClassName
   invoke LoadIcon,NULL,IDI_APPLICATION
   mov  wc.hIcon,eax
   mov  wc.hIconSm,eax
   invoke LoadCursor,NULL,IDC_ARROW
   mov  wc.hCursor,eax
   invoke RegisterClassEx, addr wc
   invoke CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\
          WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
          CW_USEDEFAULT,700,450,NULL,NULL,\
          hInst,NULL
   mov  hwnd,eax
   invoke ShowWindow, hwnd,SW_SHOWNORMAL
   invoke UpdateWindow, hwnd
   .WHILE TRUE
               invoke GetMessage, ADDR msg,NULL,0,0
               .BREAK .IF (!eax)
               invoke DispatchMessage, ADDR msg
   .ENDW
   mov    eax,msg.wParam
   ret
WinMain endp

itoa proc value:DWORD, pstr:DWORD, base:DWORD
    push ebx
    push edi
    mov ebx, base               ; radix
    mov edi, pstr
    mov eax, value
    xor ecx, ecx                ; digit counter
    test eax, eax
    jns L0
    cmp ebx, 10
    jne L0
    mov BYTE PTR [edi], '-'     ; this only for negative base 10
    inc edi
    neg eax
  L0:
    xor edx, edx                ; need only 32-bit dividend
    DODIV                       ; divide value by base
    push edx                    ; push remainder = digit value
    inc ecx
    test eax, eax
    jnz L0                      ; continue until value = 0
    add edi, ecx                ; rig these to use counter as
    neg ecx                     ;  both counter and index
  L1:
    pop edx                     ; pop digit value and convert to digit
    cmp edx, 10
    jb  L2
    add edx, 'a'-10             ; 'a' instead of 'A' to match crt itoa output
    jmp L3
  L2:
    add edx, '0'
  L3:
    mov [edi+ecx], dl           ; store digit in string
    inc ecx
    jnz L1
    mov BYTE PTR [edi+ecx], 0   ; append null terminator
    pop edi
    pop ebx
    ret
itoa endp

InsertColumn proc
	LOCAL lvc:LV_COLUMN
	mov lvc.imask,LVCF_TEXT+LVCF_WIDTH
	mov lvc.pszText,offset Heading1
	mov lvc.lx,150
	invoke SendMessage,hList, LVM_INSERTCOLUMN,0,addr lvc
	or lvc.imask,LVCF_FMT
	mov lvc.fmt,LVCFMT_RIGHT
	mov lvc.pszText,offset Heading2
	mov lvc.lx,100
	invoke SendMessage,hList, LVM_INSERTCOLUMN, 1 ,addr lvc	
	ret		
InsertColumn endp
InsertColumn2 proc
	LOCAL lvc:LV_COLUMN
	mov lvc.imask,LVCF_TEXT+LVCF_WIDTH
	mov lvc.pszText,offset Heading3
	mov lvc.lx,150
	invoke SendMessage,hList, LVM_INSERTCOLUMN,0,addr lvc
	or lvc.imask,LVCF_FMT
	ret		
InsertColumn2 endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL tvinsert:TV_INSERTSTRUCT
	LOCAL hBitmap:DWORD
	LOCAL tvhit:TV_HITTESTINFO
    LOCAL tvitem:TV_ITEM
    LOCAL lvitem:LV_ITEM
    LOCAL found:DWORD
    LOCAL temp1:DWORD
    LOCAL temp2:DWORD
   .IF uMsg==WM_DESTROY
       invoke PostQuitMessage,NULL
    .ELSEIF uMsg==WM_CREATE
        invoke DragAcceptFiles, hWnd, TRUE
        invoke CreateWindowEx,NULL,ADDR TreeViewClass,NULL,\
                                       WS_CHILD+WS_VISIBLE+TVS_HASLINES+TVS_HASBUTTONS+TVS_LINESATROOT,0,\
                                      0,200,385,hWnd,1,hInstance,NULL
        mov hwndTreeView,eax
        invoke CreateWindowEx, NULL, addr ListViewClassName, NULL, LVS_REPORT+WS_CHILD+WS_VISIBLE, \
                                        210,0,470,385,hWnd, NULL, hInstance, NULL
        mov hList, eax
        RGB 255,255,255
        invoke SendMessage,hList,LVM_SETBKCOLOR,0,eax
        
        mov ofn.lStructSize,SIZEOF ofn
        push hWnd
        pop  ofn.hWndOwner
        push hInstance
        pop  ofn.hInstance
        mov  ofn.lpstrFilter, OFFSET FilterString
        mov  ofn.lpstrFile, OFFSET buffer
        mov  ofn.nMaxFile,MAXSIZE
    .ELSEIF uMsg==WM_COMMAND
       mov eax,wParam
       .IF ax==IDM_TEST
            invoke SendMessage,hwndTreeView,TVM_DELETEITEM,0,TVI_ROOT
            invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
            invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
            invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
            invoke CloseHandle,hFile
            invoke GlobalUnlock,pMemory
            invoke GlobalFree,hMemory
       .ELSEIF ax==IDM_OPEN
            mov ofn.lStructSize,SIZEOF ofn
            push hWnd
            pop  ofn.hwndOwner
            push hInstance
            pop  ofn.hInstance
            mov  ofn.lpstrFilter, OFFSET FilterString
            mov  ofn.lpstrFile, OFFSET buffer
            mov  ofn.nMaxFile,MAXSIZE
            mov  ofn.Flags, OFN_FILEMUSTEXIST or \
                OFN_PATHMUSTEXIST or OFN_LONGNAMES or\
                OFN_EXPLORER or OFN_HIDEREADONLY
            mov  ofn.lpstrTitle, OFFSET OurTitle
            invoke GetOpenFileName, ADDR ofn
            .if eax==TRUE
                invoke SendMessage,hwndTreeView,TVM_DELETEITEM,0,TVI_ROOT
                invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                invoke CloseHandle,hFile
                invoke GlobalUnlock,pMemory
                invoke GlobalFree,hMemory
                invoke CreateFile,ADDR buffer,\
                                       GENERIC_READ or GENERIC_WRITE ,\
                                       FILE_SHARE_READ or FILE_SHARE_WRITE,\
                                       NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\
                                       NULL
                .if eax == INVALID_HANDLE_VALUE
                    invoke MessageBox,NULL,offset failmessage,OFFSET AppName,MB_OK
                    jmp ENDOFNOTIFY
                .endif
                mov hFile,eax
                invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEMSIZE
                mov  hMemory,eax
                invoke GlobalLock,hMemory
                mov  pMemory,eax
                invoke ReadFile,hFile,pMemory,MEMSIZE-1,ADDR SizeReadWrite,NULL

                mov eax, pMemory
                ASSUME eax:PTR IMAGE_DOS_HEADER
                mov ebx,[eax].e_lfanew
                add eax, ebx
                mov pimageNTHeaders, eax
                ASSUME eax:nothing

                mov ebx, pimageNTHeaders
                ASSUME ebx:PTR IMAGE_NT_HEADERS32
                lea eax, [ebx].FileHeader
                mov ebx, eax
                ASSUME ebx:PTR IMAGE_FILE_HEADER
                
                xor ecx, ecx
                xor eax, eax
                mov cx, [ebx].SizeOfOptionalHeader
                mov sizeoh, ecx
                mov ax, [ebx].NumberOfSections
                mov numsectionheaders, eax
                ASSUME ebx:nothing

                mov ebx, pimageNTHeaders
                add ebx, SIZEOF DWORD
                add ebx, SIZEOF IMAGE_FILE_HEADER
                add ebx, sizeoh
                mov ecx, sizeoh
                mov pSection, ebx

                mov ebx, pimageNTHeaders
                ASSUME ebx:PTR IMAGE_NT_HEADERS32
                lea eax, [ebx].OptionalHeader
                mov ebx, eax
                ASSUME ebx:PTR IMAGE_OPTIONAL_HEADER32
                
                lea eax, [ebx].DataDirectory
                mov ebx, eax
                add ebx, IMAGE_DIRECTORY_ENTRY_IMPORT*SIZEOF IMAGE_DATA_DIRECTORY
                ASSUME ebx:PTR IMAGE_DATA_DIRECTORY

                mov eax, [ebx].VirtualAddress
                mov importDirectoryRVA, eax
                
                ASSUME ebx:nothing
                                
                invoke ImageList_Create,16,16,ILC_COLOR16,2,10
                mov hImageList,eax
                invoke LoadBitmap,hInstance,IDB_TREE
                mov hBitmap,eax
                invoke ImageList_Add,hImageList,hBitmap,NULL
                invoke DeleteObject,hBitmap
                invoke SendMessage,hwndTreeView,TVM_SETIMAGELIST,0,hImageList
                mov tvinsert.hParent,NULL
                mov tvinsert.hInsertAfter,TVI_ROOT
                mov tvinsert.item.imask,TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE
                mov tvinsert.item.pszText,offset header
                mov tvinsert.item.iImage,0
                mov tvinsert.item.iSelectedImage,1
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov hParent,eax
                
                mov tvinsert.hParent,eax
                mov tvinsert.hInsertAfter,TVI_LAST
                mov tvinsert.item.pszText,offset dosheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.item.pszText,offset ntheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.hParent,eax
                mov tvinsert.item.pszText,offset fileheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.item.pszText,offset optionalheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.item.pszText,offset datadir
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.hParent,eax
                mov tvinsert.item.pszText,offset datadirexport
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.item.pszText,offset datadirimport
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov eax, hParent
                mov tvinsert.hParent,eax
                mov tvinsert.item.pszText,offset sectionheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov hSection, eax

                mov tvinsert.hParent,NULL
                mov tvinsert.hInsertAfter,TVI_ROOT
                mov tvinsert.item.imask,TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE
                mov tvinsert.item.pszText,offset import
                mov tvinsert.item.iImage,0
                mov tvinsert.item.iSelectedImage,1
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov himport,eax

                mov ecx, numsectionheaders
                mov ebx, pSection
                ASSUME ebx:PTR IMAGE_SECTION_HEADER
                mov edi, offset buffer
                
                .while ecx != 0
                    mov al, byte ptr [ebx]
                    mov byte ptr [edi], al
                    mov al, byte ptr [ebx+1]
                    mov byte ptr [edi+1], al
                    mov al, byte ptr [ebx+2]
                    mov byte ptr [edi+2], al
                    mov al, byte ptr [ebx+3]
                    mov byte ptr [edi+3], al
                    mov al, byte ptr [ebx+4]
                    mov byte ptr [edi+4], al
                    mov al, byte ptr [ebx+5]
                    mov byte ptr [edi+5], al
                    mov al, byte ptr [ebx+6]
                    mov byte ptr [edi+6], al
                    mov al, byte ptr [ebx+7]
                    mov byte ptr [edi+7], al
                    mov byte ptr [edi+8],0

                    mov eax, hSection
                    mov tvinsert.hParent,eax
                    mov tvinsert.item.pszText,offset buffer

                    mov eax, [ebx].VirtualAddress
                    mov temp1, eax
                    mov eax, [ebx].Misc
                    mov temp2, eax
                    
                    push ecx
                    push ebx

                    mov edx, temp1              ;temp1 Virtual Address
                    add edx, temp2
                    mov temp2, edx              ;temp2 Virtual Address + Misc

                    mov eax, importDirectoryRVA

                    .if eax >= temp1 && eax <= temp2
                        mov pImport, ebx
                    .endif
                    
                    invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                    
                    pop ebx
                    pop ecx
                    dec ecx
                    add ebx, SIZEOF IMAGE_SECTION_HEADER
                .endw

                mov eax, pMemory
                mov ebx, pImport
                ASSUME ebx:PTR IMAGE_SECTION_HEADER
                add eax, [ebx].PointerToRawData
                mov rawOffset, eax
                add eax, importDirectoryRVA
                mov edx, [ebx].VirtualAddress
                mov importVirtualAddress, edx
                sub eax, edx
                mov importDescriptor, eax
                ASSUME ebx:nothing
                
                mov ebx,importDescriptor
                ASSUME ebx:PTR IMAGE_IMPORT_DESCRIPTOR
                mov edx, dword ptr [ebx+12]
                .while edx!= 0
                    mov eax, rawOffset
                    add eax, dword ptr [ebx+12]
                    sub eax, importVirtualAddress
                    invoke StrCpyW, offset buffer, eax
                    
                    mov eax, himport
                    mov tvinsert.hParent,eax
                    mov tvinsert.item.pszText,offset buffer

                    push edx
                    push ebx

                    invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                    pop ebx
                    pop edx
                    add ebx, SIZEOF IMAGE_IMPORT_DESCRIPTOR
                    mov edx, dword ptr [ebx+12]
                .endw

            .endif
        .ELSEIF ax==IDM_EXIT
            invoke CloseHandle,hFile
            invoke GlobalUnlock,pMemory
            invoke GlobalFree,hMemory
            invoke DestroyWindow,hWnd
       .ENDIF
    .ELSEIF uMsg==WM_NOTIFY
        mov eax,wParam
		    .IF ax==1
            mov ecx, lParam
            ASSUME ecx:PTR NMHDR
            .if [ecx].code == NM_DBLCLK
                
                invoke SendMessage, hwndTreeView, TVM_GETNEXTITEM, TVGN_CARET, hItem
                mov tvitem.hItem, eax
                mov tvitem.imask, TVIF_TEXT
                mov tvitem.pszText, offset temp
                mov tvitem.cchTextMax, MAXSIZE
                invoke SendMessage, hwndTreeView, TVM_GETITEM, 0, addr tvitem
                
                invoke StrCmpCA, tvitem.pszText, offset dosheader
                .if eax == 0
                    invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke InsertColumn
                    
                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_magic
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iItem, 0
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_magic
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem
                    
                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_cblp
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_cblp
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_cp
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_cp
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_crlc
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_crlc
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_cparhdr
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_cparhdr
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_minalloc
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_minalloc
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_maxalloc
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_maxalloc
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_ss
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_ss
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_sp
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_sp
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_csum
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_csum
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_ip
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_ip
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_cs
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_cs
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_lfarlc
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_lfarlc
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_ovno
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_ovno
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_oemid
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_oemid
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov ax, [ebx].e_oeminfo
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_oeminfo
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ebx, pMemory
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_DOS_HEADER
                    mov eax, [ebx].e_lfanew
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset e_lfanew
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    ASSUME ebx:nothing
                    jmp ENDOFNOTIFY
                .endif

                invoke StrCmpCA, tvitem.pszText, offset ntheader
                .if eax == 0
                    invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke InsertColumn
                    
                    mov ebx, pimageNTHeaders
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_NT_HEADERS32
                    mov eax, [ebx].Signature
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iItem, 0
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ntSignature
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem
                    
                    ASSUME ebx:nothing
                    jmp ENDOFNOTIFY
                .endif

                invoke StrCmpCA, tvitem.pszText, offset fileheader
                .if eax == 0
                    invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke InsertColumn
                    
                    mov ebx, pimageNTHeaders
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_NT_HEADERS32
                    lea eax, [ebx].FileHeader
                    mov ebx, eax
                    ASSUME ebx:PTR IMAGE_FILE_HEADER
                    xor eax, eax

                    mov ax, [ebx].Machine
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iItem, 0
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset fhmachine
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].NumberOfSections
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset fhnumberofsections
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].TimeDateStamp
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset fhtimedatestamp
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].PointerToSymbolTable
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset fhpointertosymboltable
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].NumberOfSymbols
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset fhnumberofsymbols
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].SizeOfOptionalHeader
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset fhsizeofoptionalheader
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].Characteristics
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset fhcharacteristics
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem 
                    
                    ASSUME ebx:nothing
                    jmp ENDOFNOTIFY
                .endif

                invoke StrCmpCA, tvitem.pszText, offset optionalheader
                .if eax == 0
                    invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke InsertColumn
                    
                    mov ebx, pimageNTHeaders
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_NT_HEADERS32
                    lea eax, [ebx].OptionalHeader
                    mov ebx, eax
                    ASSUME ebx:PTR IMAGE_OPTIONAL_HEADER32
                    xor eax, eax

                    mov ax, [ebx].Magic
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iItem, 0
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohmagic
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov al, [ebx].MajorLinkerVersion
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohMajorImageVersion
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov al, [ebx].MinorLinkerVersion
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohMinorImageVersion
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfCode
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSizeOfCode
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfInitializedData
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSizeOfInitializedData
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfUninitializedData
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSizeOfUninitializedData
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].AddressOfEntryPoint
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohAddressOfEntryPoint
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].BaseOfCode
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohBaseOfCode
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].BaseOfData
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohBaseOfData
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].ImageBase
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohImageBase
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SectionAlignment
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSectionAlignment
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].FileAlignment
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohFileAlignment
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].MajorOperatingSystemVersion
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohMajorOperatingSystemVersion
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].MinorOperatingSystemVersion
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohMinorOperatingSystemVersion
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].MajorImageVersion
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohMajorImageVersion
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].MinorImageVersion
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohMinorImageVersion
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].MajorSubsystemVersion
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohMajorSubsystemVersion
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].MinorSubsystemVersion
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohMinorSubsystemVersion
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].Win32VersionValue
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohWin32VersionValue
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfImage
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSizeOfImage
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfHeaders
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSizeOfHeaders
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].CheckSum
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohCheckSum
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].Subsystem
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSubsystem
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].DllCharacteristics
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohDllCharacteristics
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfStackReserve
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSizeOfStackReserve
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfStackCommit
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSizeOfStackCommit
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfHeapReserve
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSizeOfHeapReserve
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfHeapCommit
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohSizeOfHeapCommit
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].LoaderFlags
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohLoaderFlags
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].NumberOfRvaAndSizes
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset ohNumberOfRvaAndSizes
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    ASSUME ebx:nothing
                    jmp ENDOFNOTIFY
                .endif

                invoke StrCmpCA, tvitem.pszText, offset datadirexport
                .if eax == 0
                    invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke InsertColumn
                    
                    mov ebx, pimageNTHeaders
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_NT_HEADERS32
                    lea eax, [ebx].OptionalHeader
                    mov ebx, eax
                    ASSUME ebx:PTR IMAGE_OPTIONAL_HEADER32
                    lea eax, [ebx].DataDirectory
                    mov ebx, eax
                    ASSUME ebx:PTR IMAGE_DATA_DIRECTORY

                    mov eax, [ebx].VirtualAddress
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iItem, 0
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset dirVirtualAddress
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, dword ptr [ebx+4]
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset dirSize
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem
                    
                    ASSUME ebx:nothing
                    jmp ENDOFNOTIFY
                .endif

                invoke StrCmpCA, tvitem.pszText, offset datadirimport
                .if eax == 0
                    invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke InsertColumn
                    
                    mov ebx, pimageNTHeaders
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_NT_HEADERS32
                    lea eax, [ebx].OptionalHeader
                    mov ebx, eax
                    ASSUME ebx:PTR IMAGE_OPTIONAL_HEADER32
                    lea eax, [ebx].DataDirectory
                    mov ebx, eax
                    add ebx, 8
                    ASSUME ebx:PTR IMAGE_DATA_DIRECTORY

                    mov eax, [ebx].VirtualAddress
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iItem, 0
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset dirVirtualAddress
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, dword ptr [ebx+4]
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset dirSize
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem
                    
                    ASSUME ebx:nothing
                    jmp ENDOFNOTIFY
                .endif
                
                mov ecx, numsectionheaders
                mov ebx, pSection
                ASSUME ebx:PTR IMAGE_SECTION_HEADER
                mov edi, offset buffer
                mov found,0
                .while ecx != 0
                    mov al, byte ptr [ebx]
                    mov byte ptr [edi], al
                    mov al, byte ptr [ebx+1]
                    mov byte ptr [edi+1], al
                    mov al, byte ptr [ebx+2]
                    mov byte ptr [edi+2], al
                    mov al, byte ptr [ebx+3]
                    mov byte ptr [edi+3], al
                    mov al, byte ptr [ebx+4]
                    mov byte ptr [edi+4], al
                    mov al, byte ptr [ebx+5]
                    mov byte ptr [edi+5], al
                    mov al, byte ptr [ebx+6]
                    mov byte ptr [edi+6], al
                    mov al, byte ptr [ebx+7]
                    mov byte ptr [edi+7], al
                    mov byte ptr [edi+8],0
                    push ecx
                    push ebx
                    invoke StrCmpCA, tvitem.pszText, offset buffer
                    .if eax==0
                        mov found, 1
                        mov sectionheadertemp, ebx
                        pop ebx
                        pop ecx
                        .break
                    .endif
                    pop ebx
                    pop ecx
                    dec ecx
                    add ebx, SIZEOF IMAGE_SECTION_HEADER
                .endw
                mov eax, found
                .if eax==0
                    jmp IMPORTS
                .else
                    invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke InsertColumn
                    mov ebx, sectionheadertemp
                    xor eax, eax
                    ASSUME ebx:PTR IMAGE_SECTION_HEADER

                    mov eax, [ebx].Misc
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iItem, 0
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset secMisc
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].VirtualAddress
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset secVirtualAddress
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].SizeOfRawData
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset secSizeOfRawData
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].PointerToRawData
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset secPointerToRawData
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].PointerToRelocations
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset secPointerToRelocations
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].PointerToLinenumbers
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset secPointerToLinenumbers
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].NumberOfRelocations
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset secNumberOfRelocations
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov ax, [ebx].NumberOfLinenumbers
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset secNumberOfLinenumbers
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem

                    mov eax, [ebx].Characteristics
                    invoke itoa, eax, offset buffer, 16
                    mov lvitem.imask,LVIF_TEXT
                    mov lvitem.iSubItem,0
                    mov lvitem.pszText,offset buffer
                    mov lvitem.lParam,0
                    invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                    inc lvitem.iSubItem
                    mov lvitem.pszText,offset secCharacteristics
                    invoke SendMessage,hList,LVM_SETITEM, 0,addr lvitem
                    inc lvitem.iItem
                    
                    jmp ENDOFNOTIFY
                .endif

IMPORTS:
                mov found, 0
                mov ebx,importDescriptor
                ASSUME ebx:PTR IMAGE_IMPORT_DESCRIPTOR
                mov edx, dword ptr [ebx+12]
                .while edx!= 0
                    mov eax, rawOffset
                    add eax, dword ptr [ebx+12]
                    sub eax, importVirtualAddress
                    push edx
                    push ebx
                    invoke StrCpyW, offset buffer, eax                 
                    invoke StrCmpCA, tvitem.pszText, offset buffer
                    .if eax==0
                        pop ebx
                        pop edx
                        mov found, 1
                        mov temp1, ebx
                        .break
                    .endif
                    pop ebx
                    pop edx
                    add ebx, SIZEOF IMAGE_IMPORT_DESCRIPTOR
                    mov edx, dword ptr [ebx+12]
                .endw

                mov eax, found
                .if eax==0
                    jmp ENDOFNOTIFY
                .else
                    invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                    invoke InsertColumn2
                    
                    mov ebx, temp1
                    ASSUME ebx:PTR IMAGE_SECTION_HEADER

                    mov eax, dword ptr [ebx]
                    .if eax==0
                        mov ecx, dword ptr [ebx+16]
                        mov thunk, ecx
                    .else
                        mov ecx, eax
                        mov thunk, ecx
                    .endif
                    
                    mov eax, rawOffset
                    add eax, thunk
                    sub eax, importVirtualAddress
                    mov ecx, eax
                    mov eax, dword ptr [ecx]

                    .while eax!=0
                        mov edx, rawOffset
                        add edx, eax
                        sub edx, importVirtualAddress
                        add edx, 2
                        push eax
                        push ecx
                        
                        .if eax<80000000h
                            invoke StrCpyW, offset buffer, edx
                            mov lvitem.imask,LVIF_TEXT
                            mov lvitem.iSubItem,0
                            mov lvitem.pszText,offset buffer
                            mov lvitem.lParam,0
                            invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                            inc lvitem.iItem
                        .else
                            mov lvitem.imask,LVIF_TEXT
                            mov lvitem.iSubItem,0
                            mov lvitem.pszText,offset importByOrdinal
                            mov lvitem.lParam,0
                            invoke SendMessage,hList, LVM_INSERTITEM,0, addr lvitem
                            inc lvitem.iItem
                        .endif
                        pop ecx
                        pop eax
                        add ecx, 4
                        mov eax, dword ptr [ecx]
                    .endw

                    jmp ENDOFNOTIFY
                .endif
            .endif
            ASSUME ecx:nothing
            
        .endif

    .ELSEIF uMsg==WM_DROPFILES
        invoke DragQueryFileA, wParam, 0, offset buffer, MAXSIZE
        .if eax!=0
            invoke PathFindExtensionA, offset buffer
            invoke StrCmpCA, offset exeextension, eax
            .if eax==0
                invoke SendMessage,hwndTreeView,TVM_DELETEITEM,0,TVI_ROOT
                invoke SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                invoke SendMessage, hList, LVM_DELETECOLUMN, 0, 0
                invoke CloseHandle,hFile
                invoke GlobalUnlock,pMemory
                invoke GlobalFree,hMemory
                invoke CreateFile,ADDR buffer,\
                                        GENERIC_READ or GENERIC_WRITE ,\
                                        FILE_SHARE_READ or FILE_SHARE_WRITE,\
                                        NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\
                                        NULL
                .if eax == INVALID_HANDLE_VALUE
                    invoke MessageBox,NULL,offset failmessage,OFFSET AppName,MB_OK
                    jmp ENDOFNOTIFY
                .endif
                mov hFile,eax
                invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,MEMSIZE
                mov  hMemory,eax
                invoke GlobalLock,hMemory
                mov  pMemory,eax
                invoke ReadFile,hFile,pMemory,MEMSIZE-1,ADDR SizeReadWrite,NULL

                mov eax, pMemory
                ASSUME eax:PTR IMAGE_DOS_HEADER
                mov ebx,[eax].e_lfanew
                add eax, ebx
                mov pimageNTHeaders, eax
                ASSUME eax:nothing

                mov ebx, pimageNTHeaders
                ASSUME ebx:PTR IMAGE_NT_HEADERS32
                lea eax, [ebx].FileHeader
                mov ebx, eax
                ASSUME ebx:PTR IMAGE_FILE_HEADER
                
                xor ecx, ecx
                xor eax, eax
                mov cx, [ebx].SizeOfOptionalHeader
                mov sizeoh, ecx
                mov ax, [ebx].NumberOfSections
                mov numsectionheaders, eax
                ASSUME ebx:nothing

                mov ebx, pimageNTHeaders
                add ebx, SIZEOF DWORD
                add ebx, SIZEOF IMAGE_FILE_HEADER
                add ebx, sizeoh
                mov ecx, sizeoh
                mov pSection, ebx

                mov ebx, pimageNTHeaders
                ASSUME ebx:PTR IMAGE_NT_HEADERS32
                lea eax, [ebx].OptionalHeader
                mov ebx, eax
                ASSUME ebx:PTR IMAGE_OPTIONAL_HEADER32
                
                lea eax, [ebx].DataDirectory
                mov ebx, eax
                add ebx, IMAGE_DIRECTORY_ENTRY_IMPORT*SIZEOF IMAGE_DATA_DIRECTORY
                ASSUME ebx:PTR IMAGE_DATA_DIRECTORY

                mov eax, [ebx].VirtualAddress
                mov importDirectoryRVA, eax
                
                ASSUME ebx:nothing
                                
                invoke ImageList_Create,16,16,ILC_COLOR16,2,10
                mov hImageList,eax
                invoke LoadBitmap,hInstance,IDB_TREE
                mov hBitmap,eax
                invoke ImageList_Add,hImageList,hBitmap,NULL
                invoke DeleteObject,hBitmap
                invoke SendMessage,hwndTreeView,TVM_SETIMAGELIST,0,hImageList
                mov tvinsert.hParent,NULL
                mov tvinsert.hInsertAfter,TVI_ROOT
                mov tvinsert.item.imask,TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE
                mov tvinsert.item.pszText,offset header
                mov tvinsert.item.iImage,0
                mov tvinsert.item.iSelectedImage,1
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov hParent,eax
                
                mov tvinsert.hParent,eax
                mov tvinsert.hInsertAfter,TVI_LAST
                mov tvinsert.item.pszText,offset dosheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.item.pszText,offset ntheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.hParent,eax
                mov tvinsert.item.pszText,offset fileheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.item.pszText,offset optionalheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.item.pszText,offset datadir
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.hParent,eax
                mov tvinsert.item.pszText,offset datadirexport
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov tvinsert.item.pszText,offset datadirimport
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov eax, hParent
                mov tvinsert.hParent,eax
                mov tvinsert.item.pszText,offset sectionheader
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov hSection, eax

                mov tvinsert.hParent,NULL
                mov tvinsert.hInsertAfter,TVI_ROOT
                mov tvinsert.item.imask,TVIF_TEXT+TVIF_IMAGE+TVIF_SELECTEDIMAGE
                mov tvinsert.item.pszText,offset import
                mov tvinsert.item.iImage,0
                mov tvinsert.item.iSelectedImage,1
                invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                mov himport,eax

                mov ecx, numsectionheaders
                mov ebx, pSection
                ASSUME ebx:PTR IMAGE_SECTION_HEADER
                mov edi, offset buffer
                
                .while ecx != 0
                    mov al, byte ptr [ebx]
                    mov byte ptr [edi], al
                    mov al, byte ptr [ebx+1]
                    mov byte ptr [edi+1], al
                    mov al, byte ptr [ebx+2]
                    mov byte ptr [edi+2], al
                    mov al, byte ptr [ebx+3]
                    mov byte ptr [edi+3], al
                    mov al, byte ptr [ebx+4]
                    mov byte ptr [edi+4], al
                    mov al, byte ptr [ebx+5]
                    mov byte ptr [edi+5], al
                    mov al, byte ptr [ebx+6]
                    mov byte ptr [edi+6], al
                    mov al, byte ptr [ebx+7]
                    mov byte ptr [edi+7], al
                    mov byte ptr [edi+8],0

                    mov eax, hSection
                    mov tvinsert.hParent,eax
                    mov tvinsert.item.pszText,offset buffer

                    mov eax, [ebx].VirtualAddress
                    mov temp1, eax
                    mov eax, [ebx].Misc
                    mov temp2, eax
                    
                    push ecx
                    push ebx

                    mov edx, temp1              ;temp1 Virtual Address
                    add edx, temp2
                    mov temp2, edx              ;temp2 Virtual Address + Misc

                    mov eax, importDirectoryRVA

                    .if eax >= temp1 && eax <= temp2
                        mov pImport, ebx
                    .endif
                    
                    invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                    
                    pop ebx
                    pop ecx
                    dec ecx
                    add ebx, SIZEOF IMAGE_SECTION_HEADER
                .endw

                mov eax, pMemory
                mov ebx, pImport
                ASSUME ebx:PTR IMAGE_SECTION_HEADER
                add eax, [ebx].PointerToRawData
                mov rawOffset, eax
                add eax, importDirectoryRVA
                mov edx, [ebx].VirtualAddress
                mov importVirtualAddress, edx
                sub eax, edx
                mov importDescriptor, eax
                ASSUME ebx:nothing
                
                mov ebx,importDescriptor
                ASSUME ebx:PTR IMAGE_IMPORT_DESCRIPTOR
                mov edx, dword ptr [ebx+12]
                .while edx!= 0
                    mov eax, rawOffset
                    add eax, dword ptr [ebx+12]
                    sub eax, importVirtualAddress
                    invoke StrCpyW, offset buffer, eax
                    
                    mov eax, himport
                    mov tvinsert.hParent,eax
                    mov tvinsert.item.pszText,offset buffer

                    push edx
                    push ebx

                    invoke SendMessage,hwndTreeView,TVM_INSERTITEM,0,addr tvinsert
                    pop ebx
                    pop edx
                    add ebx, SIZEOF IMAGE_IMPORT_DESCRIPTOR
                    mov edx, dword ptr [ebx+12]
                .endw
            .else
                invoke MessageBox,NULL,offset failmessage,OFFSET AppName,MB_OK
                jmp ENDOFNOTIFY
            .endif
        .endif
ENDOFNOTIFY:
   .ELSE
       invoke DefWindowProc,hWnd,uMsg,wParam,lParam
       ret
   .ENDIF
   xor   eax,eax
   ret
WndProc endp
end start