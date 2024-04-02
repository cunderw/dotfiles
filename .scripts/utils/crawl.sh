#!/bin/bash

# Check if a URL was provided
if [ -z "$1" ]; then
	echo "Usage: $0 <URL>"
	exit 1
fi

# The website to crawl, provided as a parameter
ROOT_URL="$1"

# Function to get the HTTP status code of a URL
# $1: URL to check
get_http_status() {
	local url="$1"
	curl -o /dev/null -s -w "%{http_code}" "$url"
}

# Function to fetch and parse links from a given URL
# $1: URL to fetch
fetch_links() {
	local url="$1"

	# Fetch content from the URL and parse out links
	curl -s "$url" |
		grep -o 'href="[^"]*' | sed 's/href="//' |
		sed -e "s|^//|$ROOT_URL/|" -e "s|^/|$ROOT_URL/|" -e "s|^#.*$||" |
		sort -u
}

# Function to add a trailing slash to a URL if it doesn't already have one
# $1: URL to modify
add_trailing_slash() {
	local var="$1"
	if [[ "${var}" != */ ]]; then
		var="${var}/"
	fi
	echo -n "$var"
}

# Function to parse a URL and extract the domain
# $1: URL to parse
parse_url() {
	local url="$1"
	local domain
	# Extract the protocol
	proto="${url%%://*}"
	# If the protocol is not http or https, then it's not a URL
	if [[ "$proto" != "http" && "$proto" != "https" ]]; then
		return 1
	fi
	# Remove the protocol from the URL
	url="${url#*://}"
	# Extract the domain
	domain="${url%%/*}"
	echo "$domain"
}

# Recursive function to crawl a URL
# $1: URL to crawl
# visited: Globally tracks visited URLs to prevent infinite loops
crawl() {
	local url="$1"

	# Normalize the URL by adding a trailing slash if it doesn't exist
	url=$(add_trailing_slash "$url")

	# Extract the domain from the URL
	url_domain=$(parse_url "$url")

	# Check if the URL's domain matches the root URL's domain
	if [[ "$url_domain" != "$ROOT_DOMAIN" ]]; then
		return
	fi

	# Check if the URL has already been visited
	if [[ ! " ${visited[@]} " =~ " ${url} " ]]; then
		# Mark this URL as visited
		visited+=("$url")

		# Check HTTP status code before fetching content
		status_code=$(get_http_status "$url")

		# Print the URL and its HTTP status code
		echo "$url, $status_code"

		# Fetch links from the current URL
		links=$(fetch_links "$url")

		for link in $links; do
			# Normalize the link by adding a trailing slash if it doesn't exist
			link=$(add_trailing_slash "$link")

			# Recursively crawl each link found
			crawl "$link"
		done
	fi
}

# Initialize visited array
declare -a visited

# Extract the domain from the root URL
ROOT_DOMAIN=$(parse_url "$ROOT_URL")

# Start crawling from the provided URL
crawl "$ROOT_URL"
