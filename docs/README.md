# ChiliTrack - IoT Monitoring Pembibitan Cabai

ChiliTrack adalah project IoT untuk monitoring pembibitan cabai. Sistem menerima data sensor dari ESP32, menyimpan data kelembapan tanah dan suhu ke MySQL, menampilkan monitoring di aplikasi Flutter, serta menyediakan kontrol pompa melalui backend microservice.

## Tujuan Project

- Memantau kelembapan tanah dan suhu secara real-time.
- Menentukan status kondisi bibit cabai berdasarkan ambang kelembapan dan suhu.
- Mengontrol pompa air melalui control-service.
- Menyediakan backend microservice yang siap dipantau, diamankan, dan dideploy.
- Menjadi dokumentasi teknis untuk DevOps dan kebutuhan skripsi.

## Teknologi

- Backend: Spring Boot 4.0.6, Java 17, Maven
- Security: Spring Security, JWT, BCrypt
- Service discovery: Spring Cloud Netflix Eureka
- API Gateway: Spring Cloud Gateway Server WebMVC
- Database: MySQL 8.4
- Monitoring: Spring Boot Actuator, Micrometer, Prometheus, Grafana
- Container: Docker Compose
- Frontend mobile/web: Flutter
- IoT device: ESP32
- Admin database: phpMyAdmin

## Struktur Folder

```text
.
|-- api-gateway/          # Single entry point untuk Flutter dan client HTTP
|-- auth-service/         # Login, register, JWT generation, user auth
|-- soil-service/         # Data kelembapan tanah dari ESP32
|-- temperature-service/  # Data suhu dari ESP32
|-- control-service/      # Kontrol dan status pompa
|-- eureka-service/       # Service discovery
|-- chili_track/          # Aplikasi Flutter
|-- Kode Arduino/         # Firmware ESP32
|-- docker/               # Dockerfile, Prometheus, Grafana provisioning
|-- docs/                 # Dokumentasi final project
|-- docker-compose.yml    # Orkestrasi semua container
|-- .env.example          # Template environment variable
```

## Daftar Service

| Service | Container | Port Default | Fungsi |
| --- | --- | ---: | --- |
| MySQL | `chili-mysql` | 3307 -> 3306 | Database utama |
| phpMyAdmin | `chili-phpmyadmin` | 8080 | Admin database |
| Eureka | `chili-eureka-service` | 8761 | Service discovery |
| API Gateway | `chili-api-gateway` | 8085 | Single entry point |
| Auth Service | `chili-auth-service` | 8084 | Login, register, JWT |
| Soil Service | `chili-soil-service` | 8081 | Data kelembapan tanah |
| Control Service | `chili-control-service` | 8082 | Kontrol pompa |
| Temperature Service | `chili-temperature-service` | 8083 | Data suhu |
| Prometheus | `chili-prometheus` | 9090 | Metrics collection |
| Grafana | `chili-grafana` | 3000 | Dashboard monitoring |

## API Gateway

API Gateway berjalan di port `8085` dan merutekan request ke service melalui Eureka:

- `/api/auth/**` -> `lb://auth-service`
- `/api/soil/**` -> `lb://soil-service`
- `/api/control/**` -> `lb://control-service`
- `/api/temperature/**` -> `lb://temperature-service`

Flutter menggunakan Gateway sebagai base URL. Default development:

```text
http://localhost:8085
```

Production dapat diganti saat build Flutter:

```powershell
C:\sdk\flutter\bin\flutter.bat build apk --dart-define=API_BASE_URL=https://domain-saya.com
```

## Cara Menjalankan Backend

1. Salin environment:

```powershell
Copy-Item .env.example .env
```

2. Sesuaikan nilai `.env`, terutama password database, JWT secret, CORS, dan password Grafana.

3. Build JAR setiap service:

```powershell
cd eureka-service
.\mvnw.cmd clean package -DskipTests
cd ..
```

Ulangi untuk `api-gateway`, `auth-service`, `soil-service`, `control-service`, dan `temperature-service`.

4. Jalankan Docker Compose:

```powershell
docker compose up -d --build
```

5. Cek container:

```powershell
docker compose ps
```

## Cara Build

Backend per service:

```powershell
.\mvnw.cmd clean package -DskipTests
```

Flutter development:

```powershell
cd chili_track
flutter pub get
flutter run
```

Flutter APK production:

```powershell
cd chili_track
C:\sdk\flutter\bin\flutter.bat build apk --dart-define=API_BASE_URL=https://domain-saya.com
```

## Monitoring

Setiap service mengekspos metrics di:

```text
/actuator/prometheus
```

Prometheus scrape service berikut:

- eureka-service:8761
- api-gateway:8085
- auth-service:8084
- soil-service:8081
- control-service:8082
- temperature-service:8083

Grafana berjalan di `http://localhost:3000` dengan datasource Prometheus melalui provisioning Docker.

## Docker Compose

`docker-compose.yml` menjalankan database, service discovery, backend microservice, gateway, Prometheus, dan Grafana. Healthcheck digunakan agar service menunggu dependency utama seperti MySQL dan Eureka.

## Flutter

Project Flutter berada di `chili_track/`. Base URL API berada di `lib/core/config/api_config.dart` dan dapat dioverride dengan `--dart-define=API_BASE_URL=...`.

## ESP32

Firmware berada di folder `Kode Arduino/`. ESP32 mengirim data kelembapan tanah ke `/api/soil` dan suhu ke `/api/temperature`. Endpoint tersebut tetap public agar firmware tidak perlu membawa JWT.

## MySQL

Database default bernama `chili_track`. Data disimpan melalui JPA dengan `ddl-auto=update` sesuai konfigurasi environment.

## Prometheus dan Grafana

Prometheus mengumpulkan metrics dari Actuator. Grafana digunakan untuk visualisasi performa service dan kesehatan sistem.
