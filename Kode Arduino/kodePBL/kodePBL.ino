#include <WiFi.h>
#include <WiFiClient.h>
#include <HTTPClient.h>
#include <DHT.h>

// ================= WIFI =================
const char* ssid = "Admin";
const char* password = "00000000";

// ================= API =================
// IP laptop/PC yang menjalankan backend Spring Boot.
// ESP32 dan laptop harus berada di jaringan WiFi yang sama.
const char* soilUrl = "http://34.231.237.42:8085/api/soil";
const char* tempUrl = "http://34.231.237.42:8085/api/temperature";

// ================= PIN =================
#define SOIL_PIN 32
#define RELAY_PIN 33
#define DHTPIN 4
#define DHTTYPE DHT22
  
DHT dht(DHTPIN, DHTTYPE);

// ================= RELAY =================
// relay ACTIVE LOW
#define PUMP_ON LOW
#define PUMP_OFF HIGH

// ================= KALIBRASI FINAL =================
int dryValue = 3500;
int wetValue = 1550;

// ================= THRESHOLD =================
const float soilDryThreshold = 60.0;
const float soilWetThreshold = 80.0;
const float tempMinIdeal = 24.0;
const float tempMaxIdeal = 28.0;

// ================= FUNCTION =================

int readSoilSmooth() {
  int total = 0;
  for (int i = 0; i < 5; i++) {
    total += analogRead(SOIL_PIN);
    delay(50);
  }
  return total / 5;
}

float convertSoil(int soilRaw) {
  float percent = (float)(dryValue - soilRaw) / (dryValue - wetValue) * 100;
  percent = percent * 0.58;
  return constrain(percent, 0, 100);
}

void sendData(String url, String json) {
  WiFiClient client;
  HTTPClient http;

  Serial.print("POST URL: ");
  Serial.println(url);

  String host = url;
  host.replace("http://", "");
  int slashIndex = host.indexOf('/');
  if (slashIndex >= 0) {
    host = host.substring(0, slashIndex);
  }

  String portText = "80";
  int colonIndex = host.indexOf(':');
  if (colonIndex >= 0) {
    portText = host.substring(colonIndex + 1);
    host = host.substring(0, colonIndex);
  }

  int port = portText.toInt();
  Serial.print("TCP test ");
  Serial.print(host);
  Serial.print(":");
  Serial.print(port);
  Serial.print(" -> ");
  if (client.connect(host.c_str(), port)) {
    Serial.println("OK");
    client.stop();
  } else {
    Serial.println("FAILED");
  }

  http.begin(client, url);
  http.setTimeout(10000);
  http.addHeader("Content-Type", "application/json");

  int res = http.POST(json);

  Serial.print("Response Code: ");
  Serial.println(res);

  if (res > 0) {
    Serial.println("Response Body:");
    Serial.println(http.getString());
  } else {
    Serial.print("Error: ");
    Serial.println(http.errorToString(res));
  }

  http.end();
}

void setup() {
  Serial.begin(115200);

  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, PUMP_OFF);

  dht.begin();

  WiFi.begin(ssid, password);
  Serial.print("Connecting WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWiFi Connected!");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());
  Serial.print("Gateway : ");
  Serial.println(WiFi.gatewayIP());
  Serial.print("Subnet  : ");
  Serial.println(WiFi.subnetMask());
  Serial.print("RSSI    : ");
  Serial.println(WiFi.RSSI());
}

void loop() {
  int soilRaw = readSoilSmooth();
  float soilPercent = convertSoil(soilRaw);
  float temp = dht.readTemperature();

  if (isnan(temp)) {
    Serial.println("DHT ERROR");
    delay(2000);
    return;
  }

  bool pumpOn = false;
  String soilStatus;
  String tempStatus;

  if (soilPercent < soilDryThreshold) {
    digitalWrite(RELAY_PIN, PUMP_ON);
    pumpOn = true;
    soilStatus = "Tanah kering, pompa menyala";
  } else {
    digitalWrite(RELAY_PIN, PUMP_OFF);
    pumpOn = false;

    if (soilPercent <= soilWetThreshold) {
      soilStatus = "Kelembapan ideal, pompa mati";
    } else {
      soilStatus = "Tanah terlalu basah, pompa mati";
    }
  }

  if (temp < tempMinIdeal) {
    tempStatus = "Suhu terlalu rendah";
  } else if (temp <= tempMaxIdeal) {
    tempStatus = "Suhu ideal";
  } else {
    tempStatus = "Suhu terlalu tinggi";
  }

  Serial.println("\n========== SENSOR ==========");
  Serial.print("Soil Raw     : "); Serial.println(soilRaw);
  Serial.print("Soil Percent : "); Serial.print(soilPercent); Serial.println("%");
  Serial.print("Soil Status  : "); Serial.println(soilStatus);
  Serial.print("Temperature  : "); Serial.print(temp); Serial.println(" C");
  Serial.print("Temp Status  : "); Serial.println(tempStatus);
  Serial.print("Pump Status  : "); Serial.println(pumpOn ? "ON" : "OFF");
  Serial.println("============================");

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi reconnecting...");
    WiFi.reconnect();
    delay(3000);
    return;
  }

  String soilJson = "{";
  soilJson += "\"soilMoisture\":" + String(soilPercent, 2) + ",";
  soilJson += "\"soilRaw\":" + String(soilRaw) + ",";
  soilJson += "\"deviceId\":1}";

  Serial.println("\nSEND SOIL:");
  Serial.println(soilJson);

  sendData(soilUrl, soilJson);

  delay(500);

  String tempJson = "{";
  tempJson += "\"temperature\":" + String(temp, 2) + ",";
  tempJson += "\"deviceId\":1}";

  Serial.println("\nSEND TEMP:");
  Serial.println(tempJson);

  sendData(tempUrl, tempJson);

  delay(3000);
}
