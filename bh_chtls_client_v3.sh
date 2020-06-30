remote_interface="ens2f4"
ip="102.1.7.149"
server_machine="t6p3"
path_to_openssl="/root/compiled-openssl-1.1.1/bin/"
file_path="/DATA/1G_sample"

#Function to run openssl_s_time
openssl_time()
{
#	echo "inside is $i"
 $path_to_openssl./openssl s_time -connect $ip:88$1  -www $file_path -new  > /dev/null &
}

#Function to collect BW with cee tool
collect_BW_cee()
{
	echo "cee output for instance $1"
ssh $server_machine /root/t5tools/./cee.pl -i $remote_interface -ch 0 -c 32 > ./cee_output_temp.txt 

}

#Function to collect BW with vnstat tool
collect_BW_vnstat()
{
ssh $server_machine  vnstat -i $remote_interface -tr 30 > vnstat_output.txt
}


#Function to collect cpu
collect_cpu()
{
ssh $server_machine mpstat 3 10 > ./server_cpustat.txt &
mpstat 3 10 > ./client_cpustat.txt & 
}

#Function to extract cpu util from collected data
get_cpu_util()
{
	        echo -n '----Server %CPU----:  ' | tee -a ./cee_output.txt
                sleep 1
                echo " 100 - $( cat ./server_cpustat.txt | grep Average | awk '{print $12}' )" | bc | tee -a ./cee_output.txt
                sleep 2
                echo -n '----Client %CPU----:  ' | tee -a ./cee_output.txt
                echo " 100 - $( cat ./client_cpustat.txt | grep Average | awk '{print $12}' )" | bc | tee -a ./cee_output.txt
		sleep 10
}

#Function to fetch BW from data
fetch_BW()
{
BW=$(cat vnstat_output.txt  | grep tx | awk '{print $2}')
par=$(cat vnstat_output.txt  | grep tx | awk '{print $3}')
echo "-------Total BW----:  $BW $par" | tee -a ./cee_output.txt
 #cat ./cee_output_temp.txt |grep CH0 | awk '{print $3}' >> ./cee_output.txt
#cat vnstat_output.txt  | grep tx | awk '{print $2}' | tee -a ./cee_output.txt

}




#main
rm -rf server_cpustat.txt vnstat_output.txt cee_output.txt
killall -q openssl
#no. of instances to run
for j in 1 8 16 32 64 128 256 450 
do
echo "Waiting for openssl to complete"
wait
	echo "###################instance $j#########################################" | tee -a  ./cee_output.txt
	for (( i=0; i < $j ; i++ ))  
do
	a=$i
	((a++))
#echo "Running openssl_s_time of instance $a" #Uncomment to check openssl instances
openssl_time $i
done
collect_cpu
#collect_BW_cee
collect_BW_vnstat
get_cpu_util
fetch_BW
	echo "###################instance $j end####################################" | tee -a ./cee_output.txt
done
