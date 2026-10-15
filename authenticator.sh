#!/bin/bash
source menu.sh

if [[ ! -f ".settings.json" ]]; then
  echo -e "${P}Settings file missing, initializing...${N}"
  echo '[]' > .settings.json
fi

codelist() {
  fail "Not yet implemented"
}

addaccount() {
  fail "Not yet implemented"
}

removeaccount() {
  fail "Not yet implemented"
}

backup() {
  fail "Not yet implemented"
}

restore() {
  fail "Not yet implemented"
}

menu_reset() {
  options=("${Y}Show OTP code list ${D}(hidden for security)${N}" "${B}Add an OTP account${N}" "${R}Remove an existing OTP account${N}" "${G}Back up settings${N}" "${B}Restore settings backup${N}" "Exit")
  functions=("codelist" "addaccount" "removeaccount" "backup" "restore" "quit")
  menuText=$(cat <<EOF
${P}+##############################################+
| ${B}Coolest${G}Auth${P}                                  |
| -------------------------------------------- |
| Simple terminal OTP authenticator            |
+##############################################+${N}
EOF
  )
  num_options=${#options[@]}
}

menu_reset
clear
full_menu
tput cnorm
selector