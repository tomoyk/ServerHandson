# サーバ構築入門(Apache/WordPress)

## 1. はじめに

この講座では, あらかじめ用意したVirtualMachineを使って演習を行います。必ずVMWare環境を用意してください。

## 2. Linuxについて

Linuxとは当時、大学生であったLinus Torvaldsが開発したOS(オペレーティングシステム)です。UNIX互換のOSとして開発された。Linuxのプログラムの特徴としてライセンス形態が挙げられる。Linuxのプログラムには`GPL(GNU General Public License)というライセンス形式が付与されている。これには以下の内容が含まれています。

> プログラムを実行する自由
> ソースの改変の自由
> 利用・再配布の自由
> 改良したプログラムをリリースする権利
> (Linux標準教科書より引用)

こうした自由な形態を採用した為、限られた組織や個人によって独占されることなく広く普及し発展しました。詳しいことは`書籍:Unix考古学`などに書かれています。

## 3. サーバについて

サーバとは不特定多数によるアクセスが可能なコンピュータ。

// 説明を加える

## 4. Webサーバの構築

### 4.1 VMの起動

VMware Playerを起動して、配布したVMを立ち上げます。

// photo

VMが起動したら以下の資格情報でログインしてください。

- UserName: xxx
- Password: yyy

### 4.2 ネットワーク設定

#### IPアドレスの確認

IPアドレスを確認します。コマンドラインに`ifconfig`または`ip a`を入力します。

// 実行結果

ここで`10.203.x.x`という文字列が見つかります。これがローカルネットワーク(大学内部のネットワーク)におけるIPアドレスです。

// 抽出した実行結果

ローカルネットワークのIPアドレスは国際標準規格`RFC1918`によって下記の範囲で定められています。

|クラス|IPアドレス範囲|
|---|---|
|A|10.0.0.0	-	10.255.255.255 (10/8 prefix)|
|B|172.16.0.0	-	172.31.255.255 (172.16/12 prefix)|
|C|192.168.0.0	-	192.168.255.255 (192.168/16 prefix)|

参考: [プライベート網のアドレス割当(RFC 1918) - JPNIC](https://www.nic.ad.jp/ja/translation/rfc/1918.html)

#### 疎通の確認

次に`pingコマンド`を利用してネットワーク通信が行えるか確認します。ターミナルに`ping 8.8.8.8`と入力してEnterを押下します。終了するには`Ctrl + C`を押します。

// 実行結果

サーバからの応答があれば外部との通信が出来ていると判断できます。

### 4.3 パッケージのインストール

#### パッケージマネージャについて

ソフトウェアをインストールします。Windowsでソフトウェアをインストールするには、インストーラをダウンロードして実行する必要があります。

Linuxにはソフトウェアを一元管理しているパッケージマネージャという便利な仕組みがあります。この仕組みによってソフトウェアをパッケージという単位でコマンドを使って管理できるようになります。

#### Apacheのインストール

次にApacheというWebサーバソフトウェアをインストールします。ターミナルに以下のコマンドを打ち込みます。

`sudo apt install apache2`





