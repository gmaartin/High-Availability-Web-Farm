<?php

echo "<h1>SWAP - gmartinsanchez</h1>";

//consultar la IP del servidor apache en el contenedor
$ip_servidor=$_SERVER['SERVER_ADDR'];

echo "<p>La dirección IP del servidor es:  $ip_servidor  </p>";
echo "Límite de memoria: " . ini_get('memory_limit');

?>
