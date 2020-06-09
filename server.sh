#cd to /mnt/git-openssl-chtls-16/bin or openssl install path
for (( i=0; i <=7 ; i++ ))
do
	echo $i

           ./openssl s_server -key /root/server.key -cert /root/server.crt -accept 102.1.7.149:88${i} -cipher AES128-GCM-SHA256 -WWW -4  -tls1_2 &
done

