# Arsitektur Project

ChiliTrack menggunakan arsitektur microservice dengan API Gateway sebagai pintu masuk utama, Eureka sebagai service discovery, MySQL sebagai database, dan Prometheus/Grafana untuk monitoring.

## Komponen Utama

```text
Flutter App
    |
    v
API Gateway :8085
    |
    +--> Auth Service :8084
    +--> Soil Service :8081
    +--> Temperature Service :8083
    +--> Control Service :8082

ESP32
    |
    +--> API Gateway /api/soil
    +--> API Gateway /api/temperature

Auth, Soil, Temperature
    |
    v
MySQL :3306

API Gateway dan semua service
    |
    v
Eureka Service :8761

Actuator Metrics
    |
    v
Prometheus :9090
    |
    v
Grafana :3000
```

## Service Discovery

Eureka berjalan pada port `8761`. Service yang register ke Eureka:

- api-gateway
- auth-service
- soil-service
- temperature-service
- control-service

API Gateway menggunakan route `lb://service-name`, sehingga routing tidak bergantung pada hardcoded host container.

## API Gateway

Gateway berjalan pada port `8085` dan menjadi single entry point untuk aplikasi Flutter dan client HTTP lain. Route yang digunakan:

| Path | Target |
| --- | --- |
| `/api/auth/**` | `lb://auth-service` |
| `/api/soil/**` | `lb://soil-service` |
| `/api/temperature/**` | `lb://temperature-service` |
| `/api/control/**` | `lb://control-service` |

## Alur Komunikasi Flutter

1. User login/register dari Flutter.
2. Flutter mengirim request ke API Gateway.
3. Gateway meneruskan `/api/auth/**` ke auth-service.
4. Auth-service mengembalikan JWT.
5. Flutter menyimpan token dan mengirim `Authorization: Bearer <token>` untuk endpoint control.
6. Flutter membaca data monitoring dari `/api/soil/latest` dan `/api/temperature/latest`.
7. Flutter mengontrol pompa melalui `/api/control/on`, `/api/control/off`, dan `/api/control/status`.

## Alur Komunikasi ESP32

1. ESP32 membaca sensor kelembapan tanah dan suhu.
2. ESP32 mengirim data kelembapan ke `POST /api/soil`.
3. ESP32 mengirim data suhu ke `POST /api/temperature`.
4. Gateway meneruskan request ke service terkait.
5. Service menyimpan data ke MySQL.
6. Flutter mengambil data terbaru dari endpoint latest.

Endpoint soil dan temperature didesain public agar ESP32 tetap sederhana dan tidak harus mengelola JWT.

## Database

MySQL menyimpan:

- user auth dari auth-service
- data kelembapan tanah dari soil-service
- data suhu dari temperature-service

Control-service menyimpan status pompa secara in-memory pada implementasi saat ini.

## Monitoring

Setiap service mengekspos endpoint:

```text
/actuator/health
/actuator/info
/actuator/prometheus
```

Prometheus scrape metrics dari semua service. Grafana menggunakan Prometheus sebagai datasource.
