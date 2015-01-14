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

CFG_FILE="${wizard_gasp_dir}\config\synology.virtualhost.conf"

USER="$([ $(grep buildnumber /etc.defaults/VERSION | cut -d"\"" -f2) -ge 4418 ] && echo -n http || echo -n nobody)"

daemon_status ()
{
  if [ -f ${ENABLED_FILE} ]; then
    return
  else
    return 1
  fi

}


case $1 in
  start)
  # create the open base dir configuration
  if [ "${USER}" == "nobody" ]; then
    echo -e "<Directory \"${wizard_gasp_dir}\">\nphp_admin_value open_basedir \${open_basedir}:${wizard_gasp_dir} \n</Directory>" > /usr/syno/etc/sites-enabled-user/zz_${PACKAGE}.conf
  else

    echo -e "open_basedir = \${open_basedir}:${wizard_gasp_dir}" > /etc/php/conf.d/zz_${PACKAGE_NAME}.ini
  fi
  #copy the virtualhost if not present
  if [ ! -f ${VIRTUALHOST_FILE} ]; then
    cp ${CFG_FILE} ${VIRTUALHOST_FILE}
  fi

  # readd the incluse in the apache config
  sed -i -e "s|Include ${VIRTUALHOST_FILE}||g" ${HTTPD_CONFIG_FILE}
  echo "Include ${VIRTUALHOST_FILE}" >> ${HTTPD_CONFIG_FILE}

  #restart the apache user
  if [ "${USER}" == "nobody" ]; then
    /usr/syno/etc/rc.d/S97apache-user.sh restart
  else
    /usr/syno/sbin/synoservicecfg --restart httpd-user
  fi
  exit 0
  ;;

  
  stop)
  # remove the inclusion in apache config file
  sed -i -e "s|Include ${VIRTUALHOST_FILE}||g" ${HTTPD_CONFIG_FILE}
  # delete the openbasedir configuration and restart apache user
  if [ "${USER}" == "nobody" ]; then
    rm -f /usr/syno/etc/sites-enabled-user/zz_${PACKAGE}.conf
    /usr/syno/etc/rc.d/S97apache-user.sh restart
  else
    rm -f /etc/php/conf.d/zz_${PACKAGE_NAME}.ini
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
