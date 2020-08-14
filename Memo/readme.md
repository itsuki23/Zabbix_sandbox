# Zabbix Conf
```
HostGroup / Host
              ↑
            Template(ミドルウェア、アプリ)
              ↑
            Application
           　 │
           　 ├── item
           　 │    │ └── triger ── action
           　 │    │ 
           　 │    └──── graph/map/screen/dashbord
           　 │
           　 └── web
```

# Flow
```
・監視項目の洗い出し。
・監視項目に対応したKeyを調べる。ない場合はUserParameterで定義。
・ZabbixServerもしくはproxyからのzabbix_getコマンドで値取得を確認。
・ZabbixWebでアイテムの設定。値を取得できることを確認。
・トリガーを設定。テストアラートを発報してみる。
```
```
＜共通事項＞
　プロセスは起動しているか
　ネットワークの疎通、速度は問題ないか
　CPU・メモリ・ディスク監視の閾値は異常ではないか
　時刻同期できているか
　監視エージェントのログにエラーがでていないか

＜Webサーバー＞
　ページが見れない　　　　　　　　　　　（名前解決・URL間違い）
　ページの表示が遅い　　　　　　　　　　（ネットワークスループット？Diskが不適切か、CDNを挟むか）
　ページのコンテンツの読み込みが遅い　　（キャッシュレイヤーを挟むことも検討）
　変なページが読み込まれる　　　　　　　（セキュリティ脆弱性・提供者の間違い）
　時間によって速さが違ったりおそくないか（スケジューリングによるオートスケールの検討）
　各種ログ

＜Mysql＞
　マスター、スレーブそれぞれの役割でレプリケーションできているか
```
　

# Definition
- Host
```
1. Web_Nginx_Server       : Template{Linux_OS, Basic, Web_Nginx}
2. DB_MySQL_Master_Server : Template{Linux_OS, Basic, DB_MySQL_Master}
3. DB_MySQL_Slave_Server  : Template{Linux_OS, Basic, DB_MySQL_Slave}
```

- Template
```
--------------------------------------------------------------------
Template Basic
--------------------------------------------------------------------
[item]
    Basic cpu                : system.cpu.util[,user]  × Linux_OSで定義済
    Basic Load Average 15min : system.cpu.load[,avg15]
    Basic Memory size        : vm.memory.size[free]
    Basic Disk Size          : vfs.fs.size[/,pused]
    Basic process SSHD       : proc.num[sshd]
    Basic port 22            : net.tcp.listen[22]
    Basic log Zbx Agent      : log[/var/log/zabbix/zabbix_agentd.log]  (※Active)
    item MYK Local Time Sync : system.localtime

[triger]
    Basic cpu over 80%            : 障害条件 {Template Basic:system.cpu.util[,user].last(#3)}>=80
                                    復旧条件 {Templaet Basic:system.cppu.util[,user].last(#3)}<60
    Basic prosess SSHD non-active : 障害条件 {Template Basic:proc.num[sshd]}=0
                                    復旧条件 {Templaet Basic:proc.num[sshd]}=1

    Basic Time Sync diff 3s       : {Template Basic:system.localtime.fuzzytime(3)}=0
    Basic Agent log "error" 5/10m : {Template Basic:log[/var/log/zabbix/zabbix_agentd.log].str("error")}=1
                                    and
                                    {Template Basic:log[/var/log/zabbix/zabbix_agentd.log].count(10m,"error")}>5
    Basic Agent log nodata 5m     : {Template Basic:log[/var/log/zabbix/zabbix_agentd.log].nodata(5m)}=0
                                    # Check ActiveCheck (RefreshActiveChecks: default 120s)
--------------------------------------------------------------------
Template Web_Nginx
--------------------------------------------------------------------
[item]
    Web_Nginx process HTTP     : proc.num[http]
    Web_Nginx port 80          : net.tcp.lisWeb
    Web_Nginx Nginx access log : log[/var/log/nginx/access.log] (※Active)(今回dockerなので無効化)
    Web_Nginx Nginx error log  : log[/var/log/nginx/error.log]　(※Active)(今回dockerなので無効化)
--------------------------------------------------------------------
Template DB_MySQL_Master
--------------------------------------------------------------------
[item]
    DB_Master mysqk $1で指定↓
    DB_Master mysql Seconds_Behind_Master : mysql.slave.status[Seconds_Behind_Master]
    DB_Master mysql Read_Master_Log_Pos   : mysql.slave.status[Read_Master_Log_Pos]
    DB_Master mysql Master_Log_File       : mysql.slave.status[Master_Log_File]
    DB_Master mysql Slave_SQL_Running     : mysql.slave.status[Slave_SQL_Running]
    DB_Master mysql Slave_IO_Running      : mysql.slave.status[Slave_IO_Running]

    DB_Master process MySQL   : proc.num[mysql]
    DB_Master port 3306       : net.tcp.listen[3306]
    DB_Master Mysql error log : log[/var/log/mysqld.log]  (※Active)
[triger]

--------------------------------------------------------------------
Template DB_MySQL_Slave
--------------------------------------------------------------------
[item]
    DB_Slave mysqk $1で指定↓
    DB_Slave mysqk File       : mysql.master.status[File]
    DB_Slave mysqk Position   : mysql.master.status[Position]

    DB_Slave process MySQL    : proc.num[mysql]
    DB_Slave port 3306        : net.tcp.listen[3306]
    DB_Slave Mysql error log  : log[/var/log/mysqld.log]  (※Active)

[triger]
    DB_Slave IO_Running       : {<Template_name>:mysql.slave.status[Slave_IO_Running].regexp(Yes)}=0

--------------------------------------------------------------------
※今回は抜粋して確認。Triger...
```

# 個別テスト
## リソース監視
##### CPU, ロードアベレージ, メモリ, ディスク使用率
```
<CPU>
    $ vmstatコマンドで監視すべき項目を確認       https://densan-hoshigumi.com/server/zabbix-linux-cpu-monitoring
    procs   ------cpu-----  -----------memory----------  ---swap--  -----io----  -system-- 
    r  b   us sy id wa st    swpd   free   buff  cache    si   so     bi    bo    in   cs 
    0  0    0  0 99  0  0       0 268512   2088 341032     0    0      9   142   101  176  

    item  : system.cpu.util[,user]
    triger: 障害の条件式 {Template OS Linux:system.cpu.util[,user].last(#3)}>=90
            復旧の条件式 {Template OS Linux:system.cpu.util[,user].last(#3)}<80

<ロードアベレージ>
    item  : key: system.cpu.load[,avg1]     => データ型は浮動小数点。1分(avg1)、5分(avg5)、15分(avg15)から選択できる
    triger: {A_Template_OS_Linux:system.cpu.load[,avg1].last()}>2

<メモリ>
    item  : vm.memory.size[free]            https://it-study.info/network/zabbix/zabbix-monitoring-memory/
            system.swap.size[,free]
    triger: 障害の条件式 {Template OS Linux:vm.memory.size[free].last(#3)}>=90
            復旧の条件式 {Template OS Linux:vm.memory.size[free].last(#3)}<80

<ディスク使用率>
    item  : vfs.fs.size[/,pused]
    triger: {Template OS Linux:vfs.fs.size[/,pused].last(0)}>80
```

## プロセス監視
##### sshd、zabbix-agent、ミドルなど
```
item  : proc.num[sshd] , proc.num[zabbix-agent] , proc.num[mysql] , proc.num[nginx]
triger: proc.num[sshd]
```
## ポート監視
##### sshd、zabbix-agent、ミドルなど
```
item  : net.tcp.listen[port]    (netstat -an)
        net.tcp.port[<ip>,port] (telnet localhost 80) ※外部指定ではなく、1サーバ内に複数インターフェース(IPアドレス)がある環境でどのインターフェースか指定する場合に使用
```

## サービス接続監視
```
item  : net.tcp.service[service,<ip>,<port>]
　　   （service：ssh, ntp, ldap, smtp, ftp, http, pop, nntp, imap, tcp, https, telnet）
       正常性判断。TCP/IPの階層モデルで言うと、net.tcp.portはトランスポート層（レイヤー4）、net.tcp.service、net.tcp.dnsはアプリケーション層（レイヤー5)でのチェック
```

## Web監視
```
・Webシナリオ監視
　　”監視サーバから”接続確認を行う。
　　複数ページを横断してアクセスしてチェック出来る。
　　認証が必要なサイトであっても、標準認証、または標準的なPOPによるチェックであれば認証をパスしてチェックが出来る。

・web.page.get[host,<path>,<port>]
・web.page.perf[host,<path>,<port>]
・web.page.regexp[host,<path>,<port>,<regexp>,<length>,<output>]
　　Webサイトへの接続チェックを行う。
　　シナリオ監視は行えないが、エージェントから直接httpサイトへチェックを行うことが出来る。
　　（DMZ内にあるWebサーバのサイトチェックを行う場合、監視サーバ<=>監視対象サーバ間でhttp(s)ポートを開けなくても良い）
```

## その他
##### ファイルが存在するか。しなかったらアラート
```
zabbix_agentd.conf/
AllowRoot=1          # セキュリティ上ダメなら https://tech-mmmm.blogspot.com/2018/03/zabbixallowroot1varlogmessages.html

zabbix_web/
item   : vfs.file.exists[/home/ec2-user/msp/check.txt]
triger : {Zabbix agent:vfs.file.exists[/home/ec2-user/msp/check.txt].last()}=0
```

##### logの中にerrorの文字が出てきたらアラート
```
zabbix_web/
item   : log[/var/log/zabbix/test.log]  ※type: Agent(active), data: log, application: none
triger : (({Zabbix agent:log[/var/log/zabbix/test.log].regexp(error)})<>0) →GUI作成
```

##### Dockerのversionを出力
```
zabbix_agentd.conf/
EnableRemoteCommands=1                       # コマンドの実行を許可（デフォルト: disabled）
UserParameter=docker.ver,/usr/bin/docker -v  # 実行するコマンド（キー,コマンド）

zabbix_web/
item   : docker.ver
```

##### 時刻同期できてるか
```
Linux/
まずは日本時間に設定  https://public-constructor.com/ec2-amazon-linux2-timezone/

zabbix_web/
item: {Template OS Linux:system.localtime.fuzzytime(30)}=0
      
# 確認は「=1」として同期してたらエラーを出す  # Server全てに関係するのでTemplate指定
```

##### Web外形監視
```
web_sg/
inbound: web側のsgでzabbixサーバーからの80アクセスを許可

zabbix_web/
web scenario: http://<web_ip:port>指定 
triger      : {Zabbix agent:web.test.fail[<Web_scenario_name>].last()}>0  -> 問題がな買ったら0が返ってくるので
```

##### MySQLレプリケーション監視
参考 https://blog.apar.jp/zabbix/3218/ ★
```
・監視項目をマスター/スレーブで決める
・エージェント用MySQLユーザー作成
・エージェントがログインするためのパスワードファイル作成
・agent.confファイル編集
・マスター/スレーブ/zabbix_serverのそれぞれで値が取れるか確認

zabbix_web/
item   : mysql.slave.status[Slave_IO_Running]
triger : {<Template_name>:mysql.slave.status[Slave_IO_Running].regexp(Yes)}=0
```




# Preference
![](markdown/images/2020-08-13-00-00-30.png)
![](markdown/images/2020-08-13-00-01-38.png)

# 課題
```
ネットワークディスカバリによるホストの自動登録
```

