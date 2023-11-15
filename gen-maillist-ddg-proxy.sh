#! /bin/bash

### Resume: Catches mail addresses using DuckDuckGo and a list of FQDNs.
###         Uses a third-party proxy service and simulates a broser access to avoid DDG's web scrapping defenses.

###
### How to use:
###
### $ sh catchmail.sh <domainlist>
###

# Creates a text file to store addresses
addlist="addlist-$(date +%Y%m%d-%H%M%S)"

# Sets a list of proxies - Instantproxies - Control panel: http://admin.instantproxies.com/login.php?user=88650&pass=CQK9gqnp4NNy
# proxy_list=("108.62.70.16:3128" "89.32.67.98:3128" "89.32.69.63:3128" "89.32.67.249:3128" "198.55.109.239:3128" "198.55.109.239:3128" "89.32.69.22:3128" "89.32.69.168:3128" "198.55.109.127:3128" "89.32.69.26:3128" "108.62.70.141:3128")

# Sets a list of time fractions
sleep_list=(12 15 6 8 11 16 14 13 7 12 9 10)

# While there are unprocessed domains, do...
while read fqdn domainlist; do
	
    # What is the next FQDN?
	echo "FQDN: $fqdn"

    # Sets a regular expression for catch emails
    regex_email="(^|[ \t]|[:;.]|[\'\"\`\'])([A-Za-z0-9])+([_.-]?[A-Za-z0-9])*([ \t ])*(@|at|%40|%20)([ \t ])*(<b>)?""$fqdn"

    # Sets a initial search path
    search_path="https://duckduckgo.com/lite/?q=%22$fqdn%22"

    # Sets a random proxy
    # export http_proxy="http://${proxy_list[$(($RANDOM %10))]}"; echo "IP: $http_proxy"

    while [ $(echo "$search_path" | wc -c) -ne 23 ]; do

        # Displays the search path
        echo "$search_path"

        # Dumps the first page content
	    lynx -source "$search_path" | cat > content.tmp

        # Catches e-mail addresses
	    cat content.tmp | grep -Eio "$regex_email" | sort -u >> $addlist;

        # Sets the next search path
        search_path="https://duckduckgo.com"$(cat content.tmp | grep -i --max-count=1 "<a rel=\"next\" href=\"/lite/?q=%22""$fqdn" | grep -Eio "/lite[/a-zA-Z0-9=%.;&?_-]+")

        # Take a time!
        sleep ${sleep_list[$(($RANDOM %12))]}s

    done

done < $1

# Removes temporary files
rm content.tmp

# Finishes the work
echo "Its done! The script catched $(cat $addlist | wc -l) emails. File: $addlist"


