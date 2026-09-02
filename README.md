# Excel VBA Winsock TCP Sample

Excel VBAからWindowsのWinsock APIを直接呼び出し、ローカルPC内でTCP通信を試すための学習用サンプルです。

追加のActiveXコントロールや外部ライブラリは使用しません。VBA標準モジュール1ファイルで、TCPサーバーとTCPクライアントの基本的な処理順序を確認できます。

> [!IMPORTANT]
> このリポジトリは、Winsock APIの呼び出し方を学ぶための最小サンプルです。認証、暗号化、タイムアウト、再送制御、複数クライアントの並行処理は実装していません。インターネットへ公開するサーバーには使用しないでください。

## このサンプルで確認できること

- `WSAStartup` / `WSACleanup`によるWinsockの初期化と終了
- `socket` / `bind` / `listen` / `accept` / `recv`によるTCP受信
- `socket` / `connect` / `send`によるTCP送信
- `closesocket`によるサーバー・クライアントソケットの解放
- `PtrSafe`と`LongPtr`を使った32ビット／64ビットOffice対応
- 別のExcelプロセスをサーバーとして起動する方法

## 動作環境

- Windows
- Excel 2010以降（VBA 7）
- 32ビット版または64ビット版Office
- マクロを保存できるExcelブック（`.xlsm`または`.xlsb`）

macOS版ExcelではWindows DLLを呼び出せないため動作しません。

## ファイル

| ファイル | 内容 |
| --- | --- |
| `VBA_WinsockAPI_TCP_Sample.bas` | TCPサーバー、TCPクライアント、動作確認用マクロを含む標準モジュール |

## 使い方

### 1. 標準モジュールを取り込む

1. マクロ有効ブックを作成し、一度保存します。
2. `Alt` + `F11`でVisual Basic Editorを開きます。
3. メニューの「ファイル」→「ファイルのインポート」を選びます。
4. `VBA_WinsockAPI_TCP_Sample.bas`を選択します。
5. 「デバッグ」→「VBAProjectのコンパイル」を実行します。

### 2. サーバーを起動する

`MainForMultiProcess`を実行します。

同じブックが読み取り専用で別のExcelプロセスに開かれ、1秒後に`TCPRecv`が開始します。既定では`127.0.0.1:60051`で接続を待ちます。

### 3. クライアントから送信する

最初のExcelへ戻り、次のいずれかを実行します。

| マクロ | 送信内容 | サーバー側の動作 |
| --- | --- | --- |
| `testHELLO` | `HELLO` | 接続元のIPアドレスとポート番号を表示 |
| `testElse` | `else message` | 受信文字列を表示 |
| `testQUIT` | `QUIT` | 受信ループを終了 |

`testQUIT`は受信ループだけを終了します。別プロセスのExcel自体は自動終了しないため、内容を確認してから手動で閉じてください。

## 通信の流れ

### サーバー

```text
WSAStartup → socket → bind → listen → accept → recv → closesocket → WSACleanup
```

### クライアント

```text
WSAStartup → socket → connect → send → closesocket → WSACleanup
```

## 接続先を変更する

モジュール先頭付近の次の定数を変更します。

```vb
Private Const DEFAULT_SERVER_IP As String = "127.0.0.1"
Private Const DEFAULT_SERVER_PORT As Long = 60051
```

初めて試す場合は、外部から接続できないループバックアドレス`127.0.0.1`のまま使用してください。

## 制限事項

- IPv4のみ対応
- 1回の`recv`で受け取った内容を1つのメッセージとして扱う簡易実装
- 文字列はASCII範囲での利用を想定
- `accept`と`recv`は同期・ブロッキング処理
- 同時に複数クライアントを処理する機能はなし
- 通信の認証・暗号化・完全性検証はなし

`DoEvents`はブロッキング中の`accept`や`recv`を非同期化するものではありません。このサンプルでは、Excelの操作用プロセスと受信用プロセスを分けて影響を限定しています。

## トラブルシューティング

### `Address already in use`に相当するエラーになる

同じポートを使うサーバーが既に起動している可能性があります。別プロセスのExcelを閉じるか、`DEFAULT_SERVER_PORT`を未使用のポートへ変更してください。

### Windows Defender Firewallの確認が表示される

初回実行時に表示されることがあります。このサンプルをローカルPC内だけで試す場合は、接続先を`127.0.0.1`から変更しないでください。

### 64ビットOfficeでAPI宣言エラーになる

最新版の`.bas`を取り込み直し、「デバッグ」→「VBAProjectのコンパイル」を実行してください。ソケットはWindowsのハンドルであるため、変数とAPIの戻り値に`LongPtr`を使用しています。

## 参考資料

- [64-bit Visual Basic for Applications overview](https://learn.microsoft.com/office/vba/language/concepts/getting-started/64-bit-visual-basic-for-applications-overview)
- [socket function](https://learn.microsoft.com/windows/win32/api/winsock2/nf-winsock2-socket)
- [accept function](https://learn.microsoft.com/windows/win32/api/winsock2/nf-winsock2-accept)
- [send function](https://learn.microsoft.com/windows/win32/api/winsock2/nf-winsock2-send)
- [recv function](https://learn.microsoft.com/windows/win32/api/winsock2/nf-winsock2-recv)
- [closesocket function](https://learn.microsoft.com/windows/win32/api/winsock2/nf-winsock2-closesocket)

## Repository scope

This is an educational Excel VBA sample for direct TCP communication through the Windows Winsock API. It is intentionally kept separate from HTTP, WebSocket, and LLM API examples.
