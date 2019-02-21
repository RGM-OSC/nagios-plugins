#!/bin/bash

# (C) Copyright 2017 Hewlett Packard Enterprise Development LP

# ----------------------------------------------------------------------------
# Nagios related definitions
# ----------------------------------------------------------------------------

# Folder and binary path definitions generic to Nagios server and client
NAGIOS_BASE_PATH="/usr/local/nagios"
NAGIOS_BIN_PATH="${NAGIOS_BASE_PATH}/bin"

# Folders and binary paths on Nagios Server system
NAGIOS_SERVER_BINARY_PATH="${NAGIOS_BIN_PATH}/nagios"

# Folders and binary paths on Nagios Client system
NAGIOS_NRPE_BINARY_PATH="${NAGIOS_BIN_PATH}/nrpe"
NAGIOS_NRPE_CFG_FILE_PATH="${NAGIOS_BASE_PATH}/etc"
NAGIOS_NRPE_CFG_FILE="${NAGIOS_NRPE_CFG_FILE_PATH}/nrpe.cfg"

# Nagios config file backup suffix
NAGIOS_CLIENT_CFG_BACKUP_SUFFIX=".hpe.backup"
NAGIOS_NRPE_CFG_FILE_BACKUP="${NAGIOS_NRPE_CFG_FILE}${NAGIOS_CLIENT_CFG_BACKUP_SUFFIX}"

# ----------------------------------------------------------------------------
# HPE Nagios definitions
# ----------------------------------------------------------------------------

HPE_CHANGE_BEGIN_TAG="# HPE StoreOnce Nagios configuration - begin"
HPE_CHANGE_END_TAG="# HPE StoreOnce Nagios configuration - end"

HPE_NAGIOS_INSTALL_DIR="/opt/hpe/nagios"
HPE_NAGIOS_PLUGINS_DIR="${HPE_NAGIOS_INSTALL_DIR}/plugins"
HPE_NAGIOS_CONF_DIR="/etc/hpe/nagios"
HPE_NAGIOS_LOG_DIR="/var/log/hpe/nagios"

HPE_NAGIOS_LOG_FILE="/var/log/hpe/nagios/hpe-nagios.log"

mkdir -p /var/log/hpe/nagios
if [ -d /var/log/hpe/nagios ]; then
        touch /var/log/hpe/nagios/hpe-nagios.log
fi

# -----------------------------------------------------------------------------
# Function to remove the HPE NRPE Plugin configuration items
# -----------------------------------------------------------------------------
del_hpe_nrpe_cfg()
{
    if [ -f "${NAGIOS_NRPE_CFG_FILE}" ]; then

        echo "`date` [*] Found Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}" >> "$HPE_NAGIOS_LOG_FILE"
        echo "`date` [*] Found Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}"

        # Delete the HPE Nagios plugin configuration changes from the configuration file
        sed -i "/${HPE_CHANGE_BEGIN_TAG}/,/${HPE_CHANGE_END_TAG}/d"  "${NAGIOS_NRPE_CFG_FILE}"
    else
        echo "`date` [*] ! Did not find expected Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}"  >> "$HPE_NAGIOS_LOG_FILE"
        echo "`date` [*] ! Did not find expected Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}"
    fi
}

# -----------------------------------------------------------------------------
# Function to remove the HPE Nagios Plugin install files
# -----------------------------------------------------------------------------
del_hpe_nagios_installation()
{
    if [ -d "${HPE_NAGIOS_INSTALL_DIR}" ]; then
        echo "`date` [*] Removing HPE StoreOnce Monitoring plugins for Nagios core ..." >> "$HPE_NAGIOS_LOG_FILE"
        echo "`date` [*] Removing HPE StoreOnce Monitoring plugins for Nagios core ..."
        rm -rf ${HPE_NAGIOS_INSTALL_DIR}
    fi

    if [ -d "${HPE_NAGIOS_CONF_DIR}" ]; then
        echo "`date` [*] Removing HPE StoreOnce Monitoring plugin for Nagios configuration ..." >> "$HPE_NAGIOS_LOG_FILE"
        echo "`date` [*] Removing HPE StoreOnce Monitoring plugin for Nagios configuration ..."
        rm -rf ${HPE_NAGIOS_CONF_DIR}
        echo "`date` [*] Uninstallation of HPE StoreOnce Monitoring Plugin for Nagios Core completed successfully"
        echo "`date` [*] Uninstallation of HPE StoreOnce Monitoring Plugin for Nagios Core completed successfully" >> "$HPE_NAGIOS_LOG_FILE"
    fi

}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

# Delete the NRPE configuration file entries
del_hpe_nrpe_cfg

# Delete the HPE Nagios installation files
del_hpe_nagios_installation

exit 0
# -----------------------------------------------------------------------------
# End of file
# -----------------------------------------------------------------------------
