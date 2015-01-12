#!/bin/sh

# Package
PACKAGE="gaspSync"
DNAME="gaspSync"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
WEB_DIR="${wizard_gasp_dir}/web"

ENABLED_FILE="/var/packages/${PACKAGE}/enabled"

VIRTUALHOST_FILE="/etc/httpd/conf/extra/httpd-${PACKAGE}.conf-user"
HTTPD_CONFIG_FILE="/etc/httpd/conf/httpd.conf-user"

USER="$([ $(grep buildnumber /etc.defaults/VERSION | cut -d"\"" -f2) -ge 4418 ] && echo -n http || echo -n nobody)"

daemon_status ()
{
    if [ -f ${ENABLED_FILE} ]; then
        return
    fi
    return 1
}


case $1 in
    start)
		sed -i -e "s|Include ${VIRTUALHOST_FILE}||g" ${HTTPD_CONFIG_FILE}
		echo "Include ${VIRTUALHOST_FILE}" >> ${HTTPD_CONFIG_FILE}
		if [ "${USER}" == "nobody" ]; then
			/usr/syno/etc/rc.d/S97apache-user.sh restart
		else
			/usr/syno/sbin/synoservicecfg --restart httpd-user
		fi
        exit 0
        ;;
    stop)
		sed -i -e "s|Include ${VIRTUALHOST_FILE}||g" ${HTTPD_CONFIG_FILE}
		if [ "${USER}" == "nobody" ]; then
			/usr/syno/etc/rc.d/S97apache-user.sh restart
		else
			/usr/syno/sbin/synoservicecfg --restart httpd-user
		fi
		
        exit 0
        ;;
    status)
        if daemon_status; then
            echo ${DNAME} is running
            exit 0
        else
            echo ${DNAME} is not running
            exit 1
        fi
        ;;
    log)
        exit 1
        ;;
    *)
        exit 1
        ;;
esac
