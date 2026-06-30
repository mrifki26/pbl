# Dokumentasi Security

Project menggunakan Spring Security, JWT Authentication, dan BCrypt Password Hashing pada auth-service.

## JWT Authentication

JWT dibuat oleh auth-service saat:

- `POST /api/auth/login`
- `POST /api/auth/register`

Response auth-service berisi:

```json
{
  "token": "jwt-token"
}
```

Token digunakan oleh Flutter untuk endpoint yang diproteksi dengan format:

```http
Authorization: Bearer <token>
```

## Bearer Token

Control-service membaca header `Authorization`. Token harus diawali prefix `Bearer `. Jika token tidak ada, invalid, atau expired, request ditolak dengan `401 Unauthorized`.

## BCrypt Password Hashing

Password user tidak disimpan sebagai plaintext. Pada register, auth-service memanggil `PasswordEncoder.encode()` dengan implementasi `BCryptPasswordEncoder`.

Saat login, auth-service memakai `PasswordEncoder.matches(passwordAsli, passwordHash)` untuk validasi.

## Spring Security

Security menggunakan konfigurasi modern:

- `SecurityFilterChain`
- `requestMatchers()`
- `BCryptPasswordEncoder`
- `OncePerRequestFilter` untuk JWT filter di control-service

Tidak menggunakan konfigurasi deprecated seperti `WebSecurityConfigurerAdapter`.

## Authorization Rules

Auth-service:

- `/api/auth/**` public
- `/actuator/health`, `/actuator/info`, `/actuator/prometheus` public
- endpoint lain ditolak

Control-service:

- `/api/control/**` wajib JWT
- `/actuator/health`, `/actuator/info`, `/actuator/prometheus` public
- endpoint lain ditolak

Soil-service dan temperature-service:

- Endpoint public sesuai desain karena digunakan ESP32 dan Flutter untuk monitoring data.
- Tidak ada JWT validation pada kedua service tersebut.

API Gateway:

- Melakukan routing ke service melalui Eureka.
- Tidak melakukan validasi JWT di gateway pada implementasi saat ini.
- Validasi JWT untuk endpoint control dilakukan di control-service.

## JWT Filter

Control-service menggunakan JWT filter berbasis `OncePerRequestFilter`. Filter membaca Bearer token, memvalidasi token menggunakan secret yang sama dengan auth-service, lalu membuat authentication object untuk request valid.

## Token Expiration

Masa berlaku token dikonfigurasi dengan:

```text
JWT_EXPIRATION_MS=86400000
```

Default saat ini adalah `86400000` ms atau 24 jam.

## HTTP 401 Unauthorized

Endpoint protected mengembalikan `401 Unauthorized` untuk:

- request tanpa token
- token invalid
- token expired
- format Bearer token salah

## Environment Variable

Secret dan credential production harus disimpan di `.env`, bukan di source code.

Variable penting:

- `JWT_SECRET`
- `JWT_EXPIRATION_MS`
- `SPRING_DATASOURCE_PASSWORD`
- `MYSQL_ROOT_PASSWORD`
- `GRAFANA_ADMIN_PASSWORD`

Gunakan secret panjang dan acak untuk production.

## HTTPS Deployment

Pada deployment AWS EC2, semua traffic publik harus melalui HTTPS. Rekomendasi:

- Nginx sebagai reverse proxy ke API Gateway port `8085`.
- TLS certificate dari Let's Encrypt.
- Flutter production menggunakan `http://34.231.237.42:8085` sebagai `API_BASE_URL`.
- Jangan expose port internal service ke publik kecuali diperlukan untuk administrasi terbatas.

## Rekomendasi Security Production

- Ganti semua default password dan secret di `.env`.
- Batasi Security Group AWS hanya untuk port publik yang diperlukan.
- Jangan buka MySQL, Eureka, Prometheus, dan Grafana ke internet tanpa proteksi.
- Gunakan HTTPS untuk API Gateway.
- Gunakan backup database berkala.
- Pertimbangkan memindahkan validasi JWT ke API Gateway bila semua endpoint nantinya harus diproteksi secara konsisten.
