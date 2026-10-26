$ErrorActionPreference = 'Stop'
Set-Location (Split-Path -Parent $PSScriptRoot)
Write-Host 'Importando credencial DeepSeek y flujo del laboratorio...' -ForegroundColor Cyan
docker compose exec -T n8n node /plantillas/provisionar.mjs
if ($LASTEXITCODE -ne 0) { throw 'No se pudo importar la credencial o el flujo. Comprueba tu .env y los logs.' }
docker compose restart n8n
if ($LASTEXITCODE -ne 0) { throw 'No se pudo reiniciar n8n.' }
Write-Host 'Hecho. Abre http://localhost:5678 y busca LAB3 | Agente aduanero DeepSeek | Chat.' -ForegroundColor Green

