# AGENTS.md

## Notas para Agentes de IA

Este documento contiene información técnica específica para agentes de IA que trabajen en este proyecto.

## Arquitectura del Proyecto

### Estructura de Archivos
```
lib/
├── jikanrb.rb              # Módulo principal con métodos de conveniencia
├── jikanrb/
    ├── version.rb          # Versión de la gema
    ├── configuration.rb    # Sistema de configuración
    ├── errors.rb           # Jerarquía de errores personalizados
    └── client.rb           # Cliente HTTP principal

spec/
├── spec_helper.rb          # Configuración de RSpec y WebMock
├── jikanrb_spec.rb         # Tests del módulo principal
└── jikanrb/
    ├── configuration_spec.rb  # Tests de configuración
    └── client_spec.rb         # Tests del cliente HTTP
```

### Componentes Principales

#### 1. Jikanrb::Client
- Cliente HTTP basado en Faraday
- Maneja todas las peticiones a la API de Jikan v4
- Incluye middleware de retry con backoff exponencial
- Maneja errores HTTP y los convierte en excepciones tipadas

#### 2. Jikanrb::Configuration
- Sistema de configuración con valores por defecto
- Soporta configuración global y por instancia
- Parámetros configurables:
  - `base_url`: URL base de la API (default: https://api.jikan.moe/v4)
  - `open_timeout`: Timeout de conexión (default: 5s)
  - `read_timeout`: Timeout de lectura (default: 10s)
  - `max_retries`: Reintentos máximos (default: 3)
  - `retry_interval`: Intervalo entre reintentos (default: 1s)
  - `user_agent`: User-Agent HTTP
  - `logger`: Logger opcional

#### 3. Sistema de Errores
Jerarquía de excepciones:
- `Jikanrb::Error` (base)
  - `Jikanrb::ClientError`
    - `Jikanrb::BadRequestError` (400)
    - `Jikanrb::NotFoundError` (404)
    - `Jikanrb::MethodNotAllowedError` (405)
    - `Jikanrb::RateLimitError` (429) - incluye `retry_after`
  - `Jikanrb::ServerError` (5xx)
  - `Jikanrb::ConnectionError` (timeouts, network)
  - `Jikanrb::ParseError` (JSON inválido)

## Testing

### Estrategia de Tests
- **WebMock stubs**: Todos los tests usan stubs de WebMock para simular respuestas HTTP
- **No VCR**: No se usan cassettes VCR para mantener tests independientes de la API externa
- **Cobertura completa**: 63 tests cubriendo todos los endpoints y casos de error

### Ejecutar Tests
```bash
bundle exec rspec                    # Todos los tests
bundle exec rspec --format documentation  # Con salida detallada
bundle exec rspec spec/jikanrb/client_spec.rb  # Solo tests del cliente
```

### Estructura de Tests
- `spec/jikanrb_spec.rb`: Tests del módulo principal y métodos globales
- `spec/jikanrb/configuration_spec.rb`: Tests del sistema de configuración
- `spec/jikanrb/client_spec.rb`: Tests del cliente HTTP y endpoints

### Ejemplo de Test con WebMock
```ruby
it 'fetches anime by ID' do
  response_body = { data: { mal_id: 1, title: 'Cowboy Bebop' } }.to_json
  
  stub_request(:get, "https://api.jikan.moe/anime/1")
    .to_return(status: 200, body: response_body, headers: { 'Content-Type' => 'application/json' })

  result = client.anime(1)
  expect(result['data']['title']).to eq('Cowboy Bebop')
end
```

## Linting y Estilo

### RuboCop
- Configuración en `.rubocop.yml`
- Plugins activos: `rubocop-rake`, `rubocop-rspec`
- Estilo de strings: **double quotes** (importante)
- NewCops habilitados

### Ejecutar RuboCop
```bash
bundle exec rubocop           # Inspeccionar
bundle exec rubocop -A        # Auto-corregir
```

### Reglas RSpec Personalizadas
```yaml
RSpec/ExampleLength:
  Max: 15
RSpec/MultipleExpectations:
  Max: 5
RSpec/AnyInstance:
  Enabled: false
RSpec/MessageSpies:
  Enabled: false
```

## Endpoints Implementados

Todos los endpoints soportan el parámetro `full: true` para información extendida:

### Recursos Individuales
- `client.anime(id, full: false)`
- `client.manga(id, full: false)`
- `client.character(id, full: false)`
- `client.person(id, full: false)`

### Búsquedas
- `client.search_anime(query, **params)` - params: type, score, status, rating, etc.
- `client.search_manga(query, **params)`

### Rankings
- `client.top_anime(type:, filter:, page:)` - type: tv, movie, ova, etc.
- `client.top_manga(type:, filter:, page:)`

### Temporadas
- `client.season(year, season, page:)` - season: winter, spring, summer, fall
- `client.season_now(page:)`

### Horarios
- `client.schedules(day:)` - day: monday, tuesday, etc. (opcional)

## Métodos Globales

El módulo `Jikanrb` proporciona métodos de conveniencia que delegan al cliente por defecto:

```ruby
# En lugar de:
client = Jikanrb::Client.new
client.anime(1)

# Puedes usar:
Jikanrb.anime(1)
```

## Configuración Global

```ruby
Jikanrb.configure do |config|
  config.read_timeout = 15
  config.max_retries = 5
  config.logger = Logger.new($stdout)
end

# Usar el cliente configurado globalmente
anime = Jikanrb.anime(1)

# O crear instancia con configuración personalizada
client = Jikanrb::Client.new do |config|
  config.read_timeout = 30
end
```

## Buenas Prácticas para Agentes

1. **Tests primero**: Al añadir nuevos endpoints, crear tests con WebMock stubs primero
2. **RuboCop siempre**: Ejecutar `bundle exec rubocop -A` después de cambios
3. **Double quotes**: Usar comillas dobles consistentemente según configuración
4. **Documentación YARD**: Documentar nuevos métodos públicos con YARD
5. **Manejo de errores**: Lanzar excepciones apropiadas de la jerarquía existente
6. **Configuración**: Nuevos parámetros configurables deben añadirse a `Configuration`

## Rate Limiting

La API de Jikan tiene límites de rate (60 peticiones/minuto):
- El cliente incluye retry automático para 429 responses
- El header `Retry-After` se respeta en `RateLimitError`
- Backoff exponencial: 1s, 2s, 4s entre reintentos

## Próximos Pasos Sugeridos

1. Añadir endpoints adicionales según documentación de Jikan API v4
2. Crear objetos de respuesta tipados (opcional, actualmente retorna Hashes)
3. Añadir validación de parámetros
4. Mejorar documentación YARD
5. Preparar para publicación en RubyGems
