#!/bin/bash
###############################################
# #
#   Black        0;30  #  Dark Gray     1;30 #
#   Red          0;31  #  Light Red     1;31 #
#   Green        0;32  #  Light Green   1;32 #
#   Brown/Orange 0;33  #  Yellow        1;33 #
#   Blue         0;34  #  Light Blue    1;34 #
#   Purple       0;35  #  Light Purple  1;35 #
#   Cyan         0;36  #  Light Cyan    1;36 #
#   Light Gray   0;37  #  White         1;37 #
# #
###############################################
RED='\033[1;31m'
NC='\033[0m' # No Color
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
pattern=$(ls -d */ | cut -d '/' -f1)

# Running the script only by root
[ "$EUID" != 0 ] && echo -e "${YELLOW}/!\ ${RED}You have to run this script with superuser ${YELLOW}/!\ ${NC}" && exit 1

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

echo -e "${GREEN}Sys check.....${NC}"
base=50
message="RAM: ${ram_use}/${total_ram} MB ${avg_cpu_use}"
ram_percent=$((ram_use_arr[2] * 100 / ram_use_arr[1]))
if [ $ram_percent -ge $base ]; then
    # notify-send "RAM: ${ram_percent}% ${avg_cpu_use}" "$message"
    echo -e "BEFORE FREE RAM: ${YELLOW}${ram_use} ${NC}MiB/${BLUE}${total_ram}${NC} MiB (${RED}${ram_percent}%${NC}) ${BLUE}${avg_cpu_use}${NC}"
    # # clearing PageCache
    # sudo sysctl -w vm.drop_caches=1
    # # clearing dentries and Inodes
    # sudo sysctl -w vm.drop_caches=2
    # # clearing PageCache, dentries and Inodes
    sudo sysctl -w vm.drop_caches=3 2>&1 >/dev/null
    sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches 2>&1 >/dev/null
    # sudo swapoff -a && sudo swapon -a
    ram_use=$(free -m)
    IFS=$'\n' read -rd '' -a ram_use_arr <<<"$ram_use"
    ram_use="${ram_use_arr[1]}"
    ram_use=$(echo "$ram_use" | tr -s " ")
    IFS=' ' read -ra ram_use_arr <<<"$ram_use"
    total_ram="${ram_use_arr[1]}"
    ram_use="${ram_use_arr[2]}"
    ram_percent=$((ram_use_arr[2] * 100 / ram_use_arr[1]))
    echo -e "AFTER FREE RAM: ${YELLOW}${ram_use} ${NC}MiB/${BLUE}${total_ram}${NC} MiB (${RED}${ram_percent}%${NC}) ${BLUE}${avg_cpu_use}${NC}"
else
    echo -e "FREE RAM: ${GREEN}${ram_use} ${NC}MiB/${BLUE}${total_ram}${NC} MiB (${GREEN}${ram_percent}%${NC}) ${BLUE}${avg_cpu_use}${NC}"
    echo -e "${GREEN}All Good...${NC}"
fi