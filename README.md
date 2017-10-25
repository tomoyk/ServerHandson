# サーバ構築入門(Apache/WordPress)

## 1. はじめに

この講座では, あらかじめ用意したVirtualMachineを使って演習を行います。必ずVMWare環境を用意してください。

## 2. Linuxについて

Linuxとは当時、大学生であったLinus Torvaldsが開発したOS(オペレーティングシステム)です。UNIX互換のOSとして開発された。Linuxのプログラムの特徴としてライセンス形態が挙げられる。Linuxのプログラムには`GPL(GNU General Public License)というライセンス形式が付与されている。これには以下の内容が含まれています。

> - プログラムを実行する自由
> - ソースの改変の自由
> - 利用・再配布の自由
> - 改良したプログラムをリリースする権利
> 
> (Linux標準教科書より引用)

こうした自由な形態を採用した為、限られた組織や個人によって独占されることなく広く普及し発展しました。詳しいことは`書籍:Unix考古学`などに書かれています。

## 3. サーバについて

サーバとは不特定多数によるアクセスが可能なコンピュータ。

// 説明を加える

## 4. Webサーバの構築

### 4.0 アジェンダ

- VMを起動
- ネットワーク設定の確認
- Apacheのインストール
- プロセスの確認
- ポートの確認
- ファイヤウォールの確認

### 4.1 VMの起動

VMware Playerを起動して、配布したVMを立ち上げます。

img01

VMが起動したら以下の資格情報でログインしてください。

- UserName: ebi
- Password: kappaebi1000

img02

### 4.2 ネットワーク設定

#### IPアドレスの確認

IPアドレスを確認します。コマンドラインに`ifconfig`または`ip a`を入力します。

	ebi@ebi-virtual-machine:~$ ifconfig
	ens33: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
	        inet 192.168.223.154  netmask 255.255.255.0  broadcast 192.168.223.255
	        inet6 fe80::a8dc:fd46:8a0b:d3e9  prefixlen 64  scopeid 0x20<link>
	        ether 00:0c:29:90:d5:eb  txqueuelen 1000  (イーサネット)
	        RX packets 80  bytes 24103 (24.1 KB)
	        RX errors 0  dropped 0  overruns 0  frame 0
	        TX packets 120  bytes 12064 (12.0 KB)
	        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
	
	lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
	        inet 127.0.0.1  netmask 255.0.0.0
	        inet6 ::1  prefixlen 128  scopeid 0x10<host>
	        loop  txqueuelen 1000  (ローカルループバック)
	        RX packets 108  bytes 7968 (7.9 KB)
	        RX errors 0  dropped 0  overruns 0  frame 0
	        TX packets 108  bytes 7968 (7.9 KB)
	        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
	ebi@ebi-virtual-machine:~$ ip a
	1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
	    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
	    inet 127.0.0.1/8 scope host lo
	       valid_lft forever preferred_lft forever
	    inet6 ::1/128 scope host 
	       valid_lft forever preferred_lft forever
	2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
	    link/ether 00:0c:29:90:d5:eb brd ff:ff:ff:ff:ff:ff
	    inet 192.168.223.154/24 brd 192.168.223.255 scope global dynamic ens33
	       valid_lft 1152sec preferred_lft 1152sec
	    inet6 fe80::a8dc:fd46:8a0b:d3e9/64 scope link 
	       valid_lft forever preferred_lft forever

ここで`192.168.x.x`という文字列が見つかります。これがローカルネットワークにおけるIPアドレスです。

// 抽出した実行結果

ローカルネットワークのIPアドレスは国際標準規格`RFC1918`によって下記の範囲で定められています。

|クラス|IPアドレス範囲|
|---|---|
|A|10.0.0.0	-	10.255.255.255 (10/8 prefix)|
|B|172.16.0.0	-	172.31.255.255 (172.16/12 prefix)|
|C|192.168.0.0	-	192.168.255.255 (192.168/16 prefix)|

参考: [プライベート網のアドレス割当(RFC 1918) - JPNIC](https://www.nic.ad.jp/ja/translation/rfc/1918.html)

今回使ったNAT設定は、仮想マシン(Virtual Machine)からのパケットを実機(Windows)でアドレスやポート変換して外部と通信します。

#### 疎通の確認

次に`pingコマンド`を利用してネットワーク通信が行えるか確認します。ターミナルに`ping 8.8.8.8`と入力してEnterを押下します。終了するには`Ctrl + C`を押します。

	ebi@ebi-virtual-machine:~$ ping 8.8.8.8
	PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
	64 bytes from 8.8.8.8: icmp_seq=1 ttl=128 time=4.43 ms
	64 bytes from 8.8.8.8: icmp_seq=2 ttl=128 time=4.78 ms
	64 bytes from 8.8.8.8: icmp_seq=3 ttl=128 time=3.98 ms
	64 bytes from 8.8.8.8: icmp_seq=4 ttl=128 time=4.30 ms
	64 bytes from 8.8.8.8: icmp_seq=5 ttl=128 time=5.06 ms
	^C
	--- 8.8.8.8 ping statistics ---
	5 packets transmitted, 5 received, 0% packet loss, time 4010ms
	rtt min/avg/max/mdev = 3.987/4.515/5.061/0.376 ms
	
	ebi@ebi-virtual-machine:~$ ping 8.8.8.7
	PING 8.8.8.7 (8.8.8.7) 56(84) bytes of data.
	^C
	--- 8.8.8.7 ping statistics ---
	7 packets transmitted, 0 received, 100% packet loss, time 6128ms

サーバからの応答があれば外部との通信が出来ていると判断できます。

### 4.3 パッケージのインストール

#### パッケージマネージャについて

ソフトウェアをインストールします。Windowsでソフトウェアをインストールするには、インストーラをダウンロードして実行する必要があります。

Linuxにはソフトウェアを一元管理しているパッケージマネージャという便利な仕組みがあります。この仕組みによってソフトウェアをパッケージという単位でコマンドを使って管理できるようになります。

#### Apacheのインストール

次にApacheというWebサーバソフトウェアをパッケージマネージャと利用してインストールします。ターミナルに以下のコマンドを打ち込みます。

`sudo apt install apache2`

	ebi@ebi-virtual-machine:~$ sudo apt install apache2
	[sudo] ebi のパスワード: 
	パッケージリストを読み込んでいます... 完了
	依存関係ツリーを作成しています                
	状態情報を読み取っています... 完了
	以下の追加パッケージがインストールされます:
	  apache2-bin apache2-data apache2-utils libapr1 libaprutil1
	  libaprutil1-dbd-sqlite3 libaprutil1-ldap
	提案パッケージ:
	  apache2-doc apache2-suexec-pristine | apache2-suexec-custom
	以下のパッケージが新たにインストールされます:
	  apache2 apache2-bin apache2-data apache2-utils libapr1 libaprutil1
	  libaprutil1-dbd-sqlite3 libaprutil1-ldap
	アップグレード: 0 個、新規インストール: 8 個、削除: 0 個、保留: 0 個。
	1,502 kB のアーカイブを取得する必要があります。
	この操作後に追加で 6,175 kB のディスク容量が消費されます。
	続行しますか? [Y/n] y

確認が出るので`y`を入力して`Enter`を押します.

	取得:1 http://jp.archive.ubuntu.com/ubuntu artful/main amd64 libapr1 amd64 1.6.2-1 [90.9 kB]
	取得:2 http://jp.archive.ubuntu.com/ubuntu artful/main amd64 libaprutil1 amd64 1.6.0-2 [84.2 kB]
	取得:3 http://jp.archive.ubuntu.com/ubuntu artful/main amd64 libaprutil1-dbd-sqlite3 amd64 1.6.0-2 [10.5 kB]
	取得:4 http://jp.archive.ubuntu.com/ubuntu artful/main amd64 libaprutil1-ldap amd64 1.6.0-2 [8,660 B]
	取得:5 http://jp.archive.ubuntu.com/ubuntu artful/main amd64 apache2-bin amd64 2.4.27-2ubuntu3 [968 kB]
	取得:6 http://jp.archive.ubuntu.com/ubuntu artful/main amd64 apache2-utils amd64 2.4.27-2ubuntu3 [82.5 kB]
	取得:7 http://jp.archive.ubuntu.com/ubuntu artful/main amd64 apache2-data all 2.4.27-2ubuntu3 [161 kB]
	取得:8 http://jp.archive.ubuntu.com/ubuntu artful/main amd64 apache2 amd64 2.4.27-2ubuntu3 [95.8 kB]
	1,502 kB を 0秒 で取得しました (5,591 kB/s)
	以前に未選択のパッケージ libapr1:amd64 を選択しています。
	(データベースを読み込んでいます ... 現在 113374 個のファイルとディレクトリがインストールされています。)
	.../0-libapr1_1.6.2-1_amd64.deb を展開する準備をしています ...
	libapr1:amd64 (1.6.2-1) を展開しています...
	以前に未選択のパッケージ libaprutil1:amd64 を選択しています。
	.../1-libaprutil1_1.6.0-2_amd64.deb を展開する準備をしています ...
	libaprutil1:amd64 (1.6.0-2) を展開しています...
	以前に未選択のパッケージ libaprutil1-dbd-sqlite3:amd64 を選択しています。
	.../2-libaprutil1-dbd-sqlite3_1.6.0-2_amd64.deb を展開する準備をしています ...
	libaprutil1-dbd-sqlite3:amd64 (1.6.0-2) を展開しています...
	以前に未選択のパッケージ libaprutil1-ldap:amd64 を選択しています。
	.../3-libaprutil1-ldap_1.6.0-2_amd64.deb を展開する準備をしています ...
	libaprutil1-ldap:amd64 (1.6.0-2) を展開しています...
	以前に未選択のパッケージ apache2-bin を選択しています。
	.../4-apache2-bin_2.4.27-2ubuntu3_amd64.deb を展開する準備をしています ...
	apache2-bin (2.4.27-2ubuntu3) を展開しています...
	以前に未選択のパッケージ apache2-utils を選択しています。
	.../5-apache2-utils_2.4.27-2ubuntu3_amd64.deb を展開する準備をしています ...
	apache2-utils (2.4.27-2ubuntu3) を展開しています...
	以前に未選択のパッケージ apache2-data を選択しています。
	.../6-apache2-data_2.4.27-2ubuntu3_all.deb を展開する準備をしています ...
	apache2-data (2.4.27-2ubuntu3) を展開しています...
	以前に未選択のパッケージ apache2 を選択しています。
	.../7-apache2_2.4.27-2ubuntu3_amd64.deb を展開する準備をしています ...
	apache2 (2.4.27-2ubuntu3) を展開しています...
	libapr1:amd64 (1.6.2-1) を設定しています ...
	ufw (0.35-5) のトリガを処理しています ...
	ureadahead (0.100.0-20) のトリガを処理しています ...
	apache2-data (2.4.27-2ubuntu3) を設定しています ...
	libc-bin (2.26-0ubuntu2) のトリガを処理しています ...
	libaprutil1:amd64 (1.6.0-2) を設定しています ...
	systemd (234-2ubuntu12) のトリガを処理しています ...
	man-db (2.7.6.1-2) のトリガを処理しています ...
	libaprutil1-ldap:amd64 (1.6.0-2) を設定しています ...
	libaprutil1-dbd-sqlite3:amd64 (1.6.0-2) を設定しています ...
	apache2-utils (2.4.27-2ubuntu3) を設定しています ...
	apache2-bin (2.4.27-2ubuntu3) を設定しています ...
	apache2 (2.4.27-2ubuntu3) を設定しています ...
	Enabling module mpm_event.
	Enabling module authz_core.
	Enabling module authz_host.
	Enabling module authn_core.
	Enabling module auth_basic.
	Enabling module access_compat.
	Enabling module authn_file.
	Enabling module authz_user.
	Enabling module alias.
	Enabling module dir.
	Enabling module autoindex.
	Enabling module env.
	Enabling module mime.
	Enabling module negotiation.
	Enabling module setenvif.
	Enabling module filter.
	Enabling module deflate.
	Enabling module status.
	Enabling module reqtimeout.
	Enabling conf charset.
	Enabling conf localized-error-pages.
	Enabling conf other-vhosts-access-log.
	Enabling conf security.
	Enabling conf serve-cgi-bin.
	Enabling site 000-default.
	Created symlink /etc/systemd/system/multi-user.target.wants/apache2.service → /lib/systemd/system/apache2.service.
	Created symlink /etc/systemd/system/multi-user.target.wants/apache-htcacheclean.service → /lib/systemd/system/apache-htcacheclean.service.
	libc-bin (2.26-0ubuntu2) のトリガを処理しています ...
	ureadahead (0.100.0-20) のトリガを処理しています ...
	systemd (234-2ubuntu12) のトリガを処理しています ...
	ufw (0.35-5) のトリガを処理しています ...

Apacheのインストールが完了しました。

### プロセスの確認

Linuxではアプリケーション1つひとつに**プロセスID**というIDが付与されます。これによってプロセスを区別しています。Windowsのタスクマネージャでプロセスが起動している様子をイメージすると分かりやすいです。

Apacheのインストールが終わるとApacheは自動で起動します。まず、Apacheのプロセスが存在するか`psコマンド`で確認します。

`ps aux | grep apache`

	ebi@ebi-virtual-machine:~$ sudo ps -aux | grep apache
	root       2590  0.0  0.4  73856  4588 ?        Ss   11:49   0:00 /usr/sbin/apache2 -k start
	www-data   2592  0.0  0.4 821768  4428 ?        Sl   11:49   0:00 /usr/sbin/apache2 -k start
	www-data   2593  0.0  0.4 821768  4428 ?        Sl   11:49   0:00 /usr/sbin/apache2 -k start
	ebi        2853  0.0  0.1  15380  1052 pts/0    S+   11:57   0:00 grep --color=auto apache

表示された結果の1番左が`プロセスが実行されたユーザ`、左から2番目が`プロセスID`、一番右が`プロセスの実行内容(コマンド)`をそれぞれ表しています。これでApacheのプロセスが起動していることが確認できます。

### ポート状況の確認

ポート開放状況は`netstat`か`ss`を使って確認します。`| grep -i xxx`の部分で大文字小文字の区別なく`xxx`という文字列を検索します。

	ebi@ebi-virtual-machine:~$ netstat -ant | grep -i listen
	tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN
	tcp        0      0 127.0.0.1:631           0.0.0.0:*               LISTEN
	tcp        0      0 0.0.0.0:5355            0.0.0.0:*               LISTEN
	tcp6       0      0 :::22                   :::*                    LISTEN
	tcp6       0      0 ::1:631                 :::*                    LISTEN
	tcp6       0      0 :::5355                 :::*                    LISTEN
	tcp6       0      0 :::80                   :::*                    LISTEN
	ebi@ebi-virtual-machine:~$ ss -ant | grep -i listen
	LISTEN     0      128          *:22                       *:*
	LISTEN     0      5      127.0.0.1:631                      *:*
	LISTEN     0      128          *:5355                     *:*
	LISTEN     0      128         :::22                      :::*
	LISTEN     0      5          ::1:631                     :::*
	LISTEN     0      128         :::5355                    :::*
	LISTEN     0      128         :::80                      :::*

以下の行を見ることで`TCP 80番ポート`が開放されていると分かります。

	ebi@ebi-virtual-machine:~$ netstat -ant | grep -i listen
	(略)
	tcp6       0      0 :::80                   :::*                    LISTEN
	ebi@ebi-virtual-machine:~$ ss -ant | grep -i listen
	(略)
	LISTEN     0      128         :::80                      :::*

以下に主要なポートの一覧をあげます。

|ポート番号|プロトコル|サービス名|
|---|---|---|
|80|TCP|HTTP|
|53|UDP|DNS|
|22|TCP|SSH|
|443|TCP|HTTPS|

### PHP(プログラミング言語)のインストール

プログラミング言語PHPの実行に必要なパッケージをインストールします。

`sudo apt install libapache2-mod-php libapache2-mod-php7.1 php-common php7.1-cli php7.1-common php7.1-json php7.1-opcache php7.1-readline php7.1-gd php7.1-xmlrpc php7.1-dev php7.1-mbstring php7.1-mysql`

	ebi@ebi-virtual-machine:~$ sudo apt install libapache2-mod-php libapache2-mod-php7.1 php-common php7.1-cli php7.1-common php7.1-json php7.1-opcache php7.1-readline php7.1-gd php7.1-xmlrpc php7.1-dev php7.1-mbstring php7.1-mysql
	パッケージリストを読み込んでいます... 完了
	依存関係ツリーを作成しています
	状態情報を読み取っています... 完了
	以下の追加パッケージがインストールされます:
	  autoconf automake autopoint autotools-dev binutils binutils-common binutils-x86-64-linux-gnu build-essential debhelper dh-autoreconf
	  dh-strip-nondeterminism dpkg-dev fakeroot g++ g++-7 gcc gcc-7 gettext intltool-debian libalgorithm-diff-perl libalgorithm-diff-xs-perl
	  libalgorithm-merge-perl libarchive-cpio-perl libarchive-zip-perl libasan4 libatomic1 libbinutils libc-dev-bin libc6-dev libcc1-0
	  libcilkrts5 libdpkg-perl libfakeroot libfile-fcntllock-perl libfile-stripnondeterminism-perl libgcc-7-dev libitm1 liblsan0 libltdl-dev
	  libmail-sendmail-perl libmpx2 libpcre16-3 libpcre3-dev libpcre32-3 libpcrecpp0v5 libsigsegv2 libssl-dev libssl-doc libstdc++-7-dev
	  libsys-hostname-long-perl libtool libtsan0 libubsan0 libxmlrpc-epi0 linux-libc-dev m4 make manpages-dev php-pear php-xml php7.1-xml
	  pkg-php-tools po-debconf shtool zlib1g-dev
	提案パッケージ:
	  autoconf-archive gnu-standards autoconf-doc binutils-doc dh-make debian-keyring g++-multilib g++-7-multilib gcc-7-doc libstdc++6-7-dbg
	  gcc-multilib flex bison gdb gcc-doc gcc-7-multilib gcc-7-locales libgcc1-dbg libgomp1-dbg libitm1-dbg libatomic1-dbg libasan4-dbg
	  liblsan0-dbg libtsan0-dbg libubsan0-dbg libcilkrts5-dbg libmpx2-dbg libquadmath0-dbg gettext-doc libasprintf-dev libgettextpo-dev
	  glibc-doc libtool-doc libstdc++-7-doc gfortran | fortran95-compiler gcj-jdk m4-doc make-doc dh-php libmail-box-perl
	以下のパッケージが新たにインストールされます:
	  autoconf automake autopoint autotools-dev binutils binutils-common binutils-x86-64-linux-gnu build-essential debhelper dh-autoreconf
	  dh-strip-nondeterminism dpkg-dev fakeroot g++ g++-7 gcc gcc-7 gettext intltool-debian libalgorithm-diff-perl libalgorithm-diff-xs-perl
	  libalgorithm-merge-perl libapache2-mod-php libapache2-mod-php7.1 libarchive-cpio-perl libarchive-zip-perl libasan4 libatomic1
	  libbinutils libc-dev-bin libc6-dev libcc1-0 libcilkrts5 libdpkg-perl libfakeroot libfile-fcntllock-perl libfile-stripnondeterminism-perl
	  libgcc-7-dev libitm1 liblsan0 libltdl-dev libmail-sendmail-perl libmpx2 libpcre16-3 libpcre3-dev libpcre32-3 libpcrecpp0v5 libsigsegv2
	  libssl-dev libssl-doc libstdc++-7-dev libsys-hostname-long-perl libtool libtsan0 libubsan0 libxmlrpc-epi0 linux-libc-dev m4 make
	  manpages-dev php-common php-pear php-xml php7.1-cli php7.1-common php7.1-dev php7.1-gd php7.1-json php7.1-mbstring php7.1-mysql
	  php7.1-opcache php7.1-readline php7.1-xml php7.1-xmlrpc pkg-php-tools po-debconf shtool zlib1g-dev
	アップグレード: 0 個、新規インストール: 78 個、削除: 0 個、保留: 0 個。
	42.3 MB のアーカイブを取得する必要があります。
	この操作後に追加で 185 MB のディスク容量が消費されます。
	続行しますか? [Y/n] y

キー`y`を押して`Enter`で続行します。

**ApacheでPHPを使うためのパッケージ**

- libapache2-mod-php
- libapache2-mod-php7.1

**WordPressで必要となるPHPのパッケージ**

- php-common
- php7.1-cli
- php7.1-common
- php7.1-json
- php7.1-opcache
- php7.1-readline
- php7.1-gd
- php7.1-xmlrpc
- php7.1-dev
- php7.1-mbstring
- php7.1-mysql

### MySQLデータベースのインストール



