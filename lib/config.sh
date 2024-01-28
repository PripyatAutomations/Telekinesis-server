# Allow accessing contents of the config.yaml
CF=/opt/netrig/etc/netrig.yaml

# Generate a json version
#CF_JSON=/opt/netrig/run/netrig.json

#cat ${CF} | yq > ${CF_JSON} || {
#   echo "invalid configuration at ${CF}, bailing"
#   exit 1
#}

CF_VAL=""

get_val() {
   CF_VAL=$(cat ${CF} | yq $1)
   # remove outer quotes if present
   temp="${CF_VAL%\"}"
   temp="${temp#\"}"
   CF_VAL=$temp
   return $?
}
