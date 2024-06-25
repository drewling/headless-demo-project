#!/usr/bin/env sh

# Wait until MySQL is ready
until mysql -h db-service -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SELECT 1;" 
do
  echo "Waiting for MySQL..."
  sleep 1
done

# Check if WP is installed
if wp core is-installed
then
    echo "WordPress is already installed, exiting."
    exit
fi

# Downloading and installing WP
wp core download --force

[ -f wp-config.php ] || wp config create \
    --dbhost="$WORDPRESS_DB_HOST" \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD" \
    --dbprefix="$WORDPRESS_DB_PREFIX"

wp core install \
    --url="$WORDPRESS_URL" \
    --title="$WORDPRESS_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_USER" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
    --skip-email

# Manage required plugins
wp plugin delete akismet hello

wp plugin install --activate --force \
    advanced-custom-fields \
    wordpress-seo \

# Theme settings
wp theme activate $THEME_NAME
wp theme delete twentytwenty twentytwentyone twentytwentytwo twentytwentythree twentytwentyfour

wp option update siteurl "$WORDPRESS_URL"
wp option update home "$WORDPRESS_HOME"
wp rewrite structure "$WORDPRESS_PERMALINK_STRUCTURE"
wp rewrite flush

echo "Install done. You can now log into WordPress at: $WORDPRESS_URL/wp-admin ($WORDPRESS_ADMIN_USER/$WORDPRESS_ADMIN_PASSWORD)"
