#!/usr/bin/env bash

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -f <file>    Specify the input file containing domains"
  echo "  -h, --help   Show this help message"
  echo "Examples:"
  echo "  $0 -f <input.file>   Extract domains from <input.file>"
}

if [ "$#" -eq 0 ]; then
  show_help
  exit 0
fi

while getopts "f:h" opt; do
  case $opt in
    f)
      input_file="$OPTARG"
      ;;
    h)
      show_help
      exit 0
      ;;
    \?)
      echo "Option not available: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [ -z "$input_file" ]; then
  echo "Error: Please use -f option with <input.file>." >&2
  exit 1
fi

if [ ! -f "$input_file" ]; then
  echo "Error: File not found: $input_file" >&2
  exit 1
fi

# Use grep and cut to extract domain names and store them in an array
mapfile -t of_domain_names < <(grep -o 'of domain \([^ ]\+\)' "$input_file" | cut -d ' ' -f 3)
mapfile -t of_the_domain_names < <(grep -oP 'of the domain \K[^<]+' "$input_file")

domain_names=("${of_domain_names[@]}" "${of_the_domain_names[@]}")

# Iterate through the domain names and run whois for each
printf "%-2s %-30s %-12s %-25s %s\n" "SN" "Domain Name" "Expiry Date" "Registrar" "Status"
SN=1
for domain in "${domain_names[@]}"; do
  domain="${domain#"${domain%%[![:space:]]*}"}"
  domain="${domain%"${domain##*[![:space:]]}"}"

  domain_info=$(whois "$domain" 2>/dev/null)
  domain_expiry=$(grep "Registry Expiry Date:" <<< "$domain_info" | awk '{sub("Registry Expiry Date: ", ""); print}')
  domain_expiry="${domain_expiry%%T*}" 
  domain_expiry="${domain_expiry#"${domain_expiry%%[![:space:]]*}"}"
  domain_expiry="${domain_expiry%"${domain_expiry##*[![:space:]]}"}"
  
  domain_status=$(grep "Domain Status: " <<< "$domain_info" | awk '{sub("Domain Status: ", ""); print}' | awk '{print $1}' | sort | uniq | tr '\n' ', ')
  domain_status=${domain_status%,}
  domain_status="${domain_status#"${domain_status%%[![:space:]]*}"}"
  domain_status="${domain_status%"${domain_status##*[![:space:]]}"}"

  domain_registrar=$(grep "Registrar: " <<< "$domain_info" | awk '{sub("Registrar: ", ""); print}' | head -n 1 | cut -c -25)
  domain_registrar="${domain_registrar#"${domain_registrar%%[![:space:]]*}"}"
  domain_registrar="${domain_registrar%"${domain_registar##*[![:space:]]}"}"


  printf "%-2s %-30s %-12s %-25s %s\n" "$SN" "$domain" "$domain_expiry" "$domain_registrar" "$domain_status"
 SN=$((SN + 1)) 
done

