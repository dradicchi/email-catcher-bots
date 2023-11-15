#! /bin/bash

### Resume: Catches mail addresses using Google and a list of FQDNs.
###         Uses Instantproxies proxy service and simulates a broser access to avoid Google's web scrapping defenses.

###
### How to use:
###
### $ sh catchmail.sh <domainlist>
###

# Creates a text file to store addresses
addlist="addlist-$(date +%Y%m%d-%H%M%S)"

# Sets a list of proxies - Instantproxies - Control panel: http://admin.instantproxies.com/login.php?user=88650&pass=CQK9gqnp4NNy
proxy_list=("108.62.70.16:3128" "89.32.67.98:3128" "89.32.69.63:3128" "89.32.67.249:3128" "198.55.109.239:3128" "198.55.109.239:3128" "89.32.69.22:3128" "89.32.69.168:3128" "198.55.109.127:3128" "89.32.69.26:3128" "108.62.70.141:3128")

# Sets a list of time fractions
sleep_list=(34 45 29 31 46 51 29 37 27 42 39 41)

# While there are unprocessed domains, do...
while read fqdn domainlist; do
	
    # What is the next FQDN?
	echo "FQDN: $fqdn"

    # Sets a regular expression for catch emails
    regex_email="(^|[ \t]|[:;.]|[\'\"\`\'])([A-Za-z0-9])+([_.-]?[A-Za-z0-9])*([ \t ])*(@|at|%40|%20)([ \t ])*(<b>)?""$fqdn"

	# Sets a random proxy
    export http_proxy="http://${proxy_list[$(($RANDOM %10))]}"; echo "IP: $http_proxy"

    # Sets a initial search path
    search_path="http://www.google.com.br/search?q=%22$fqdn%22&filter=0"; echo "$search_path"

    # Dumps the first page content
	lynx -source "$search_path" | cat > content-google.tmp

    # Counts number of pages
    pages=$(cat content-google.tmp | grep -io "</td><td><a href=\"/search?q=%22" | wc -l); echo "Pages: $pages"

    # Take a time!
    sleep ${sleep_list[$(($RANDOM %12))]}s

	# For each page, does...
	for page in $(seq 1 1 $pages); do
		
        # Catches e-mail addresses
	    cat content-google.tmp | grep -Eio "$regex_email" | sort -u >> $addlist;

        # Sets the next search path
        search_path="http://www.google.com.br"$(cat content-google.tmp | pega o numero | grep -Eio "/lite[/a-zA-Z0-9=%.;&?_-]+")

        # Dumps the next page content
	    lynx -source "$search_path" | cat > content-google.tmp

        # Take a time!
        sleep ${sleep_list[$(($RANDOM %12))]}s

    done

done < $1

# Removes temporary files
rm content-google.tmp

# Finishes the work
echo "Its done! The script catched $(cat $addlist | wc -l) emails. File: $addlist"


