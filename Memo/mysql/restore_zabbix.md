# 構成
- EC2_01: zabbix-server
- EC2_02: zabbix-db_master
- EC2_03: zabbix-db_slave
- EC2_04: web-server
<br>
- EC2_05: zabbix-server/ zabbix-db ※リストア

```
同じバージョンのZabbixを設定。DBのバックアップを使ってリストア
ブラウザからEC2_01と同様の設定が反映されているか確認
```

# バックアップ
<EC2_02>
```
★ DBをロックさせないオプション: --single-transaction

$ mysqldump -u root -p -h localhost--single-transaction --databases zabbix > ./mysqldump_zabbix_$(date +"%Y%m%d").sql
　( zip mysqldump_zabbix_20200817.sql.zip mysqldump_zabbix_20200817.sql ) -> 今回は圧縮しないでそのままmysql経由で転送する
```

# リストア
<EC2_05>
```
# Zabbixインストール
# mysqlにZabbixユーザー作成。どこからでも接続できるように@%とする
```

<EC2_02>
```
$ mysql -u zabbix -p -h <Restore先のIP> -P 3306 < ./mysqldump_zabbix_20200817.sql
```

<EC2_05>
```
テーブル確認
httpd, zabbix-server, zabbix-agentを起動してブラウザからリストアチェック
```

# 履歴の差分もリストアしたDBに反映させるなら…

- バイナリログからsqlファイル作成
```
mysqlbinlog /var/lib/mysql-bin.000016 > /logs/allbinlog.sql
```

- バイナリログからデータを復元
```
--------------------------------------------------------------------------------------
MySQLサーバーで実行するバイナリログが複数ある場合、サーバーへ単一接続してすべてを処理。

mysqlbinlog mysql_bin.000001 | mysql -u root -ppassword database_name
mysqlbinlog mysql_bin.000002 | mysql -u root -ppassword database_name

または
mysqlbinlog mysql_bin.000001 mysql_bin.000002 | mysql -u root -ppassword database_name

--------------------------------------------------------------------------------------
時間に基づいてデータを復元

$ mysqlbinlog --start-datetime="2005-04-20 10:01:00" \
  --stop-datetime="2005-04-20 9:59:59" mysql_bin.000001 \
  | mysql -u root -ppassword database_name

--------------------------------------------------------------------------------------
位置に基づいてデータを復元

$ mysqlbinlog --start-position=368315 \
  --stop-position=368312 mysql_bin.000001 \
  | mysql -u root -ppassword database_name

--------------------------------------------------------------------------------------
```

# Ref
https://tech-mmmm.blogspot.com/2017/06/zabbixmysqldb.html 