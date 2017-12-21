# flynn-ssl-cert

## Introduction
> Bash script that generates Let's Encrypt certificates and updates flynn routes automatically :)

## Quickstart
```bash
git clone git@github.com/flynn-ssl-cert.git
cd flynn-ssl-cert
chmod a+x ./gen-cert.sh
```
## Usage
```bash
./gen-cert.sh my_app_name [domain_name] [email] [dns_service_name]
```
> domain_name, email and dns_service_name are optional parameters. Make sure you change their default values before running the script.

## Assumptions
1. You have a valid domain name
2. You have access to a DNS service where your domain is hosted
3. You have docker installed and running
4. You have a flynn cluster up and running
5. You have the flynn CLI installed

## Useful links
https://flynn.io/

https://hub.docker.com/r/certbot/certbot/

https://www.docker.com/

https://letsencrypt.org/

## License
[MIT licensed](LICENSE)
