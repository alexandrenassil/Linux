# CentOS 7
#!/bin/bash
#
# mysql_install.sh - Instalador do MySQL
#
# Author: Alexandre Nascimento da Silva
# Maintance: Alexandre Nascimento da Silva
#
# ------------------------------------------------------------------- #
# Este script instala e configura o MySQL
#
# CONFIGURATION:
# Arquivo de configuracao mysql_install.conf, necessario que o servidor CentOS 7 esteja devidamente configurado
#
# HOW TO USE IT?
# Examples:
# $ ./mysql_install.sh
#
# LOG_FILE
# mysql_install.log
#
#
# ------------------------------------------------------------------- #
#
#	v1.0 2021-09-03, Alexandre Nascimento da Silva:
#   	- Versão inicial do instalador
#	v1.1 2021-09-16, Alexandre Nascimento da Silva:
#		- Corrigido bug de configurações
#
#
# ################################################################### #

# Arquivo de configuracao
. mysql_install.conf

# instalacao dos pacotes de funcoes do servidor CentoOS 7
chmod +x instalacao_pacotes.sh
./instalacao_pacotes.sh

# Download do sistema MySQL
echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 1/16 - Iniciando Download dos pacotes do Mysql" >> $LOG_FILE 2>&1
wget -P /root https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-common-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1
wget -P /root https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-libs-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1
wget -P /root https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1
wget -P /root https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-libs-compat-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1
wget -P /root https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-server-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1

# Pastas de FTP Akiva
echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 2/16 - Criando as pastas do FTP" >> $LOG_FILE 2>&1
mkdir $FTP_AVIKA >> $LOG_FILE 2>&1
mkdir $FTP_AVIKA/$FTP_BLACKLIST >> $LOG_FILE 2>&1
mkdir $FTP_AVIKA/$FTP_MAILINGS >> $LOG_FILE 2>&1
chmod -R 777 $FTP_AVIKA >> $LOG_FILE 2>&1

# Arquivo mytop padrao akiva
echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 3/16 - Copiando o arquivo mytop" >> $LOG_FILE 2>&1
cp -f $MYTOP $MYSQL_TOP >> $LOG_FILE 2>&1

# Configuracao de alguns arquivos do CentOS
echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 4/16 - Configurando servidor CentOS" >> $LOG_FILE 2>&1
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config >> $LOG_FILE 2>&1
setenforce 0 >> $LOG_FILE 2>&1
NOLOGIN=$(tail -n 1 /etc/shells)
if [ $NOLOGIN -ne "/usr/sbin/nologin" ]; then
	echo "/usr/sbin/nologin" >> /etc/shells >> $LOG_FILE 2>&1
fi

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 5/16 - Removendo instalacao do MariaDB" >> $LOG_FILE 2>&1
MARIADB=$(rpm -qa | grep mariadb)
if [ -z $MARIADB ]; then
	rpm -e --nodeps $($MARIADB) >> $LOG_FILE 2>&1
fi

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 6/16 - Desabilitando firewall" >> $LOG_FILE 2>&1
systemctl disable firewalld >> $LOG_FILE 2>&1
systemctl start chronyd >> $LOG_FILE 2>&1
systemctl disable chronyd >> $LOG_FILE 2>&1

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 7/16 - Iniciando a instalacao do MySql" >> $LOG_FILE 2>&1
rpm -ivh /root/mysql-community-common-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1
rpm -ivh /root/mysql-community-libs-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1
rpm -ivh /root/mysql-community-client-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1
rpm -ivh /root/mysql-community-libs-compat-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1
rpm -ivh /root/mysql-community-server-5.7.30-1.el7.x86_64.rpm >> $LOG_FILE 2>&1

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 8/16 - Copiando arquivo my.cnf" >> $LOG_FILE 2>&1
systemctl disable mysqld >> $LOG_FILE 2>&1
cp -f $MYCNF $MYSQL_CNFF >> $LOG_FILE 2>&1
systemctl start mysqld >> $LOG_FILE 2>&1

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 9/16 - Configurando my.cnf" >> $LOG_FILE 2>&1

sed -i "s/#validate_password_policy = 0/validate_password_policy = 0/g" $MYSQL_CNFF >> $LOG_FILE 2>&1
sed -i "s/innodb_buffer_pool_size = 100M/innodb_buffer_pool_size = $INNO_BUFFER_POOL_SIZE/g" $MYSQL_CNFF >> $LOG_FILE 2>&1
sed -i "s/innodb_log_file_size = 100M/innodb_log_file_size = $INNODB_LOG_FILE_SIZE/g" $MYSQL_CNFF >> $LOG_FILE 2>&1
sed -i "s/innodb_log_files_in_group = 2/innodb_log_files_in_group = $INNODB_LOG_FILES_IN_GROUP/g" $MYSQL_CNFF >> $LOG_FILE 2>&1

systemctl restart mysqld >> $LOG_FILE 2>&1

sed -i "s/LimitNOFILE = 5000/LimitNOFILE=infinity/g" /lib/systemd/system/mysqld.service >> $LOG_FILE 2>&1
for i in /lib/systemd/system/mysqld.service ; do sed -i "61s/^/LimitMEMLOCK=infinity\n/" $i ; done >> $LOG_FILE 2>&1
systemctl daemon-reload >> $LOG_FILE 2>&1

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 10/16 - Copiando arquivo FULL" >> $LOG_FILE 2>&1
cp -f $MYSQL_DUMP_FULL /root >> $LOG_FILE 2>&1
echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 11/16 - Copiando arquivo ROUTINES" >> $LOG_FILE 2>&1
cp -f $MYSQL_DUMP_ROUTINES /root >> $LOG_FILE 2>&1

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 12/16 - Pegando senha provisoria do MySQL" >> $LOG_FILE
TMPPASSWD=$(grep password /var/lib/mysql/mysql-error.log | awk '{print $11}' | head -n 1) >> $LOG_FILE 2>&1

echo "*************** Temp password mysql ***************" >> $LOG_FILE 2>&1
echo $TMPPASSWD >> $LOG_FILE 2>&1
echo "*************** ******************* ***************" >> $LOG_FILE 2>&1

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 13/16 - Alterando senha root MySQL" >> $LOG_FILE 2>&1
mysql -u root -p$TMPPASSWD --connect-expired-password -e "ALTER USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASS'; update mysql.user set Host='%' where user = '$MYSQL_USER'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 14/16 - Definindo privilegions para os usuarios do sistema Akiva" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'manager'@'%' IDENTIFIED BY 'xcallmanbd'; alter user 'manager'@'%' identified by 'xcallmanbd'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'report'@'%' IDENTIFIED BY 'xcallrepbd'; alter user 'report'@'%' identified by 'xcallrepbd'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'agente'@'%' IDENTIFIED BY 'xcallagebd'; alter user 'agente'@'%' identified by 'xcallagebd'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'supervisor'@'%' IDENTIFIED BY 'xcallsupbd'; alter user 'supervisor'@'%' identified by 'xcallsupbd'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
ysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'portal'@'%' IDENTIFIED BY 'xcallporbd'; alter user 'portal'@'%' identified by 'xcallporbd'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'pabx'@'%' IDENTIFIED BY 'xcallpbxbd'; alter user 'pabx'@'%' identified by 'xcallpbxbd'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'tarifador'@'%' IDENTIFIED BY 'xcalltarbd'; alter user 'tarifador'@'%' identified by 'xcalltarbd'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'webmanager'@'%' IDENTIFIED BY 'xcallwebbd2016'; alter user 'webmanager'@'%' identified by 'xcallwebbd2016'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'discador'@'%' IDENTIFIED BY 'xcalldialerbd2016'; alter user 'discador'@'%' identified by 'xcalldialerbd2016'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON *.* TO 'events_akiva'@'%' IDENTIFIED BY 'xcallevebd2016'; alter user 'events_akiva'@'%' identified by 'xcallevebd2016'; FLUSH PRIVILEGES;" >> $LOG_FILE 2>&1

mysql -u $MYSQL_USER -p$MYSQL_PASS -e "select @@log_bin_trust_function_creators;" >> $LOG_FILE 2>&1
mysql -u $MYSQL_USER -p$MYSQL_PASS -e "set global log_bin_trust_function_creators = 1;" >> $LOG_FILE 2>&1

echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 15/16 - Extraindo arquivos FULL para o MySQL" >> $LOG_FILE 2>&1
gunzip < $MYSQL_DUMP_FULL | mysql -u $MYSQL_USER -p$MYSQL_PASS >> $LOG_FILE 2>&1
echo `date +%Y-%m-%d_%H:%M:%S`" ********************************* 16/16 - Extraindo arquivos ROUTINES para o MySQL" >> $LOG_FILE 2>&1
gunzip < $MYSQL_DUMP_ROUTINES | mysql -u $MYSQL_USER -p$MYSQL_PASS >> $LOG_FILE 2>&1

echo `date +%Y-%m-%d_%H:%M:%S`" - ****************************** Checklist ******************************" >> $LOG_FILE 2>&1
cat /proc/sys/vm/swappiness >> $LOG_FILE 2>&1 # Resultado tem que ser 0
systemctl status firewalld >> $LOG_FILE 2>&1 # Tem que estar INATIVO
systemctl status vsftpd >> $LOG_FILE 2>&1 # Tem que estar ATIVO
systemctl status mysqld >> $LOG_FILE 2>&1 # Tem que estar ATIVO
systemctl status chronyd >> $LOG_FILE 2>&1 # Tem que estar INATIVO
timedatectl >> $LOG_FILE 2>&1 # Tem que estar America/Sao_Paulo e o horário correto !! ATENÇÃO PARA LUGARES DE OUTRO ESTADO
sestatus >> $LOG_FILE 2>&1 # tem que estar DISABLED, so sera desabilitado apos reiniciar o servidor

echo `date +%Y-%m-%d_%H:%M:%S`" - ****************************** - Instalacao Finalizada - ******************************" >> $LOG_FILE 2>&1

echo "***************************************************************"
echo "É necessario reiniciar o servidor para ativar as configurações"
echo "***************************************************************"

# Loop com a condição para reiniciar o servidor com validação de caractere 
# (y = init 6,n = CTRL + c, * = loop de opcao invalida)
while :;
do
	echo "Deseja reinicar o servidor agora? (y/n)"
	read OPTION
	case $OPTION in
		y)
			echo "Reiniciando o servidor agora!"
			echo "Apos reiniciar, configurar o arquivo my.cnf com relacao ao POS_DUMP!"
			init 6
			;;

		n)
			break
			;;
		*)
			echo "Opcao invalida!"
			;;
	esac
done
