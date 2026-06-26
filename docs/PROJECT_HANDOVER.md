# Project Handover - ChiliTrack

Dokumen ini ditujukan untuk tim DevOps yang akan menerima, menjalankan, dan mendeploy project ChiliTrack.

## Ringkasan Project

ChiliTrack adalah sistem IoT monitoring pembibitan cabai berbasis microservice. ESP32 mengirim data sensor ke backend. Flutter membaca data melalui API Gateway dan dapat mengontrol pompa melalui endpoint control yang diproteksi JWT.

## Service

| Service | Port Container | Host Port Default | Container |
| --- | ---: | ---: | --- |
| MySQL | 3306 | 3307 | `chili-mysql` |
| phpMyAdmin | 80 | 8080 | `chili-phpmyadmin` |
| Eureka | 8761 | 8761 | `chili-eureka-service` |
| API Gateway | 8085 | 8085 | `chili-api-gateway` |
| Auth Service | 8084 | 8084 | `chili-auth-service` |
| Soil Service | 8081 | 8081 | `chili-soil-service` |
| Control Service | 8082 | 8082 | `chili-control-service` |
| Temperature Service | 8083 | 8083 | `chili-temperature-service` |
| Prometheus | 9090 | 9090 | `chili-prometheus` |
| Grafana | 3000 | 3000 | `chili-grafana` |

## Dependency

- Docker dan Docker Compose plugin
- Java 17 untuk build JAR
- Maven wrapper per service
- MySQL 8.4 container
- Prometheus v2.55.1
- Grafana 11.4.0
- Flutter SDK untuk build aplikasi
- ESP32 firmware dari folder `Kode Arduino/`

## Environment Variable Penting

- `MYSQL_ROOT_PASSWORD`
- `MYSQL_DATABASE`
- `SPRING_DATASOURCE_URL`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `SPRING_JPA_HIBERNATE_DDL_AUTO`
- `SPRING_JPA_SHOW_SQL`
- `JWT_SECRET`
- `JWT_EXPIRATION_MS`
- `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE`
- `EUREKA_SERVER_ENABLE_SELF_PRESERVATION`
- `GATEWAY_CORS_ALLOWED_ORIGIN_PATTERNS`
- `GRAFANA_ADMIN_USER`
- `GRAFANA_ADMIN_PASSWORD`
- host port variables untuk setiap service

Detail fungsi setiap variable ada di `ENVIRONMENT_VARIABLES.md`.

## Yang Harus Dilakukan Tim DevOps

1. Siapkan EC2, domain, DNS, Docker, dan Docker Compose.
2. Clone repository ke server.
3. Buat `.env` dari `.env.example`.
4. Ganti semua secret dan password default.
5. Build JAR untuk semua service Spring Boot.
6. Jalankan `docker compose up -d --build`.
7. Pasang Nginx sebagai reverse proxy ke API Gateway port `8085`.
8. Aktifkan HTTPS.
9. Build Flutter dengan `--dart-define=API_BASE_URL=https://domain-saya.com`.
10. Batasi akses publik hanya ke port yang diperlukan.
11. Siapkan backup database.
12. Verifikasi Prometheus dan Grafana.

## Checklist Deployment

- [ ] Server EC2 aktif.
- [ ] Domain mengarah ke public IP EC2.
- [ ] Docker dan Docker Compose terinstall.
- [ ] Repository berhasil diclone.
- [ ] File `.env` sudah dibuat.
- [ ] Password dan secret production sudah diganti.
- [ ] Semua JAR service berhasil dibuild.
- [ ] `docker compose up -d --build` berhasil.
- [ ] Semua container `healthy`.
- [ ] Eureka menampilkan semua service.
- [ ] API Gateway dapat diakses.
- [ ] Nginx reverse proxy aktif.
- [ ] HTTPS aktif.
- [ ] Flutter APK dibuild dengan production base URL.

## Checklist Setelah Deployment

- [ ] Register user berhasil.
- [ ] Login user berhasil dan menghasilkan JWT.
- [ ] Password tersimpan sebagai hash BCrypt di database.
- [ ] Flutter dapat membaca data soil latest.
- [ ] Flutter dapat membaca data temperature latest.
- [ ] Endpoint control menolak request tanpa JWT.
- [ ] Endpoint control menerima request dengan JWT valid.
- [ ] ESP32 dapat mengirim data soil.
- [ ] ESP32 dapat mengirim data temperature.
- [ ] Prometheus target status `UP`.
- [ ] Grafana dapat membaca datasource Prometheus.
- [ ] Backup database berhasil dibuat.

## Catatan Penting

- API publik untuk aplikasi adalah API Gateway, bukan port service internal.
- Soil-service dan temperature-service public sesuai desain agar ESP32 dapat mengirim data tanpa JWT.
- Control-service wajib JWT.
- Jangan expose MySQL langsung ke internet.
- Ganti `JWT_SECRET` sebelum production.
