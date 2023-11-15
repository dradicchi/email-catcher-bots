#! /bin/sh

# Resume: Generates mailing from a list of domains, using the Google Search.
#         Introduces a wait to avoid Google'a DDOS defenses.


# While there are unprocessed domains, do...
while read domain

do
	# What is the domain of time?
	echo "Domain: $domain"
	
	# Sets an initial page for a search
	search_page=0

	# Generates a initial search path
	search_path='https://www.google.com.br/search?hl=pt-BR&num=100&start='"$search_page"'&q="'"$domain"'"''&gws_rd=ssl&filter=0'

	# Defines a regular expression for locate emails
	regex_mail='(^|[ \t]|[:;.])([A-Za-z0-9])+([_.-]?[A-Za-z0-9])*([ \t ])*(@|at|%40|%20)([ \t ])*'"$domain""([ \t]|[:;,]|[.][ \t]|[a-zA-z0-9]|[\'\"\`\']|[.]?$)"

	# Defines regular expressions to identify pages
	regex_pages_1='(Anterior((   )[0-9])+|([0-9](   ))+Mais)'
	regex_pages_2='(((   )[0-9])+|([0-9](   ))+)'
	
	# Counts the number of pages
	counter_pages=$(links -dump "$search_path" | grep -Eio "$regex_pages_1" | grep -Eio "$regex_pages_2" | wc -w)

	# If "counter_pages == 0", increases "counter_pages" on "1"
	if [ $counter_pages = 0 ]; then counter_pages=$(($counter_pages + 1)); fi; echo "Search returned $counter_pages pages."
	
	# For each page, does...
	for counter in $(seq 1 1 $counter_pages)

	do
		
		# Locates and saves valid emails on "maillist" file
		links -dump "$search_path" | grep -Pio "$regex_mail" | sort -u >> maillist; echo $search_path
		
		# Updates $search_page and...
		search_page=$(($search_page + 100))

		# ...updates the search path
		search_path='http://www.google.com.br/search?hl=pt-BR&num=100&start='"$search_page"'&q="'"$domain"'"''&gws_rd=ssl&filter=0'
		
		# Calms the Google!
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
		
done < domainlist

echo "Its done!"


