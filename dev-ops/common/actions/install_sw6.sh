#!/usr/bin/env bash 

php dev-ops/generate_ssl.php

composer install --no-interaction --optimize-autoloader --no-suggest --no-scripts 

mysql -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' -e "DROP DATABASE IF EXISTS \`__DB_NAME__\`"
mysql -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' -e "CREATE DATABASE \`__DB_NAME__\` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci"
mysql -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' __DB_NAME__ < vendor/shopware/platform/src/Core/schema.sql

rm -rf var/cache 

php bin/console database:migrate --all Shopware\\
php bin/console database:migrate-destructive --all Shopware\\

php bin/console scheduled-task:register 

php bin/console plugin:refresh

php bin/console user:create admin --password=shopware

php bin/console sales-channel:create:storefront --url='__APP_URL__' 

# phpunit db
mysql -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' -e "DROP DATABASE IF EXISTS \`__DB_NAME___test\`"
mysql -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' -e "CREATE DATABASE \`__DB_NAME___test\` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci"
mysqldump '__DB_NAME__' -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' | mysql '__DB_NAME___test' -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__'

# e2e
mysql -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' -e "DROP DATABASE IF EXISTS \`__DB_NAME___e2e\`"
mysql -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' -e "CREATE DATABASE \`__DB_NAME___e2e\` DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_unicode_ci"
mysqldump '__DB_NAME__' -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' | mysql '__DB_NAME___e2e' -u '__DB_USER__' -p'__DB_PASSWORD__' -h '__DB_HOST__' --port='__DB_PORT__' 

APP_ENV=prod bin/console framework:demodata
APP_ENV=prod bin/console dbal:refresh:index 

rm -rf var/cache 

npm clean-install --prefix vendor/shopware/platform/src/Administration/Resources/administration/ 

php bin/console administration:dump:bundles
PROJECT_ROOT=__PROJECT_ROOT__ npm run --prefix vendor/shopware/platform/src/Administration/Resources/administration/ build
php bin/console assets:install 

npm --prefix vendor/shopware/platform/src/Storefront/Resources/ install

PROJECT_ROOT=__PROJECT_ROOT__/  npm --prefix vendor/shopware/platform/src/Storefront/Resources/ run production
