#!/bin/bash

# colores para que la salida sea más legible
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo -e "${BLUE}=== Monitoreo SWAP - $DATE ===${NC}"

for i in {1..8}; do
    NAME="web$i"

    #obtener uso de CPU y memoria desde las estadisticas de Docker
    # --no-stream para que de el dato continue y no se quede bloqueado
    STATS=$(docker stats $NAME --no-stream --format "{{.CPUPerc}} | {{.MemUsage}}")

    # comprobar si el puerto 80 esta escuchando internamente
    #si netstat falla (porque no existe o no hay red), devolvera ERROR
    #-tln es para t->buscar conexiones TCP, l->mostrar los puertos que estan escuchando, n->muestra los numeros del puerto en vez de nombres
    #/dev/null es para tirar lineas de errores por no tener instalado netstat y cosas asi que no me interesan
    LISTEN=$(docker exec $NAME netstat -tln 2>/dev/null | grep :80 > /dev/null && echo -e "${GREEN}Escuchando${NC}" || echo -e "ERROR")

    # sacar el resultado por pantalla
    echo -e "[${BLUE}$NAME${NC}] CPU/RAM: $STATS | Puerto 80: $LISTEN"
done

echo "------------------------------------------------"
echo "Monitoreo completado visualmente."
