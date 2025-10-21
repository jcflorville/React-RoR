# 🧪 Teste Manual - Refresh Token

## Passo 1: Limpar storage do navegador

1. Abra o DevTools (F12)
2. Vá em Application > Local Storage
3. Delete todas as chaves relacionadas a auth
4. Recarregue a página

## Passo 2: Fazer Login

1. Faça login na aplicação
2. No DevTools, na aba Network, procure o request `sign_in`
3. Verifique a resposta:
   - **Header Authorization**: Deve ter o access token
   - **Body refresh_token**: Deve ter o refresh token

**Exemplo esperado:**
```json
{
  "success": true,
  "data": { "id": 1, "email": "...", "name": "..." },
  "refresh_token": "eyJhbGc...",
  "message": "Logged in successfully"
}
```

## Passo 3: Verificar Tokens no Console

Abra o console e execute:
```javascript
localStorage.getItem('auth-storage')
```

Você deve ver algo como:
```json
{
  "state": {
    "user": {...},
    "token": "eyJ...",
    "refreshToken": "eyJ...",
    "isAuthenticated": true
  }
}
```

## Passo 4: Forçar Expiração (Temporária)

### Opção A - Mudar tempo de expiração (RECOMENDADO)

1. No backend, edite `config/initializers/devise.rb`
2. Mude temporariamente:
   ```ruby
   jwt.expiration_time = 1.minute.to_i  # era 15.minutes
   ```
3. Reinicie backend: `docker compose restart backend`
4. Faça logout e login novamente
5. Espere 1 minuto
6. Tente acessar qualquer página (ex: /projects)

### Opção B - Invalidar token manualmente

Execute no console do navegador:
```javascript
// Pegar o store atual
const currentState = JSON.parse(localStorage.getItem('auth-storage'))

// Invalidar o access token (manter refresh token)
currentState.state.token = 'token-invalido'

// Salvar
localStorage.setItem('auth-storage', JSON.stringify(currentState))

// Recarregar página
location.reload()
```

## Passo 5: Verificar Renovação Automática

Com o DevTools Network aberto:

1. Tente acessar `/projects` ou qualquer rota protegida
2. Você deve ver esta sequência:
   - `GET /projects` → **401 Unauthorized**
   - `POST /auth/refresh` → **200 OK**
   - `GET /projects` → **200 OK** (retry automático)

## Passo 6: Verificar Console Logs

No console do navegador, você deve ver logs como:
```
🔍 Refreshing token...
✅ Token refreshed successfully
🔄 Retrying original request...
```

## ✅ Teste Bem Sucedido

Se tudo funcionou:
- ✅ Token foi renovado automaticamente
- ✅ Request original foi retentado com sucesso
- ✅ Usuário não percebeu nada (UX transparente)
- ✅ Nenhum redirect para login

## ❌ Se Não Funcionou

Verifique:

1. **Console do navegador**: Erros JavaScript?
2. **Network tab**: 
   - Request `refresh` retorna 200?
   - Tem header `Authorization` no response?
   - Tem `refresh_token` no body?
3. **Backend logs**: Erros no Rails?

Cole os logs aqui para debug!

## 🔍 Debug Adicional

Execute no console:
```javascript
// Ver estado atual do auth store
console.log(useAuthStore.getState())

// Ver tokens
console.log('Access Token:', localStorage.getItem('auth_token'))
console.log('Refresh Token:', localStorage.getItem('refresh_token'))
```
