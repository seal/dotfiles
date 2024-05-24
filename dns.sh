nmcli -g name,type connection  show  --active | awk -F: '/ethernet|wireless/ { print $1 }' | while read connection
do
  nmcli con mod "$connection" ipv6.ignore-auto-dns yes
  nmcli con mod "$connection" ipv4.ignore-auto-dns yes
  nmcli con mod "$connection" ipv4.dns "1.1.1.1 1.0.0.1"
  nmcli con mod "$connection" ipv6.dns "2606:4700:4700::1111 2606:4700:4700::1001"
  nmcli con down "$connection" && nmcli con up "$connection"
done
