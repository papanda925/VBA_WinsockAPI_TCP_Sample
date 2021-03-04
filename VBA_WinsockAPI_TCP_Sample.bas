Attribute VB_Name = "VBA_WinsockAPI_TCP_Sample"
Option Explicit

'* ---  FormatMessage  --- */
'FormatMessage.dwFlags
Private Const FORMAT_MESSAGE_ALLOCATE_BUFFER As Long = &H100
Private Const FORMAT_MESSAGE_ARGUMENT_ARRAY As Long = &H2000
Private Const FORMAT_MESSAGE_FROM_HMODULE As Long = &H800
Private Const FORMAT_MESSAGE_FROM_STRING As Long = &H400
Private Const FORMAT_MESSAGE_FROM_SYSTEM As Long = &H1000
Private Const FORMAT_MESSAGE_IGNORE_INSERTS As Long = &H200
Private Const FORMAT_MESSAGE_MAX_WIDTH_MASK As Long = &HFF
'FormatMessage(API)
Private Declare PtrSafe Function FormatMessage Lib "kernel32" Alias "FormatMessageA" (ByVal dwFlags As Long, lpSource As Long, _
        ByVal dwMessageId As Long, ByVal dwLanguageId As Long, _
        ByVal lpBuffer As String, ByVal nSize As Long, Arguments As LongPtr) _
        As Long

'* ---  WSAStartup / WSACleanup  --- */
'WSAStartup / WSACleanup size
Private Const WSASYS_STATUS_LEN  As Long = 128
Private Const WSASYS_STATUS_SIZE As Long = WSASYS_STATUS_LEN + 1
Private Const WSADESCRIPTION_LEN As Long = 256
Private Const WSADESCRIPTION_SIZE As Long = WSADESCRIPTION_LEN + 1

Public Type WSADATA
    wVersion As Integer
    wHighVersion As Integer
    szDescription As String * WSADESCRIPTION_SIZE
    szSystemStatus As String * WSASYS_STATUS_SIZE
    iMaxSockets As Integer
    iMaxUdpDg As Integer
    lpVendorInfo As Long
End Type

'WSAStartup / WSACleanup(API)
Public Declare PtrSafe Function WSAStartup Lib "ws2_32.dll" (ByVal wVersionRequested As Integer, ByRef lpWSADATA As WSADATA) As Long
Public Declare PtrSafe Function WSACleanup Lib "wsock32.dll" () As Long

'* ---  Network�@ --- */
Private Enum AF
  AF_UNSPEC = 0
  AF_INET = 2
  AF_IPX = 6
  AF_APPLETALK = 16
  AF_NETBIOS = 17
  AF_INET6 = 23
  AF_IRDA = 26
  AF_BTH = 32
End Enum

Private Enum SOCKTYPE
   SOCK_STREAM = 1
   SOCK_DGRAM = 2
   SOCK_RAW = 3
   SOCK_RDM = 4
   SOCK_SEQPACKET = 5
End Enum

Private Enum PROTOCOL
   IPPROTO_ICMP = 1
   IPPROTO_IGMP = 2
   BTHPROTO_RFCOMM = 3
   IPPROTO_TCP = 6
   IPPROTO_UDP = 17
   IPPROTO_ICMPV6 = 58
   IPPROTO_RM = 113
End Enum

' IPv4 address
Public Type sockaddr_in
    sin_family As Integer
    sin_port As Integer
    sin_addr As Long
    sin_zero1 As Long
    sin_zero2 As Long
End Type

Private Const INVALID_SOCKET = -1
Private Const SOCKET_ERROR As Long = -1

'socket / closesocket(API)
Public Declare PtrSafe Function socket Lib "wsock32.dll" (ByVal lngAf As LongPtr, ByVal lngType As LongPtr, ByVal lngProtocol As LongPtr) As Long
Public Declare PtrSafe Function closesocket Lib "ws2_32.dll" (ByVal socketHandle As Long) As Long
'bind(API)
Private Declare PtrSafe Function bind Lib "ws2_32.dll" (ByVal s As Long, ByRef name As sockaddr_in, ByVal namelen As Long) As Long
'accept(API)
Private Declare PtrSafe Function accept Lib "ws2_32.dll" (ByVal s As Long, ByRef name As sockaddr_in, ByRef namelen As LongPtr) As Long
'htons(API)
Private Declare PtrSafe Function htons Lib "ws2_32.dll" (ByVal hostshort As Long) As Integer
'ntohs(API)
Private Declare PtrSafe Function ntohs Lib "ws2_32.dll" (ByVal netshort As Long) As Integer
' inet_addr(API) IP���h�b�g�`��(x.x.x.x)��������`���ɕύX
Private Declare PtrSafe Function inet_addr Lib "ws2_32.dll" (ByVal cp As String) As Long
'IPv4�܂���IPv6�C���^�[�l�b�g�l�b�g���[�N�A�h���X����C���^�[�l�b�g�W���`���̕�����ɕϊ�
Private Declare PtrSafe Function InetNtopW Lib "ws2_32.dll" (ByVal Family As Integer, ByRef pAddr As Long, ByVal pStringBuf As String, ByVal StringBufSize As Integer) As Long

'TCP�N���C�A���g�����ڑ��� �Ƃ肠����5
'http://www.kt.rim.or.jp/~ksk/wskfaq-ja/advanced.html
Const SOMAXCONN As Integer = 5
'listen(API)
Private Declare PtrSafe Function listen Lib "ws2_32.dll" (ByVal s As Long, ByVal backlog As Long) As Long
'send(API)
Private Declare PtrSafe Function send Lib "ws2_32.dll" (ByVal s As Long, ByVal buf As String, ByVal length As Long, ByVal flags As Long, ByRef remoteAddr As sockaddr_in, ByVal remoteAddrSize As Long) As Long

'recv(API)
Private Declare PtrSafe Function recv Lib "wsock32.dll" (ByVal socket As Long, ByVal buf As String, ByVal length As Long, ByVal flags As Long) As Long

'connect(API)
Private Declare PtrSafe Function connect Lib "ws2_32.dll" (ByVal s As Long, ByRef name As sockaddr_in, ByVal namelen As Long) As Long

'* ---  Sleep --- */
Private Declare PtrSafe Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

'�G���[�R�[�h��FormatMessage�ŉǉ\�ɕϊ�
Public Function GetFormatMessageString(Optional ByVal dwMessageId As Long = 0) As String
    Dim dwFlags As Long    '�I�v�V�����t���O
    Dim lpBuffer As String '���b�Z�[�W���i�[���邽�̃o�b�t�@
    Dim result As Long     '�߂�l(������̃o�C�g��)
    
    '�����ȗ��Ή��
    If dwMessageId = 0 Then
        dwMessageId = VBA.Information.Err().LastDllError '���ݒ�̏ꍇ��LastDllError���Z�b�g
    End If
    
    dwFlags = FORMAT_MESSAGE_FROM_SYSTEM Or FORMAT_MESSAGE_IGNORE_INSERTS Or FORMAT_MESSAGE_MAX_WIDTH_MASK
    lpBuffer = String(1024, vbNullChar)
    result = FormatMessage(dwFlags, 0&, dwMessageId, 0&, lpBuffer, Len(lpBuffer), 0&)
    If (result > 0) Then
        lpBuffer = Left(lpBuffer, InStr(lpBuffer, vbNullChar) - 1) 'Null�I�[�܂Ŏ擾
    Else
        lpBuffer = ""
    End If
    
    GetFormatMessageString = lpBuffer & "(" & dwMessageId & ")"
End Function

'C����@MAKEWORD ����
Public Function MAKEWORD(Lo As Byte, Hi As Byte) As Integer
    MAKEWORD = Lo + Hi * 256& Or 32768 * (Hi > 127)
End Function

Public Sub TCPRecv()
    'WSAStartup�@socket bind  listen�@accept  recv�@closesocket   WSACleanup
    Dim ServerIP As String: ServerIP = "127.0.0.1"
    Dim ServerPort As Long: ServerPort = 60051
    Dim ServerAddr As sockaddr_in
    Dim ServerSocket As Long

    Dim ClientAddr As sockaddr_in
    Dim ClientSocket As Long

    Dim RetCode As Long
    
    Const RecvBuffSize As Long = 2048
    Dim recvBuffer As String * RecvBuffSize
    Dim ipBuffer As String
    
    Dim WSAD As WSADATA
    RetCode = WSAStartup(MAKEWORD(2, 2), WSAD)
    If RetCode <> 0 Then
        MsgBox "WSAStartup failed with error�F" & GetFormatMessageString(RetCode)
        Exit Sub
    End If
    
    ServerSocket = socket(AF.AF_INET, SOCKTYPE.SOCK_STREAM, 0)
    If ServerSocket = INVALID_SOCKET Then
        MsgBox "SOCKET failed with error�F" & GetFormatMessageString(Err.LastDllError)
        GoTo EXIT_POINT
    End If
    
    ServerAddr.sin_family = AF_INET
    ServerAddr.sin_addr = inet_addr(ServerIP)
    ServerAddr.sin_port = htons(ServerPort)
        
    RetCode = bind(ServerSocket, ServerAddr, LenB(ServerAddr))
    If RetCode = SOCKET_ERROR Then
        MsgBox "Error binding listener socket: " & GetFormatMessageString(Err.LastDllError)
        GoTo EXIT_POINT
     End If
    
    'listen SOMAXCONN�͂Ƃ肠�����ݒ�@�����Ƒ傫�����Ă�OK
    RetCode = listen(ServerSocket, SOMAXCONN)
    If RetCode = SOCKET_ERROR Then
        MsgBox "Error listen: " & GetFormatMessageString(Err.LastDllError)
        GoTo EXIT_POINT
    End If

    Do While True
        DoEvents
        Sleep 200
        recvBuffer = String(RecvBuffSize, vbNullChar)
        'accept ������Client����̐ڑ��҂�
        ClientSocket = accept(ServerSocket, ClientAddr, LenB(ClientAddr))
        If ClientSocket = SOCKET_ERROR Then
            MsgBox "Error binding listener socket: " & GetFormatMessageString(Err.LastDllError)
            GoTo EXIT_POINT
        End If

        RetCode = recv(ClientSocket, recvBuffer, RecvBuffSize, 0)
        If (RetCode > 0) Then

            ipBuffer = Left(recvBuffer, InStr(recvBuffer, vbNullChar) - 1) 'Null�I�[�܂Ŏ擾
            '�d������
            '�d�l�F
            'HELLO -> HELLO VBA Winsock API �Ɠ�����B
            'QUIT  -> �����I��
            '����ȊO�͒ʒm���ꂽ���������̂܂ܕ\������B
                                
            Select Case ipBuffer
                Case "HELLO"
                    MsgBox "HELLO VBA Winsock API " & PrintIPAndPortNumber(ClientAddr)

                Case "QUIT"
                    MsgBox "�T�[�o�[ �����I���d����M���� �I���������܂��B:" & ipBuffer
                    GoTo EXIT_POINT: '��M���������烋�[�v�𔲂���
                Case Else
                    MsgBox "�T�[�o�[ �d����M����:" & ipBuffer
            End Select
        ElseIf RetCode = SOCKET_ERROR Then
            MsgBox "recv error:" & GetFormatMessageString(Err.LastDllError)
            GoTo EXIT_POINT:
        End If
    Loop
    
EXIT_POINT:
     If closesocket(ServerSocket) = SOCKET_ERROR Then
        MsgBox "closesocket failed with error�F" & GetFormatMessageString(Err.LastDllError)
     End If
     If WSACleanup() <> 0 Then
        MsgBox "Windows Sockets error occurred in Cleanup.", vbExclamation
     End If

    '�����Ŏ������g�����B
    ThisWorkbook.Close
    Application.Quit

End Sub


Public Sub TCPSend(ByRef Msg As String)
' WSAStartup ->   socket �� sendto�@���@ closesocket�@ WSACleanup

    Dim RetCode As Long
    Dim WSADATA As WSADATA
    Dim SendSocketHandle As Long
    Dim DstAddr As sockaddr_in
    
    '�p�����[�^
    Dim ServerIP As String: ServerIP = "127.0.0.1"
    Dim ServerPort As Long: ServerPort = 60051
    Dim strbuffer As String
    strbuffer = Msg
   
    '�X�^�[�g�A�b�v
    RetCode = WSAStartup(MAKEWORD(2, 2), WSADATA)
    If RetCode <> 0 Then
        MsgBox "WSAStartup failed with error�F" & GetFormatMessageString(RetCode)
        Exit Sub
    End If

    'TCP socket
    SendSocketHandle = socket(AF.AF_INET, SOCKTYPE.SOCK_STREAM, 0)
    If SendSocketHandle = INVALID_SOCKET Then
        MsgBox "SOCKET failed with error�F" & GetFormatMessageString(Err.LastDllError)
        GoTo EXIT_POINT
    End If

    DstAddr.sin_family = AF.AF_INET
    DstAddr.sin_addr = inet_addr(ServerIP)
    DstAddr.sin_port = htons(Convert_u_short_PortNumber(ServerPort))

    'TCP connect
    RetCode = connect(SendSocketHandle, DstAddr, LenB(DstAddr))
    If RetCode = INVALID_SOCKET Then
        MsgBox "w_connect failed with error�F" & GetFormatMessageString(Err.LastDllError)
        GoTo EXIT_POINT
    End If

    'send
    RetCode = send(SendSocketHandle, strbuffer, Len(strbuffer), 0, DstAddr, LenB(DstAddr))
    If RetCode = SOCKET_ERROR Then
        MsgBox "sendto failed with error�F" & GetFormatMessageString(Err.LastDllError)
        GoTo EXIT_POINT
    Else
        Debug.Print "Sendto:" & PrintIPAndPortNumber(DstAddr)
    End If

EXIT_POINT:
     If closesocket(SendSocketHandle) = SOCKET_ERROR Then
        MsgBox "closesocket failed with error�F" & GetFormatMessageString(Err.LastDllError)
     End If
     If WSACleanup() <> 0 Then
        MsgBox "Windows Sockets error occurred in Cleanup.", vbExclamation
     End If
End Sub

Function PrintIPAndPortNumber(ByRef Addr As sockaddr_in) As String
        Dim s As String
        Dim s2 As String
        s = String(100, vbNullChar)
        Call InetNtopW(AF.AF_INET, Addr.sin_addr, s, 128)
        s2 = Replace(s, vbNullChar, "")
        PrintIPAndPortNumber = "IPv4�A�h���X�F" & s2 & " �|�[�g�ԍ�" & u_short_PortNumberToLong(ntohs(Addr.sin_port))
End Function


Sub MainForMultiProcess()
    Dim SVApp As Application
    Dim SVWb As Workbook
    
    '�ʃv���Z�X���T�[�o�Ƃ��ċN��
    Set SVApp = New Application
    SVApp.Visible = True '�f�o�b�O�p�ɕ\���A�s�v�ł����false�ɂ���΂悢
    Set SVWb = SVApp.Workbooks.Open(ThisWorkbook.FullName, _
                                    UpdateLinks:=False, _
                                    ReadOnly:=True)

    '�T�[�o�v���Z�X�N��
    '�����̎��Ă΂��v���V�[�W���ɂ�OnTime�݂̂��L�q�������ɉ�����Ԃ��B
    Call SVApp.Run("'" & SVWb.name & "'!OnTimeTCPRecv")
    
End Sub

'TCPRecv�̋N��
Private Sub OnTimeTCPRecv()
    Application.OnTime Now + TimeValue("00:00:1"), "TCPRecv"
End Sub

'�T���v���d��
Sub testHELLO()
    Call TCPSend("HELLO")
End Sub

Sub testElse()
    Call TCPSend("else message ")
End Sub

Sub testQUIT()
    Call TCPSend("QUIT")
End Sub

'�|�[�g�ԍ���u_short�i16bit�̕����Ȃ������^�j�ɕϊ������f�[�^�̉Ǘp�\���p�ϊ�
Function u_short_PortNumberToLong(ByVal u_short_PortNumber As Integer) As Long
    u_short_PortNumberToLong = 65535 And u_short_PortNumber
End Function

'�|�[�g�ԍ���u_short�i16bit�̕����Ȃ������^�j�ɕϊ�����B
'VB�ł́A16bit�̌^��Integer�ɂȂ邪�A�������萮�����߁A32767�ȏ�̐����l��������ƃI�[�o�[�t���[����B
'���̂���Bit���x����,Integer�^�ɂ͂ߍ���
Function Convert_u_short_PortNumber(ByVal PortNumber As Long) As Integer
    Select Case PortNumber
        Case Is < 0&: Err.Raise "UnderFlow  PortNumber is 0 - 65535"
        Case 0 To 32767:  Convert_u_short_PortNumber = PortNumber
        Case 32768 To 65535: Convert_u_short_PortNumber = PortNumber - 65536
        Case Is > 65535: Err.Raise Number:=513, Description:="OverFlow PortNumber is 0 - 65535"
    End Select
End Function

