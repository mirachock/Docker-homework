# Запуск

Есть файл .env.example - как пример файла .env\
В .env можно настроить:\
PORT=8080, порт на localhost, который будет подключаться к контейнеру
GREETING="Hello, Docker!", отвечает за соответсвуйющую строку в json (получается при взаимодействии с программой)

Делает образ под названием X-app, создает compose проект X-main с двумя контейнерами X-app, redis:7.4-alpine, также создается volume: X_redis-data (где X - имя Compose проекта, по умолчанию - имя репозитория)

# Приложение

Учебный HTTP-сервис со счётчиком. 

| Запрос | Результат |
| --- | --- |
| `GET /` | JSON с `greeting`, `count`, `hostname`, `storage`; счётчик не меняется |
| `POST /increment` | Увеличить счётчик на 1, вернуть тот же JSON; тело не требуется |
| `GET /healthz` | HTTP 200, если HTTP-сервер работает |
| `GET /readyz` | HTTP 200 при доступном хранилище, иначе 503 |

При недоступности Redis `GET /` и `POST /increment` тоже возвращают 503.
Приложение не сбрасывает данные и не переключается на SQLite при сбое Redis.
После восстановления Redis следующий запрос снова может выполниться.
Для проверки JSON открывайте адрес в браузере или используйте `curl`.

# Отчет

Ниже представлены команды и выводы на них (команды выполнялиьс последовательно)

## Создание образа и контейнера

### docker compose up -d

[+] Building 3.0s (13/13) FINISHED                                                                                                                    \
 => [internal] load local bake definitions                                                                                                       0.0s\
 => => reading from stdin 538B                                                                                                                   0.0s\
 => [internal] load build definition from Dockerfile                                                                                             0.0s\
 => => transferring dockerfile: 319B                                                                                                             0.0s\
 => [internal] load metadata for docker.io/library/python:3.13-slim                                                                              2.0s\
 => [internal] load .dockerignore                                                                                                                0.0s\
 => => transferring context: 109B                                                                                                                0.0s\
 => [1/6] FROM docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90                        0.0s\
 => => resolve docker.io/library/python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90                        0.0s\
 => [internal] load build context                                                                                                                0.0s\
 => => transferring context: 94B                                                                                                                 0.0s\
 => CACHED [2/6] WORKDIR /app                                                                                                                    0.0s\
 => CACHED [3/6] COPY app/app.py .                                                                                                               0.0s\
 => CACHED [4/6] COPY app/requirements.txt .                                                                                                     0.0s\
 => CACHED [5/6] RUN pip install -r requirements.txt                                                                                             0.0s\
 => CACHED [6/6] RUN apt-get update && apt-get install -y curl                                                                                   0.0s\
 => exporting to image                                                                                                                           0.7s\
 => => exporting layers                                                                                                                          0.0s\
 => => exporting manifest sha256:67d9228d1afe73e5c7ea966466be8b16e9890c8538033b8942e63af7491379eb                                                0.0s\
 => => exporting config sha256:0e56e9e344164d28cdc44e4525cc7cb09250d0633d0c0d9f83c7fd0b2b896484                                                  0.0s\
 => => exporting attestation manifest sha256:679d63ee0d4e248040d20ec04370f1bb239264b02f6944b8d718006157cbf9c2                                    0.0s\
 => => exporting manifest list sha256:02ef51f134762e2c04d7b1d9fb55041c132791c3c4b436e8818388f59fc8f4cb                                           0.0s\
 => => naming to docker.io/library/hw_3_template-main-app:latest                                                                                 0.0s\
 => => unpacking to docker.io/library/hw_3_template-main-app:latest                                                                              0.5s\
 => resolving provenance for metadata file                                                                                                       0.0s\
[+] up 5/5\
 ✔ Image hw_3_template-main-app         Built                                                                                                     3.1s\
 ✔ Network hw_3_template-main_default   Created                                                                                                   0.1s\
 ✔ Volume hw_3_template-main_redis-data Created                                                                                                   0.0s\
 ✔ Container hw_3_template-main-redis-1 Healthy                                                                                                   6.4s\
 ✔ Container hw_3_template-main-app-1   Started                                                                                                   6.0s\

## Проверка работоспособности

### curl -fsS http://127.0.0.1:8080/

{"greeting": "Hello, Docker!", "count": 0, "hostname": "2d3ff1eb7daf", "storage": "redis"}

### curl -fsS -X POST http://127.0.0.1:8080/increment

{"greeting": "Hello, Docker!", "count": 1, "hostname": "2d3ff1eb7daf", "storage": "redis"}

### curl -fsS -X POST http://127.0.0.1:8080/increment

{"greeting": "Hello, Docker!", "count": 2, "hostname": "2d3ff1eb7daf", "storage": "redis"}

### curl -fsS http://127.0.0.1:8080/

{"greeting": "Hello, Docker!", "count": 2, "hostname": "2d3ff1eb7daf", "storage": "redis"}

## Выключение и включение контейнера

### docker compose down

[+] down 3/3\
 ✔ Container hw_3_template-main-app-1   Removed                                                                                                  10.2s\
 ✔ Container hw_3_template-main-redis-1 Removed                                                                                                   0.3s\
 ✔ Network hw_3_template-main_default   Removed                                                                                                   0.1s

### docker compose up -d

[+] up 3/3\
 ✔ Network hw_3_template-main_default   Created                                                                                                   0.0s\
 ✔ Container hw_3_template-main-redis-1 Healthy                                                                                                   5.9s\
 ✔ Container hw_3_template-main-app-1   Started                                                                                                   5.9s

## Проверка того, что данные были сохранены (то есть не пропали)

###  curl -fsS http://127.0.0.1:8080/

{"greeting": "Hello, Docker!", "count": 2, "hostname": "8b27383f355e", "storage": "redis"}

## Выключение redis

### docker compose stop redis

[+] stop 1/1\
 ✔ Container hw_3_template-main-redis-1 Stopped                                                                                                   0.3s

## Проверка только недоступности redis

### curl -fsS http://127.0.0.1:8080/healthz

{"status": "alive"}

### curl -fsS http://127.0.0.1:8080/readyz

curl: (22) The requested URL returned error: 503


### curl -fsS -X POST http://127.0.0.1:8080/increment

curl: (22) The requested URL returned error: 503

## Обратно включаем redis

### docker compose start redis

[+] start 1/1\
 ✔ Container hw_3_template-main-redis-1 Started                                                                                                   0.2s

## Проверяка того, что перезапуск redis не повлиял на работу

### curl -fsS http://127.0.0.1:8080/

{"greeting": "Hello, Docker!", "count": 2, "hostname": "8b27383f355e", "storage": "redis"}

### curl -fsS -X POST http://127.0.0.1:8080/increment

{"greeting": "Hello, Docker!", "count": 3, "hostname": "8b27383f355e", "storage": "redis"}
