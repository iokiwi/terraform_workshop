# REPLACE This With Your Name
namespace = "default"

# Replace this with AWS Route53 Hosted Zone
# domain = "pstntfworkshop.xyz"
domain = "simonmerrick.com"

# Replace this with your email address
certbot_email = "first.last@trademe.co.nz"

# Replace this with your ip address in CIDR format E.g
# curl https://icanhazip.com
# 125.239.50.77
 cidr_whitelist = [ 
    "125.239.70.99/32",
    # "<your ip address here>/32"
]

######################### WARNING #############################
# OBVIOUSLY THIS IS NOT SECURE
# DO NOT STORE SECRETS IN PLAIN TEXT
# DO NOT USE THIS IN PRODUCTION OR EXPOSE TO INTERNET
# THIS REPOSITORY IS FOR LEARNING PURPOSES ONLY
###############################################################
wordpress_db_charset = "utf8mb4"
wordpress_db_host = "db"
wordpress_db_name = "wordpress"
wordpress_db_user = "wordpress"
wordpress_db_pass = "wordpress"
###############################################################
