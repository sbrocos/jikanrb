# CLAUDE.md

## Proyecto
Gema Ruby cliente para Jikan API v4 (https://api.jikan.moe/v4)

## Documentación de referencia
- API Docs: https://docs.api.jikan.moe/
- Gema original (v3, archivada): https://github.com/Zerocchi/jikan.rb

## Stack
- Ruby 3.1+
- Faraday para HTTP (con middleware de retry)
- RSpec para tests
- WebMock para stubs HTTP en tests
- RuboCop para linting y style checking
- YARD para documentación

## Convenciones
- Seguir estructura estándar de gemas Ruby
- Métodos snake_case
- Documentar con YARD
- Todo el código debe pasar `bundle exec rubocop` sin ofensas
- Configuración de RuboCop: double quotes, NewCops habilitados, plugins rubocop-rake y rubocop-rspec
- Ejecutar `bundle exec rubocop -A` para auto-correcciones cuando sea posible
- Tests deben usar WebMock stubs (no VCR) para independencia de la API externa

## Estado Actual

### ✅ Implementado
- [x] Client base con Faraday
- [x] Sistema de configuración global y por instancia
- [x] Manejo de errores completo (404, 400, 429, 5xx, timeouts, parse errors)
- [x] Retry automático con backoff exponencial
- [x] Rate limiting awareness
- [x] Endpoints principales:
  - anime(id, full: false)
  - manga(id, full: false)
  - character(id, full: false)
  - person(id, full: false)
  - search_anime(query, **params)
  - search_manga(query, **params)
  - top_anime(type:, filter:, page:)
  - top_manga(type:, filter:, page:)
  - season(year, season, page:)
  - season_now(page:)
  - schedules(day:)
- [x] Métodos de conveniencia globales (Jikanrb.anime(1), etc.)
- [x] Suite completa de tests (63 tests pasando)
- [x] RuboCop configurado y pasando (0 ofensas)

### 🧪 Tests
- 63 ejemplos, 0 fallos
- Cobertura completa de endpoints
- Tests de manejo de errores
- Tests de configuración
- Todos los tests usan WebMock stubs (no requieren conexión a internet)

### 📋 Tareas Pendientes
- [ ] Añadir más endpoints según necesidad (studios, producers, clubs, etc.)
- [x] Implementar paginación helpers
- [ ] Añadir validación de parámetros
- [ ] Crear objetos de respuesta tipados (opcional)
- [ ] Publicar gem en RubyGems
- [ ] Documentación completa con YARD
- [x] README con ejemplos de uso
- [ ] CHANGELOG actualizado