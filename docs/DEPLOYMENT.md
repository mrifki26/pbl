# Panduan Deployment AWS EC2

Dokumen ini menjelaskan langkah deployment ChiliTrack ke AWS EC2 menggunakan Docker Compose.

## 1. Persiapan Server

Rekomendasi awal:

- Ubuntu Server LTS
- Minimal 2 vCPU dan 4 GB RAM untuk menjalankan semua service, MySQL, Prometheus, dan Grafana
- Storage cukup untuk database, metrics, log, dan backup
- Domain diarahkan ke public IP EC2

Port publik yang umum dibuka:

- `80` HTTP untuk challenge/redirect
- `443` HTTPS untuk API Gateway
- `22` SSH terbatas ke IP admin

Port internal seperti MySQL, Eureka, Prometheus, Grafana, dan service backend sebaiknya tidak dibuka ke publik.

## 2. Install Docker

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 3. Clone Repository

```bash
git clone <repository-url> chili-microservice
cd chili-microservice
```

## 4. Buat File `.env`

```bash
cp .env.example .env
nano .env
```

Wajib diganti untuk production:

- `MYSQL_ROOT_PASSWORD`
- `SPRING_DATASOURCE_PASSWORD`
- `JWT_SECRET`
- `GRAFANA_ADMIN_PASSWORD`
- `GATEWAY_CORS_ALLOWED_ORIGIN_PATTERNS`

Contoh:

```text
GATEWAY_CORS_ALLOWED_ORIGIN_PATTERNS=http://chilitrack.online,http://chilitrack.online:8085,http://www.chilitrack.online,http://www.chilitrack.online:8085,https://chilitrack.online,https://www.chilitrack.online,http://34.231.237.42:*,http://localhost:*,http://127.0.0.1:*
JWT_SECRET=isi-dengan-random-secret-panjang-minimal-32-karakter
```

## 5. Build JAR Backend

Jalankan pada setiap service:

```bash
cd eureka-service
./mvnw clean package -DskipTests
cd ..
```

Ulangi untuk:

- `api-gateway`
- `auth-service`
- `soil-service`
- `control-service`
- `temperature-service`

## 6. Build dan Jalankan Container

```bash
docker compose up -d --build
```

Cek status:

```bash
docker compose ps
```

Lihat log:

```bash
docker compose logs -f
```

## 7. Verifikasi Container

Endpoint lokal pada server:

```text
Eureka:      http://34.231.237.42:8761
Gateway:     http://chilitrack.online:8085/actuator/health
Auth:        http://34.231.237.42:8084/actuator/health
Soil:        http://34.231.237.42:8081/actuator/health
Control:     http://34.231.237.42:8082/actuator/health
Temperature: http://34.231.237.42:8083/actuator/health
Prometheus:  http://34.231.237.42:9090
Grafana:     http://34.231.237.42:3000
```

Verifikasi routing gateway:

```bash
curl http://chilitrack.online:8085/actuator/health
curl http://chilitrack.online:8085/api/soil/latest
curl http://chilitrack.online:8085/api/temperature/latest
```

## 8. Nginx Reverse Proxy

Install Nginx:

```bash
sudo apt install -y nginx
```

Contoh konfigurasi:

```nginx
server {
    listen 80;
    server_name domain-saya.com;

    location / {
        proxy_pass http://127.0.0.1:8085;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Reload Nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 9. HTTPS

Gunakan Certbot/Let's Encrypt:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d domain-saya.com
```

Setelah HTTPS aktif, build Flutter dengan:

```bash
flutter build apk --dart-define=API_BASE_URL=http://chilitrack.online:8085
```

## 10. Monitoring

Prometheus:

```text
http://34.231.237.42:9090
```

Grafana:

```text
http://34.231.237.42:3000
```

Grafana menggunakan datasource Prometheus dari provisioning di folder `docker/grafana/provisioning`.

Untuk production, akses Grafana sebaiknya dibatasi dengan VPN, basic auth Nginx, atau Security Group terbatas.

## 11. Backup Database

Backup manual:

```bash
docker exec chili-mysql mysqldump -uroot -p chili_track > backup-chili-track.sql
```

Restore:

```bash
docker exec -i chili-mysql mysql -uroot -p chili_track < backup-chili-track.sql
```

Rekomendasi:

- Jadwalkan backup harian dengan cron.
- Simpan backup di storage terpisah seperti S3.
- Uji restore secara berkala.

## 12. Stop dan Update

Stop container:

```bash
docker compose stop
```

Update deployment:

```bash
git pull
docker compose up -d --build
```
