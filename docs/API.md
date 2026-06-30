# Dokumentasi API

Base URL development melalui API Gateway:

```text
http://34.231.237.42:8085
```

Base URL production:

```text
http://34.231.237.42:8085
```

Header untuk endpoint yang membutuhkan JWT:

```http
Authorization: Bearer <token>
Content-Type: application/json
```

## Auth Service

Base path:

```text
/api/auth
```

### Register

| Item | Detail |
| --- | --- |
| Method | `POST` |
| URL | `/api/auth/register` |
| Authentication | Public |

Request:

```json
{
  "username": "asep",
  "password": "12345678"
}
```

Response `200 OK`:

```json
{
  "token": "jwt-token"
}
```

Status code:

- `200 OK` register berhasil
- `400 Bad Request` username/password kosong
- `409 Conflict` username sudah terdaftar

### Login

| Item | Detail |
| --- | --- |
| Method | `POST` |
| URL | `/api/auth/login` |
| Authentication | Public |

Request:

```json
{
  "username": "asep",
  "password": "12345678"
}
```

Response `200 OK`:

```json
{
  "token": "jwt-token"
}
```

Status code:

- `200 OK` login berhasil
- `400 Bad Request` username/password tidak dikirim
- `401 Unauthorized` username atau password salah

## Soil Service

Base path:

```text
/api/soil
```

### Simpan Data Kelembapan Tanah

| Item | Detail |
| --- | --- |
| Method | `POST` |
| URL | `/api/soil` |
| Authentication | Public |
| Pengguna | ESP32 |

Request:

```json
{
  "soilMoisture": 65.5,
  "deviceId": 1,
  "soilRaw": 1890
}
```

Response `200 OK`:

```json
{
  "message": "Soil data saved"
}
```

Status code:

- `200 OK` data berhasil disimpan
- `400 Bad Request` field wajib tidak valid

### Ambil Data Kelembapan Terbaru

| Item | Detail |
| --- | --- |
| Method | `GET` |
| URL | `/api/soil/latest` |
| Authentication | Public |
| Pengguna | Flutter |

Response `200 OK`:

```json
{
  "soilMoisture": 65.5,
  "deviceId": 1,
  "soilRaw": 1890,
  "createdAt": "2026-06-26T10:00:00"
}
```

## Temperature Service

Base path:

```text
/api/temperature
```

### Simpan Data Suhu

| Item | Detail |
| --- | --- |
| Method | `POST` |
| URL | `/api/temperature` |
| Authentication | Public |
| Pengguna | ESP32 |

Request:

```json
{
  "temperature": 26.5,
  "deviceId": 1
}
```

Response `200 OK`:

```json
{
  "message": "Temperature saved"
}
```

Status code:

- `200 OK` data berhasil disimpan
- `400 Bad Request` field wajib tidak valid

### Ambil Data Suhu Terbaru

| Item | Detail |
| --- | --- |
| Method | `GET` |
| URL | `/api/temperature/latest` |
| Authentication | Public |
| Pengguna | Flutter |

Response `200 OK`:

```json
{
  "temperature": 26.5,
  "deviceId": 1,
  "createdAt": "2026-06-26T10:00:00"
}
```

## Control Service

Base path:

```text
/api/control
```

Semua endpoint `/api/control/**` membutuhkan JWT valid.

### Test Service

| Item | Detail |
| --- | --- |
| Method | `GET` |
| URL | `/api/control` |
| Authentication | JWT |

Response `200 OK`:

```text
Control Service Running
```

### Nyalakan Pompa

| Item | Detail |
| --- | --- |
| Method | `POST` |
| URL | `/api/control/on` |
| Authentication | JWT |

Response `200 OK`:

```json
{
  "message": "Pompa menyala",
  "status": true
}
```

Status code:

- `200 OK` berhasil
- `401 Unauthorized` token tidak ada, invalid, atau expired

### Matikan Pompa

| Item | Detail |
| --- | --- |
| Method | `POST` |
| URL | `/api/control/off` |
| Authentication | JWT |

Response `200 OK`:

```json
{
  "message": "Pompa mati",
  "status": false
}
```

Status code:

- `200 OK` berhasil
- `401 Unauthorized` token tidak ada, invalid, atau expired

### Ambil Status Pompa

| Item | Detail |
| --- | --- |
| Method | `GET` |
| URL | `/api/control/status` |
| Authentication | JWT |

Response `200 OK`:

```json
{
  "message": "Status pompa",
  "status": false
}
```

Status code:

- `200 OK` berhasil
- `401 Unauthorized` token tidak ada, invalid, atau expired

## Actuator

Endpoint monitoring berikut tersedia pada service Spring Boot:

```text
/actuator/health
/actuator/info
/actuator/prometheus
```

Endpoint tersebut public untuk kebutuhan healthcheck Docker dan scraping Prometheus.
