#!/bin/bash
set -e

# システム更新
dnf update -y

# Dockerインストール
dnf install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Docker Composeプラグイン導入
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# 作業ディレクトリ作成
mkdir -p /home/ec2-user/wordpress
cd /home/ec2-user/wordpress

# docker-compose.yml生成
cat > docker-compose.yml <<'COMPOSE_EOF'
services:
  db:
    image: mysql:8.0
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: $${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: $${MYSQL_PASSWORD}
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    restart: always
    depends_on:
      - db
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: $${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wp_data:/var/www/html

volumes:
  db_data:
  wp_data:
COMPOSE_EOF

# .env生成(Terraformから渡された変数を埋め込む)
cat > .env <<ENV_EOF
MYSQL_ROOT_PASSWORD=${mysql_root_password}
MYSQL_PASSWORD=${mysql_password}
ENV_EOF

chmod 600 .env
chown -R ec2-user:ec2-user /home/ec2-user/wordpress

# 起動
docker compose up -d