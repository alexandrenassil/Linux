# CentOS 7
#!/bin/bash
#
# instalacao_pacotes.sh - Instalador de pacotes CentOS
#
# Author: Alexandre Nascimento da Silva
# Maintance: Alexandre Nascimento da Silva
#
# ------------------------------------------------------------------- #
# WHAT IT DOES?
# Este script instala os pacotes de funcoes necessarios para rodar sistemas no servidor CentOS
#
# CONFIGURATION:
# o arquivo dos pacotes necessarios para instalacao e "functions_patch.txt", utilizar este caso seja necessario inserir, excluir ou alterar algum pacote
#
# HOW TO USE IT?
# Examples:
# $ ./instalacao_pacotes.sh
#
# LOG_FILE
# mysql_install.log
#
#
# ################################################################### #

. mysql_install.conf

ARQUIVO=$FUNCTIONS_PATCH

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* Iniciando instalacao dos pacotes" >> $LOG_FILE 2>&1
while IFS= read -r LINHA || [[ -n "$LINHA" ]]; do
    yum -y install $LINHA >> $LOG_FILE 2>&1
done < "$ARQUIVO"

#USERS=$MYSQL_USERS
#while IFS= read -r LINHA; do
   # USERAKV=$LINHA
   # PASS=$(awk '{print $1}')
   # echo $PASS
    #mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO '$USER'@'%' IDENTIFIED BY '$PASS'; alter user '$USER'@'%' identified by '$PASS'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
#done < "$USERS"

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* Finalizando instalacao dos pacotes" >> $LOG_FILE 2>&1
