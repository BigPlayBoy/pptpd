
SUBNET=$1

if [ -z "${SUBNET}" ]; then 
  SUBNET=192.168.0
fi

yum remove -y pptpd ppp
iptables --flush POSTROUTING --table nat
rm -rf /etc/pptpd.conf
rm -rf /etc/ppp

wget https://github.com/wendyeq/pptpd/raw/master/pptpd-1.3.4-2.el6.i686.rpm

yum install -y ppp
rpm -ivh pptpd-1.3.4-2.el6.i686.rpm

echo "localip ${SUBNET}.1" >> /etc/pptpd.conf
echo "remoteip ${SUBNET}.234-238,${SUBNET}.245" >> /etc/pptpd.conf

echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd
echo "ms-dns 8.8.4.4" >> /etc/ppp/options.pptpd
pass=`openssl rand 6 -base64`
if [ "$1" != "" ]
then pass=$1
fi
echo "vpn pptpd ${pass} *" >> /etc/ppp/chap-secrets

sed -i 's/net.ipv4.ip_forward = 0/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
sed -i 's/net.ipv4.tcp_syncookies = 1/#net.ipv4.tcp_syncookies = 1/' /etc/sysctl.conf
sysctl -p
iptables -t nat -A POSTROUTING -s ${SUBNET}.0/24 -o eth0 -j MASQUERADE
/etc/init.d/iptables save

chkconfig pptpd on
service iptables start
service pptpd start
