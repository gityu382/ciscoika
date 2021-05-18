#! /bin/sh

# 初期update
yum -y update

# Install squid
yum install -y \
  squid

systemctl enable squid
systemctl start squid
firewall-cmd --permanent --add-port=3128/tcp
firewall-cmd --reload

# Squid プロキシ ログを設定
sed -i -e '$a \n# アクセスログ設定\nlogformat access_format %ts%03tu %<tt %>a %>p %>st %<A %<st %<la %<lp %la %lp %un %ru\naccess_log syslog:user.6 access_format' /etc/squid/squid.conf

# Squid サーバのsyslog サービスを設定します
sed -i -e '$a \n# Audit Log Facility BEGIN\nfilter bs_filter { filter(f_user) and level(info) };\ndestination udp_proxy { udp("10.1.100.181" port(514)); };\nlog {\nsource(s_all);\nfilter(bs_filter);\ndestination(udp_proxy);\n};\n# Audit Log Facility END' /etc/rsyslog.conf

# squid再起動
systemctl restart squid

# rsyslog再起動
systemctl restart rsyslog
