# Cloud Watch


# EC2
メトリクス　https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html

Diskサイズとともに決まることが多い
  IOPS（Input Output Per Second)
  スループット　１秒間のデータ転送量（MB/秒）
```
0: 正常  1: 異常


CPUUtilization [%]
現在インスタンス上で使用されているものの比率。アプリケーションを実行するのに必要な処理能力を特定可能
------------------------------------------------------------------------------------------

Disk [ReadOps[カウント], kWriteOps[カウント], ReadBytes[バイト], WriteBytes[バイト] ]
指定された期間にインスタンスで利用できるすべてのインスタンスストアボリュームでの、完了した [ 読み取り, 書き込み ]
インスタンスで利用できるすべてのインスタンスストアボリュームから [ 読み取られた, 書き込まれた ] バイト数 -> アプリケーション速度　が分かる -> 値が高いならキャッシュレイヤー追加を検討
------------------------------------------------------------------------------------------

Network [ In[バイト], out[バイト], PacketsIn[カウント], PacketsOut[カウント] ] 
すべてのネットワークインターフェイスでの、このインスタンスによって [ 受信, 送信 ] されたバイトの数
すべてのネットワークインターフェイスでの、このインスタンスによって [ 受信された, 送信された ] パケットの数
------------------------------------------------------------------------------------------

MetadataNoToken	[カウント]
トークンを使用しないメソッドを使用してインスタンスメタデータサービスに正常にアクセスした回数。
------------------------------------------------------------------------------------------

CPUCredit
今回略
------------------------------------------------------------------------------------------

EBS[ ReadOps, WriteOps, ReadBytes ]
指定された期間にインスタンスに接続されたすべての Amazon EBS ボリュームからの
 ReadOps    　[個]: 完了した読み込みオペレーション    Case 5min Monitoring -> {I/O 操作回数} / min = value / 300
 WriteOps   　[個]: 完了した書き込み操作
 ReadBytes[バイト]: 読み取られたバイト数

------------------------------------------------------------------------------------------
StatusCheck　[Failed(両方), Failed_Instance, Failed_System]	(単位: カウント)
インスタンスが過去 1 分間にステータスチェックに合格したかどうか
★初動チェック　AWS側の問題か？(system)  インスタンス内の問題か？(instance)
```

# RDS
https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/MonitoringOverview.html

# ALB
https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html






# Memo
```
単位
%　　　　 ９０％でアラート
カウント　異常性でアラート
バイト　　異常性でアラート　ベースライン
```



