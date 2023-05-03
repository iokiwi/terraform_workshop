# A namespace to distinguish your resources in the account from others
# Your name or another memorable unique string would be an appropriate value
# https://${namespace}.example.com
# namespace = "default"

# Your email address to register with Letsencrypt/Certbot
# It's required to accept the TOS and get notifcations about certificate lifecycle events
# certbot_email = ""

# An IP address whitelist for initiall installation
# E.g. run curl https://icanhazip.com
# privileged_ip_address = ""

# The top level domain your namespace and instance will be launched under
domain = "tfworkshop.xyz"

############################### WARNING ###############################
# NOT SUITABLE FOR PRODUCTION USE. NEVER STORE SECRETS IN PLAINTEXT
# SECRETS MANAGEMENT IS NOT COVERED IN THIS LAB BUT MAY BE COVERED IN
# A FUTURE LAB
#######################################################################
wordpress_db_charset = "utf8mb4"
wordpress_db_host    = "db"
wordpress_db_name    = "wordpress"
wordpress_db_user    = "wordpress"
wordpress_db_pass    = "wordpress"
####################### END WARING ####################################
