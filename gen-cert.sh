#!/bin/bash -e
set -e
#------------------------------------------------------------------------------------------------
# functions
#------------------------------------------------------------------------------------------------

function get_certbot() {
  printf "Getting certbot docker image\n"
  docker pull certbot/certbot
}

function get_image_id() {
  printf "Saving docker image id\n"
  certbot_imageid=$(docker images | grep certbot | grep latest | awk '{print $3}')
}

function define_variables() {
  printf "Defining some variables\n"
  cert_folder=/tmp/letsencrypt
  cert_common_name=$domain_name
  cert_generation_email=$email
  domain_dns=$dns_name
}

function create_temp_folder() {
  printf "Creating temp folder\n"
  if [ ! -d "$cert_folder" ]; then
    mkdir $cert_folder
  fi
}

function execute_certbot() {
  printf "Running certbot\n"
  docker run -v $cert_folder:/etc/letsencrypt -it $certbot_imageid certonly -d $cert_common_name --manual --preferred-challenges dns -m $cert_generation_email --no-eff-email --agree-tos --manual-public-ip-logging-ok
}

function print_certs() {
  printf "### PRIVATE KEY..."
  cat $cert_folder/live/$cert_common_name/privkey.pem
  printf "### FULLCHAIN KEY..."
  cat $cert_folder/live/$cert_common_name/fullchain.pem
}

function add_https_flynn() {
  printf "Updating flynn route\n"
  flynn_route_id=$(flynn -a $app_name route | grep $domain_name | awk '{print $3}')
  if [ -z "$flynn_route_id" ]; then
    echo "Error. Can't determine route id."
    exit 1
  fi
  flynn -a $app_name route update $flynn_route_id --tls-cert $cert_folder/live/$cert_common_name-0001/fullchain.pem --tls-key $cert_folder/live/$cert_common_name-0001/privkey.pem
}
#------------------------------------------------------------------------------------------------
# main
#------------------------------------------------------------------------------------------------

if [ -z "$1" ]; then
  echo "Please provide an app name. Usage: ./gen-cert.sh my_app_name [domain_name] [email] [dns_name]"
  exit 1
fi

app_name=$1
domain_name=$app_name.${2:-example.com}
email=${3:-"your.email@example.com"}
dns_name=${4:-somednsserver.com}

echo "-------------------------------------------------------------------------------"
echo "Generating SSL certificates for app $app_name"
echo "-------------------------------------------------------------------------------"

get_certbot
get_image_id
define_variables
create_temp_folder
execute_certbot

#print_certs
add_https_flynn

echo "-------------------------------------------------------------------------------"
echo "SSL certs generated. Flynn routes updated successfully! Enjoy :)"
echo "-------------------------------------------------------------------------------"
