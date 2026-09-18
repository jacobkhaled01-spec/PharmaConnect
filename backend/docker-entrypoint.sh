#!/bin/sh
set -e

echo "=== بدء تشغيل خادم PharmaConnect على منصة Render السحابية ==="

# التأكد من وجود ملف قاعدة بيانات SQLite في حال تفعيلها
if [ "$DB_CONNECTION" = "sqlite" ] || [ -z "$DB_CONNECTION" ]; then
    echo "إعداد قاعدة بيانات SQLite..."
    mkdir -p /app/database
    touch /app/database/database.sqlite
    chmod 777 /app/database/database.sqlite
fi

# التحقق من مفتاح التطبيق APP_KEY
if [ -z "$APP_KEY" ]; then
    echo "توليد APP_KEY..."
    php artisan key:generate --force
fi

# تشغيل التهجير وبذر البيانات الأولية
echo "تشغيل Migrations و Seeders..."
php artisan migrate --force
php artisan db:seed --force

# تحسين الكاش للإنتاج السحابي
echo "تخزين المسارات والإعدادات في الكاش..."
php artisan config:clear
php artisan route:cache
php artisan view:cache

# تحديد المنفذ المعطى من Render
PORT=${PORT:-10000}
echo "🚀 السيرفر يعمل الآن بنجاح على المنفذ: $PORT"

exec php artisan serve --host=0.0.0.0 --port=$PORT
