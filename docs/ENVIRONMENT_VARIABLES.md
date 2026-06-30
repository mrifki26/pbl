# Environment Variables

Template environment tersedia di `.env.example`. Untuk deployment, salin menjadi `.env` dan ganti nilai sensitif.

```bash
cp .env.example .env
```

## Database

| Variable | Fungsi | Contoh |
| --- | --- | --- |
| `MYSQL_ROOT_PASSWORD` | Password root MySQL container | `change-me` |
| `MYSQL_DATABASE` | Nama database yang dibuat otomatis | `chili_track` |
| `SPRING_DATASOURCE_URL` | JDBC URL untuk service Spring Boot | `jdbc:mysql://mysql:3306/chili_track?...` |
| `SPRING_DATASOURCE_USERNAME` | Username database untuk service | `root` |
| `SPRING_DATASOURCE_PASSWORD` | Password database untuk service | `change-me` |
| `SPRING_JPA_HIBERNATE_DDL_AUTO` | Mode schema JPA | `update` |
| `SPRING_JPA_SHOW_SQL` | Menampilkan SQL query di log | `false` |

Catatan production:

- Gunakan password kuat.
- Pertimbangkan user database khusus selain `root`.
- Untuk production besar, pertimbangkan migration tool seperti Flyway atau Liquibase.

## JWT

| Variable | Fungsi | Default Development |
| --- | --- | --- |
| `JWT_SECRET` | Secret untuk sign dan validate JWT | `change-me-to-a-long-random-secret-at-least-32-characters` |
| `JWT_EXPIRATION_MS` | Masa berlaku token dalam milidetik | `86400000` |

`JWT_SECRET` wajib sama antara auth-service dan control-service.

## Eureka

| Variable | Fungsi | Default Docker |
| --- | --- | --- |
| `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE` | URL Eureka yang dipakai client service | `http://eureka-service:8761/eureka/` |
| `EUREKA_SERVER_ENABLE_SELF_PRESERVATION` | Mode self-preservation Eureka | `true` |

Saat menjalankan service lokal tanpa Docker, default properties mengarah ke:

```text
http://eureka-service:8761/eureka/
```

## API Gateway

| Variable | Fungsi | Contoh |
| --- | --- | --- |
| `GATEWAY_CORS_ALLOWED_ORIGIN_PATTERNS` | Origin yang diizinkan oleh CORS gateway | `http://34.231.237.42:*,http://34.231.237.42:8085` |

Untuk development, gateway memiliki default:

```text
http://34.231.237.42:*,http://34.231.237.42:8085
```

Untuk production, gunakan domain asli.

## Grafana

| Variable | Fungsi | Default |
| --- | --- | --- |
| `GRAFANA_ADMIN_USER` | Username admin Grafana | `admin` |
| `GRAFANA_ADMIN_PASSWORD` | Password admin Grafana | `change-me` |

Wajib ganti password Grafana untuk production.

## Host Ports

| Variable | Fungsi | Default |
| --- | --- | ---: |
| `MYSQL_HOST_PORT` | Port MySQL di host | 3307 |
| `PHPMYADMIN_HOST_PORT` | Port phpMyAdmin di host | 8080 |
| `EUREKA_HOST_PORT` | Port Eureka di host | 8761 |
| `AUTH_HOST_PORT` | Port auth-service di host | 8084 |
| `SOIL_HOST_PORT` | Port soil-service di host | 8081 |
| `CONTROL_HOST_PORT` | Port control-service di host | 8082 |
| `TEMPERATURE_HOST_PORT` | Port temperature-service di host | 8083 |
| `API_GATEWAY_HOST_PORT` | Port API Gateway di host | 8085 |
| `PROMETHEUS_HOST_PORT` | Port Prometheus di host | 9090 |
| `GRAFANA_HOST_PORT` | Port Grafana di host | 3000 |

Pada production, hanya API Gateway yang perlu dipublikasikan melalui Nginx/HTTPS. Port lain sebaiknya hanya internal atau dibatasi Security Group.

## phpMyAdmin

| Variable | Fungsi | Default |
| --- | --- | --- |
| `PHPMYADMIN_UPLOAD_LIMIT` | Batas upload phpMyAdmin | `64M` |

## Flutter Build Variable

Flutter memakai compile-time variable:

| Variable | Fungsi | Default Development |
| --- | --- | --- |
| `API_BASE_URL` | Base URL API Gateway untuk aplikasi Flutter | `http://34.231.237.42:8085` |

Contoh build production:

```bash
flutter build apk --dart-define=API_BASE_URL=http://34.231.237.42:8085
```
