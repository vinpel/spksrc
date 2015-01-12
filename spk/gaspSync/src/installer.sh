#!/bin/sh

# Package
PACKAGE="gaspSync"
DNAME="gaspSync"
PACKAGE_NAME="com.synocommunity.packages.${PACKAGE}"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"


WEB_DIR="${wizard_gasp_dir}/web"

# config file for ./yii install
DEFAULT_CFG_FILE="/usr/local/${PACKAGE}/init.synology.init.php"
CFG_FILE="${wizard_gasp_dir}/config/local.init.php"

# virtual host definition
DEFAULT_VIRTUALHOST_FILE="/usr/local/${PACKAGE}/init.synology.virtualhost.conf"
VIRTUALHOST_FILE="/etc/httpd/conf/extra/httpd-${PACKAGE}.conf-user"


# file where we will includ the virtual host configuration
# we can't use the default insert :
#		<VirtualHost *:80>
#		    Include sites-enabled-user/*.conf
#		</VirtualHost>
# cause we use another port. 
HTTPD_CONFIG_FILE="/etc/httpd/conf/httpd.conf-user"

USER="$([ $(grep buildnumber /etc.defaults/VERSION | cut -d"\"" -f2) -ge 4418 ] && echo -n http || echo -n nobody)"

preinst ()
{
    exit 0
}


postinst ()
{
    # Link
    ln -s ${SYNOPKG_PKGDEST} ${INSTALL_DIR}

    # Install the web interface
    cp -pR ${INSTALL_DIR}/share/${PACKAGE} ${wizard_gasp_dir}
	
    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
        # Configure open_basedir
		# the name zz_ is for loading AFTER user-setting cause we touch the global openbasedir
		# need to be tested for DSM 4.3 ...
		
        if [ "${USER}" == "nobody" ]; then
            echo -e "<Directory \"${wizard_gasp_dir}\">\nphp_admin_value open_basedir \${open_basedir}:${wizard_gasp_dir} \n</Directory>" > /usr/syno/etc/sites-enabled-user/zz_${PACKAGE}.conf
        else
			
            echo -e "open_basedir = \${open_basedir}:${wizard_gasp_dir}" > /etc/php/conf.d/zz_${PACKAGE_NAME}.ini
        fi


        # Create a default configuration file init.synology.init.php => local.init.php
        if [ ! -f ${CFG_FILE} ]; then
          cp ${DEFAULT_CFG_FILE} ${CFG_FILE}
		  sed -i -e "s|@wizard_gasp_port@|${wizard_gasp_port:=4000}|g" ${CFG_FILE}
		  sed -i -e "s|@wizard_calibre_hostname@|${wizard_calibre_hostname:=locahost}|g" ${CFG_FILE}
		  sed -i -e "s|@wizard_gasp_dbhost@|${wizard_gasp_dbhost}|g" ${CFG_FILE}
		  sed -i -e "s|@wizard_gasp_dbname@|${wizard_gasp_dbname}|g" ${CFG_FILE}
		  sed -i -e "s|@wizard_gasp_dblogin@|${wizard_gasp_dblogin}|g" ${CFG_FILE}
          sed -i -e "s|@wizard_gasp_dbpassword@|${wizard_gasp_dbpassword}|g" ${CFG_FILE}
          chmod ga+w ${CFG_FILE}
        fi
		echo "DEFAULT_VIRTUALHOST_FILE" > /volume1/monbootstrap/test.tst
		#  copy and edit the virtual-host configuration
		if [ ! -f ${VIRTUALHOST_FILE} ]; then
          cp ${DEFAULT_VIRTUALHOST_FILE} ${VIRTUALHOST_FILE}
		  sed -i -e "s|@wizard_gasp_port@|${wizard_gasp_port:=}|g" ${VIRTUALHOST_FILE}
		  sed -i -e "s|@wizard_calibre_hostname@|${wizard_calibre_hostname:=}|g" ${VIRTUALHOST_FILE}
		  # the public directory is the Web directory (warning name are different)
		  sed -i -e "s|@wizard_gasp_dir@|${WEB_DIR}|g" ${VIRTUALHOST_FILE}
          chmod ga+w ${VIRTUALHOST_FILE}
        fi
		# Add the virtual host to the Apache user config
		
			# if the user check "launch after install" it will launch, no need to strange behaviour
		# remove if already installed
		#sed -i -e "s|Include ${VIRTUALHOST_FILE}||g" ${HTTPD_CONFIG_FILE}
		# add / readd the inclusion 
		#echo "Include ${VIRTUALHOST_FILE}" >> ${HTTPD_CONFIG_FILE}
		
		
		
		sed -i -e "s|Include /etc/httpd/conf/extra/httpd-gaspSync.conf-user||g"
		

		# perform install
		${wizard_gasp_dir}/yii install/synology
		# create database
		# ${wizard_gasp_dir}/yii migrate --interactive=0 
		
		# Set permissions
        chown ${USER} ${wizard_gasp_dir} -R
    fi

    exit 0
}

preuninst ()
{
    exit 0
}

postuninst ()
{
    # Remove install dir
    rm -Rf ${wizard_gasp_dir}

    # Remove open_basedir configuration
    rm -f /usr/syno/etc/sites-enabled-user/zz_${PACKAGE}.conf
    rm -f /etc/php/conf.d/zz_${PACKAGE_NAME}.ini
	
	# remove virtualhost configuration
	rm -f ${VIRTUALHOST_FILE}
	sed -i -e "s|Include ${VIRTUALHOST_FILE}||g" ${HTTPD_CONFIG_FILE}
    exit 0
}

preupgrade ()
{
    # Save some stuff
    #rm -fr ${TMP_DIR}/${PACKAGE}
#    mkdir -p ${TMP_DIR}/${PACKAGE}
    #mv ${CFG_FILE} ${TMP_DIR}/${PACKAGE}/
    #if [ "${USER}" == "nobody" ]; then
    #    mv /usr/syno/etc/sites-enabled-user/${PACKAGE}.conf ${TMP_DIR}/${PACKAGE}/
    #else
        #mv /etc/php/conf.d/${PACKAGE_NAME}.ini ${TMP_DIR}/${PACKAGE}/
    #fi
    exit 0
}

postupgrade ()
{
    # Restore some stuff
    #rm -f ${CFG_FILE}
    #mv ${TMP_DIR}/${PACKAGE}/config_local.php ${CFG_FILE}
    #mv ${TMP_DIR}/${PACKAGE}/${PACKAGE}.conf /usr/syno/etc/sites-enabled-user
    ##mv ${TMP_DIR}/${PACKAGE}/${PACKAGE_NAME}.ini /etc/php/conf.d/
    #rm -fr ${TMP_DIR}/${PACKAGE}

    exit 0
}
