kubectl get deployment -A -l tier=disposable --no-headers | awk '{print $1, $2}' | while read -r ns name; do
  if [ ! -z "$ns" ] && [ ! -z "$name" ]; then
    echo "Apagando $ns/$name..."
    kubectl scale deployment "$name" -n "$ns" --replicas=0 </dev/null
  fi
done

echo "----------------------------------------"

kubectl get nodes -l tier=disposable --no-headers -o custom-columns=NAME:.metadata.name | while read -r nodo; do
  if [ ! -z "$nodo" ]; then
    echo "Preparando el nodo $nodo para el apagado..."
    
    kubectl cordon "$nodo"
    kubectl drain "$nodo" --ignore-daemonsets --delete-emptydir-data --force
    
    echo "Enviando comando de apagado a $nodo..."
    ssh -o ConnectTimeout=5 "barista@$nodo" "sudo /sbin/shutdown -h now" 2>/dev/null || echo "Nodo $nodo fuera de línea o comando enviado."
  fi
done