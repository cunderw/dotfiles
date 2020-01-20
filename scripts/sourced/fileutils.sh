shopt -s globstar
for t in **/*torrent; do mkdir -p "${t%.*}"; mv "$t" "${t%.*}"; done
