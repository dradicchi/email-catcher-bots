#! /bin/sh

# Description: This script generates a email list from a list of domain names provided as input, using the Google Search.

# While there are unprocessed domains, do...
while read domain domainlist

do
	# What is the domain of time?
	echo $domain
	
	# Sets an initial page for a search
	search_page=0

	# Generates a initial search path
	search_path='http://www.google.com.br/search?hl=pt-BR&num=100&start='"$search_page"'&q="'"$domain"'"'

	# Defines a regular expression for locate emails
	regex_mail='(^|[ \t]|[:;.])([A-Za-z0-9])+([_.-]?[A-Za-z0-9])*(@|at|%40)'"$domain"'([ \t]|[:;,]|[.][ \t]|[.]?$)'

	# Defines regular expressions to identify pages
	regex_pages_1='(Anterior([ \t][0-9])+|([0-9][ \t])+Mais)'
	regex_pages_2='(([ \t][0-9])+|([0-9][ \t])+)'
	
	# Counting the number of pages
	counter_pages=$(links -dump "$search_path" | grep -Eio "$regex_pages_1" | grep -Eio "$regex_pages_2" | wc -w)

	# If "counter_pages == 0", increases "counter_pages" on "1"
	if [ $counter_pages = 0 ]; then counter_pages=$(($counter_pages + 1)); fi; echo $counter_pages
	
	# For each page, does...
	for counter in $(seq 1 1 $counter_pages)

	do
		
		# Locates and saves valid emails on "maillist" file
		links -dump "$search_path" | grep -Eio "$regex_mail" | sort -u | cat >> maillist-tmp; echo $search_path
		
		# Updates $search_page and...
		search_page=$(($search_page + 100))

		# ...updates the search path
		search_path='http://www.google.com.br/search?hl=pt-BR&num=100&start='"$search_page"'&q="'"$domain"'"'
		
		# Calms the Google!
		sleep 30s

	done
		
done < domainlist

# Defines a regular expression for locate clean e-mails.
regex='([A-Za-z0-9])+([_.-]?[A-Za-z0-9])*@([A-Za-z0-9])+([.-]?[A-Za-z0-9])*(.com|.net|.ind|.srv)(.br)?'

# Sanitize the addresses.
grep -Eio "$regex" maillist-tmp | sort -u >> maillist-final

# Removes TMP files.
rm maillist-tmp



