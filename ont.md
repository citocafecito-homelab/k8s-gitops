# Confiugurar tu propio

## 🛠️ Fase 1: Configuración del ONT Stick (Capa de Fibra)

El objetivo es lograr el estado de sincronización O5.

[ ] Extraer GPON SN: Obtén el Serial Number del router original (menú Status > PON o etiqueta).

Nota: Si el stick requiere formato hexadecimal y tu SN empieza por ZTEG, usa 5A544547 seguido de los 8 caracteres restantes.

[ ] Ingresar SN en el Stick: Accede a la interfaz web del stick (usualmente 192.168.1.1 o 192.168.100.1) y guarda el Serial.

[ ] Configurar Vendor ID: Si el stick lo permite, asegúrate de que el Vendor ID coincida con el del router original (ej. ZTEG).

[ ] Verificar Estado O5: Reinicia el stick conectado a la fibra. Entra a su interfaz y confirma que el ONU State sea O5.

Si se queda en O2 o O3: Intenta copiar el "Software Version" del router original al stick.

## 🌐 Fase 2: Configuración del Router (Capa de Red)
El objetivo es obtener IP y salida a internet por el puerto SFP.

[ ] Configurar Puerto SFP: Asegúrate de que la velocidad del puerto esté en "Auto" o forzada a 1Gbps (según soporte tu stick).

[ ] Clonar Dirección MAC: En los ajustes de la interfaz WAN de tu router, cambia la MAC por la de tu equipo original:

MAC a usar: c0:94:ad:23:35:87

[ ] Configurar VLAN: Activa el etiquetado de VLAN en la interfaz WAN.

VLAN ID: 200

Prioridad (802.1p): 0

[ ] Establecer Modo de Conexión: Selecciona DHCP (o IP Dinámica).

[ ] Configurar IPv6 (Opcional): Si deseas mantener IPv6 como en tu captura original, pon el modo en Auto / DHCPv6.

## 🧪 Fase 3: Pruebas de Conectividad
[ ] Validar IP WAN: Verifica en el dashboard de tu router si has recibido una IP (probablemente en el rango 10.x.x.x debido a la CGNAT de Claro).

[ ] Prueba de Ping: Realiza un ping a 8.8.8.8 desde las herramientas de diagnóstico del router.

[ ] MTU Check: Asegúrate de que el MTU esté en 1500. Si notas que algunas páginas no cargan, prueba bajándolo a 1492.

## ⚠️ Recordatorio Importante
Como vimos en tu captura de WAN Connection Status, tu IP es privada (10.34.185.233). Al pasar al ONT Stick:

Seguirás bajo CGNAT (no podrás abrir puertos hacia internet fácilmente sin usar herramientas como Tailscale o Cloudflare Tunnels).

Tendrás el control total del hardware, eliminando el router del operador de la ecuación.