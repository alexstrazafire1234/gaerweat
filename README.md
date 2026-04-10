# Telemt MTProxy on Railway

Быстрый деплой [telemt](https://github.com/telemt/telemt) (Rust MTProxy) на Railway.

## Деплой

### Через GitHub

1. Форкни/залей это репо на GitHub
2. В Railway: New Project → Deploy from GitHub repo → выбери это репо
3. Настрой переменные окружения (см. ниже)
4. В Settings → Networking → Add Port `443`

### Переменные окружения (Variables)

| Переменная | Описание | Дефолт |
|---|---|---|
| `SECRET` | Твой секрет (32 hex символа) | генерируется случайно |
| `USERNAME` | Имя пользователя (для конфига) | `user` |
| `PORT` | Порт сервера | `443` |
| `TLS_DOMAIN` | Домен для TLS-маскировки | `www.google.com` |
| `AD_TAG` | Тег от @MTProxybot (опционально) | пусто |
| `LOG_LEVEL` | Уровень логов: debug/normal/silent | `normal` |

### Как сгенерировать SECRET

```bash
openssl rand -hex 16
```

## Подключение в Telegram

После деплоя смотри в логах строки:
```
Secret:      <твой секрет>
Secret для Fake TLS (ee): ee<hex домена><секрет>
```

В Telegram → Settings → Data and Storage → Proxy → Add Proxy → MTProto:
- **Server**: твой домен Railway (из Settings → Networking)
- **Port**: порт из Railway Networking (не обязательно 443)
- **Secret**: `ee<hex домена><секрет>` (из логов)

## Регистрация у @MTProxybot

1. Напиши `/newproxy` боту [@MTProxybot](https://t.me/MTProxybot)
2. Укажи хост, порт, секрет
3. Получи тег и добавь в переменную `AD_TAG`
