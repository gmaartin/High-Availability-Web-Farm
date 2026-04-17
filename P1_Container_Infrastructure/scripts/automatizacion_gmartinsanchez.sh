#!/bin/bash

# --- PASO 0: Arrancar la infraestructura ---
echo "--- Levantando infraestructura con Docker Compose ---"
# -d para que corra en segundo plano y podamos seguir con el script
sudo docker compose up -d

echo "Esperando 5 segundos a que los servicios inicien..."
sleep 5

CONTENEDORES=("web1" "web2" "web3" "web4" "web5" "web6" "web7" "web8")

echo "--- Iniciando limpieza y chequeo de salud post-arranque ---"

for c in "${CONTENEDORES[@]}"; do
    echo ">> Analizando $c..."

    # 1. Detectar qué servidor está corriendo
    if docker exec $c [ -d /etc/apache2 ]; then
        TIPO="Apache"
        LOG="/var/log/apache2/access.log"
    elif docker exec $c [ -d /etc/nginx ]; then
        TIPO="Nginx"
        LOG="/var/log/nginx/access.log"
    elif docker exec $c [ -d /etc/lighttpd ]; then
        TIPO="Lighttpd"
        LOG="/var/log/lighttpd/access.log"
    else
        TIPO="Desconocido"
    fi

    echo "   [Tipo: $TIPO]"

    # 2. Limpieza de logs (para empezar cada sesión con logs limpios)
    if [ "$TIPO" != "Desconocido" ]; then
        docker exec $c sh -c "truncate -s 0 $LOG 2>/dev/null"
        echo "   [OK] Log $LOG vaciado."
    fi

    # 3. Monitoreo de salud
    STATUS=$(docker exec $c curl -s -o /dev/null -w "%{http_code}" localhost 2>/dev/null)

    if [[ "$STATUS" == "200" || "$STATUS" == "403" || "$STATUS" == "404" ]]; then
        echo "   [OK] Salud: Funcionando (Status: $STATUS)"
    else
        echo "   [ALERTA] Salud: Posible caída o inicio lento (Status: ${STATUS:-"Error"})"
    fi
done

echo "--- Infraestructura lista para trabajar ---"
