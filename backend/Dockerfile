# PharmaConnect Backend - Production Dockerfile for Free Cloud Hosting (Render / Koyeb / Fly)
FROM php:8.2-cli-alpine

# تثبيت متطلبات النظام الأساسية
RUN apk add --no-cache \
    curl \
    git \
    unzip \
    libzip-dev \
    sqlite-dev \
    oniguruma-dev \
    libxml2-dev

# تثبيت امتدادات PHP الضرورية لتشغيل Laravel و REST APIs
RUN docker-php-ext-install \
    pdo \
    pdo_sqlite \
    mbstring \
    xml \
    bcmath \
    zip

# تثبيت Composer الرسمي
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# نسخ ملفات المشروع
COPY . /app

# ضبط الأذونات لمجلدات الكاش والتخزين
RUN chown -R www-data:www-data /app \
    && chmod -R 775 /app/storage /app/bootstrap/cache

# تثبيت حزم الاعتماديات للإنتاج
RUN composer install --no-dev --optimize-autoloader --no-interaction

# نسخ ملف البيئة الافتراضي في حال عدم وجوده
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# إعداد سكريبت نقطة الدخول
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# المنفذ الافتراضي الذي توفره Render
ENV PORT=10000
EXPOSE 10000

CMD ["/usr/local/bin/docker-entrypoint.sh"]
