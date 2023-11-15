#! /bin/bash


### Resume: Catches mail addresses using Google Search and a list of FQDNs.
###         Uses a third-party proxy service and simulates a broser access to avoid Google's web scrapping defenses.

###
### How to use:
###
### $ sh catchmail.sh <domain-list>
###


# Creates a text file to store addresses
addlist="addlist-$(date +%Y%m%d-%H%M%S)"

# Sets a match count to "$search_path"
# count_matches=0

# Sets a initial "user_agent"
user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36"

# Sets a initial "ip_proxy" 
ip_proxy="getmore:UKuf2pkD@181.215.14.52:60099"


# While there are unprocessed domains, do...
while read domain domainlist

do
	# What is the next domain?
	echo "Searching $domain ..."
	
	# Generates a initial search path
	search_page=0
	search_path='http://www.google.com.br/search?hl=pt-BR&filter=0&num=100&start='"$search_page"'&q="'"$domain"'"'

	# Defines a regular expression for catch emails
	# regex_mail='(^|[ \t]|[:;.])([A-Za-z0-9])+([_.-]?[A-Za-z0-9])*(@|at|%40)'"$domain"'([ \t]|[:;,]|[.][ \t]|[.]?$)'
    regex_mail='(^|[ \t]|[:;.])([A-Za-z0-9])+([_.-]?[A-Za-z0-9])*([ \t ])*(@|at|%40|%20)([ \t ])*'"$domain""([ \t]|[:;,]|[.][ \t]|[a-zA-z0-9]|[\'\"\`\']|[.]?$)"
    # regex_mail='(^|[ \t]|[:;.])([A-Za-z0-9])+([_.-]?[A-Za-z0-9])*([ \t ])*(@|at|%40|%20)([ \t ])*'"$domain"'([ \t]|[:;,]|[.][ \t]|[a-zA-z0-9]|[.]?$)'

	# Defines regular expressions to scrap the Google Search page navigation
	regex_pages_1='(Anterior([ \t][0-9])+|([0-9][ \t])+Mais)'
	regex_pages_2='(([ \t][0-9])+|([0-9][ \t])+)'
	
	# Counts pages
    # If "counter_pages == 0", increases "counter_pages" on "1" to prevent the script breaking
	counter_pages=$(links -http.fake-user-agent "$user_agent" -http-proxy "$ip_proxy" -dump "$search_path" | grep -Eio "$regex_pages_1" | grep -Eio "$regex_pages_2" | wc -w)
	if [ $counter_pages = 0 ]; then counter_pages=$(($counter_pages + 1)); fi; echo "Search returned $counter_pages pages."
	
	# For each page, does...
	for counter in $(seq 1 1 $counter_pages)

	do

        # Calms the Google!
        # Selects a browser user agent
 		case $(($RANDOM %3)) in

		 	0) user_agent="Mozilla/5.0 (Windows NT 10.0; WOW64; rv:52.0) Gecko/20100101 Firefox/52.0";; # Firefox 52 on Windows 10
		 	1) user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36";; # Chrome 55 on Windows 10
		 	2) user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36";; # Chrome 58 on Windows 10
		 	
		esac; # echo "User agent:  $user_agent"

        # Calms the Google!
        # Selects a IP of Proxy pool
 		case $(($RANDOM %5)) in
        
			# SEOBlazing - Dedicated
			0) ip_proxy="d6884a8638:Gb8Onf7T@179.61.214.222:4444";;
			1) ip_proxy="d6884a8638:Gb8Onf7T@179.61.247.93:4444";;
			2) ip_proxy="d6884a8638:Gb8Onf7T@181.215.16.45:4444";;	### tested
			3) ip_proxy="d6884a8638:Gb8Onf7T@191.96.132.66:4444";;
			4) ip_proxy="d6884a8638:Gb8Onf7T@191.96.63.60:4444";;
			
			# Bonanza - Dedicated
			#0) ip_proxy="getmore:UKuf2pkD@179.61.213.117:60099";;	### tested
			#1) ip_proxy="getmore:UKuf2pkD@181.215.14.52:60099";;	### tested

		esac; # echo "Proxy: $ip_proxy"             
		
		# Finds and catches e-mail addresses on the search results
        # links -dump "$search_path" | grep -Eio "$regex_mail" | sort -u >> $addlist; echo "URL: $search_path"
		links -http.fake-user-agent "$user_agent" -http-proxy "$ip_proxy" -dump "$search_path" | grep -Eio "$regex_mail" #| sort -u >> $addlist; echo "URL: $search_path"
		
		# Counts the matches for "$search_path"
		# echo "Matches: $count_matches"
		# count_matches=$(($(cat $addlist | wc -l) - $count_matches )); echo "Matches: $count_matches"
		
		# Updates the search path
		search_page=$(($search_page + 100))
		search_path='http://www.google.com.br/search?hl=pt-BR&filter=0&num=100&start='"$search_page"'&q="'"$domain"'"'
		
		# Calms the Google!
        # Takes a random break between searches
        # sleep 10s
		case $(($RANDOM %10)) in

			0) sleep 13s;;
			1) sleep 23s;;
			2) sleep 33s;;
			3) sleep 43s;;
			4) sleep 63s;;
			5) sleep 16s;;
			6) sleep 26s;;
			7) sleep 36s;;
			8) sleep 46s;;
			9) sleep 66s;;

		esac

	done
		
done < $1

# Finishes the work
echo "Its done! The script catched $(cat $addlist | wc -l) emails. File: $addlist"
