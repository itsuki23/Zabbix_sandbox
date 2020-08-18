# フロー
```
# 準備
　サービス停止
　設定ファイルのバックアップ

# アップデート
　Zabbixリポジトリ
　Zabbixソフトウェア群

# 後処理
　設定ファイル修正
　サービス起動
```

# バージョンアップ
```
sudo -Uvh  https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
yum clean all
yum check-update
sudo yum upgrade zabbix-server-mysql zabbix-web-mysql zabbix-web-japanese zabbix-agent
```

依存性で怒られる。php7.2以降が必要とのこと。
https://www.yamamanx.com/amazon-linux-wordpress-php-53-72/
```
yum repolist all
sudo amazon-linux-extras install php7.2
```
また怒られる。Refusiong because php7.2 could cause an invalid combination
https://forums.aws.amazon.com/thread.jspa?threadID=305528
```
sudo amazon-linux-extras list
sudo amazon-linux-extras disable php7...
sudo amazon-linux-extras enable php7.2

sudo amazon-linux-extras install php7.2
sudo yum install php php-mbstring
```
いざ...
```
sudo yum upgrade zabbix-server-mysql zabbix-web-mysql zabbix-web-japanese zabbix-agent

```


# Ref
[php バージョンアップ](https://qiita.com/longunder/items/26ae871558e78b64c2f0)
[php 依存関係mysql](https://www.sodo-shed.com/archives/12584)
[amzn2でRemi repository 使うにはまずEPEL有効に](https://qiita.com/charon/items/f890ddbb66aa24d9bc38)
[依存関係★](https://knowledge.sakura.ad.jp/21419/)
[違うレポジトリを見に行ってしまう](https://higherhope.net/?p=2731)
[zabbix バージョンアップ　ドキュメント](https://www.zabbix.com/documentation/2.2/jp/manual/installation/upgrade)
[zabbix バージョンアップ 参考1](https://qiita.com/spurheads/items/6d6da58b233557f9a3b2)
[zabbix バージョンアップ 参考2](https://higherhope.net/?p=31489)




