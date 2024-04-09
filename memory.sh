# Get cpu usage of last minitue
avg_cpu_use=$(uptime)
IFS=',' read -ra avg_cpu_use_arr <<<"$avg_cpu_use"
avg_cpu_use=""

for i in "${avg_cpu_use_arr[@]}"; do
    :
    if [[ $i == *"load average"* ]]; then
        avg_cpu_use=$i
        break
    fi
done

avg_cpu_use=$(echo ${avg_cpu_use:16}) # Remove "  load average: "

if [[ -z "${avg_cpu_use// /}" ]]; then
    avg_cpu_use="CPU: N/A%"
    exit -1
else
    avg_cpu_use="CPU: ${avg_cpu_use}%"
fi

# Get RAM usage
ram_use=$(free -m)
IFS=$'\n' read -rd '' -a ram_use_arr <<<"$ram_use"
ram_use="${ram_use_arr[1]}"
ram_use=$(echo "$ram_use" | tr -s " ")
IFS=' ' read -ra ram_use_arr <<<"$ram_use"
total_ram="${ram_use_arr[1]}"
ram_use="${ram_use_arr[2]}"
ram_use="RAM: ${ram_use}/${total_ram} MB"

echo "Sys check....."
base=50
message="RAM: ${ram_use}/${total_ram} MB ${avg_cpu_use}"
ram_percent=$((ram_use_arr[2] * 100 / ram_use_arr[1]))
if [ $ram_percent -ge $base ]; then
    notify-send "RAM: ${ram_percent}% ${avg_cpu_use}" "$message"
    free -h
    # # clearing PageCache
    # sudo sysctl -w vm.drop_caches=1
    # # clearing dentries and Inodes
    # sudo sysctl -w vm.drop_caches=2
    # # clearing PageCache, dentries and Inodes
    sudo sysctl -w vm.drop_caches=3
    sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
    # sudo swapoff -a && sudo swapon -a
    free -h
else
    echo "All Good..."
fi