# Tests de OmniAuth para Devise + Google OAuth2

Este documento describe la infraestructura de tests agregada para validar la futura implementación de OmniAuth con Google OAuth2 en el proyecto.

## Archivos Creados

### 1. `spec/support/omniauth.rb`
Configuración de OmniAuth para tests que incluye:
- Activación del modo de prueba: `OmniAuth.config.test_mode = true`
- Helper method `mock_google_oauth` para crear mocks de autenticación de Google con parámetros personalizables
- Limpieza automática de mocks después de cada test

### 2. `spec/requests/omniauth_callbacks_spec.rb`
Suite de 11 tests que documentan el comportamiento esperado:

#### Tests de Creación de Usuario:
- ✓ Crear un nuevo usuario con datos de Google cuando no existe
- ✓ Autenticar al usuario después de crear la cuenta
- ✓ Verificar redirección apropiada

#### Tests de Inicio de Sesión:
- ✓ No crear usuario duplicado cuando ya existe con el mismo email
- ✓ Autenticar al usuario existente
- ✓ Actualizar información del usuario con datos de Google

#### Tests de Manejo de Errores:
- ✓ No crear usuario cuando Google no devuelve email
- ✓ Redirigir al formulario de registro con mensaje de error
- ✓ Manejar errores de autenticación de Google
- ✓ Manejar cancelación de usuario

#### Tests de Configuración:
- ✓ Verificar ruta de callback de Google configurada
- ✓ Verificar ruta de inicio de autenticación configurada

## Estado Actual

Todos los tests están marcados como **PENDING** (pendientes) con el mensaje:
```ruby
skip "Pendiente: Implementar OmniAuth callbacks controller y configuración de Devise"
```

Esto es intencional ya que la implementación de OmniAuth no existe todavía. Los tests sirven como:
1. **Documentación** del comportamiento esperado
2. **Guía** para la implementación futura
3. **Validación** una vez implementada la funcionalidad

## Ejecutar los Tests

```bash
bundle exec rspec spec/requests/omniauth_callbacks_spec.rb
```

Resultado esperado: `11 examples, 0 failures, 11 pending`

## Próximos Pasos para Implementación

Para que estos tests pasen, se necesita implementar:

### 1. Migración de Base de Datos
Agregar columnas `provider` y `uid` al modelo User:
```ruby
rails generate migration AddOmniauthToUsers provider:string uid:string
rails db:migrate
```

### 2. Configurar Modelo User
Agregar el módulo `:omniauthable` en `app/models/user.rb`:
```ruby
devise :database_authenticatable, :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:google_oauth2]
```

Agregar método `from_omniauth`:
```ruby
def self.from_omniauth(auth)
  where(email: auth.info.email).first_or_create do |user|
    user.email = auth.info.email
    user.name = auth.info.name
    user.password = Devise.friendly_token[0, 20]
    user.provider = auth.provider
    user.uid = auth.uid
    # Asignar country_code por defecto si es requerido
    user.country_code = 'US' # o el que corresponda
  end
end
```

### 3. Crear Controlador de Callbacks
Crear `app/controllers/users/omniauth_callbacks_controller.rb`:
```ruby
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: 'Error de autenticación con Google'
  end
end
```

### 4. Configurar Rutas
Actualizar `config/routes.rb`:
```ruby
devise_for :users, controllers: { 
  sessions: 'users/sessions',
  omniauth_callbacks: 'users/omniauth_callbacks'
}
```

### 5. Configurar Devise Initializer
En `config/initializers/devise.rb`, agregar:
```ruby
config.omniauth :google_oauth2, 
  ENV['GOOGLE_CLIENT_ID'], 
  ENV['GOOGLE_CLIENT_SECRET'],
  scope: 'email,profile'
```

### 6. Configurar Variables de Entorno
Agregar al archivo `.env` (no commitear):
```
GOOGLE_CLIENT_ID=tu_client_id
GOOGLE_CLIENT_SECRET=tu_client_secret
```

## Correcciones Adicionales Incluidas

Para que la infraestructura de tests funcione, se corrigieron bugs pre-existentes:

1. **database.yml**: Se agregó manejo seguro de credenciales faltantes usando el operador safe navigation (`&.`)
2. **install_generator.rb**: Se corrigió la estructura de módulos para cumplir con Zeitwerk
3. **.gitignore**: Se agregó `vendor/bundle` para excluir dependencias

## Notas Importantes

- El gem `omniauth-google-oauth2` ya está instalado en el Gemfile
- La factory de User existente ya tiene los atributos necesarios
- Los tests usan el modo test de OmniAuth que no hace llamadas reales a Google
- Se recomienda agregar también `omniauth-rails_csrf_protection` al Gemfile para seguridad

## Referencias

- [Documentación de Devise + OmniAuth](https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview)
- [OmniAuth Google OAuth2](https://github.com/zquestz/omniauth-google-oauth2)
- [Testing OmniAuth](https://github.com/omniauth/omniauth/wiki/Integration-Testing)
