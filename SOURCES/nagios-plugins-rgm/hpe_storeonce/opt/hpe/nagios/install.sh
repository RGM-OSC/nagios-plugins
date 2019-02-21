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

# -----------------------------------------------------------------------------
# HPE Nagios content to add to the existing Nagios Client system
# -----------------------------------------------------------------------------

HPE_CHANGE_BEGIN_TAG="# HPE StoreOnce Nagios configuration - begin\n"
HPE_CHANGE_END_TAG="# HPE StoreOnce Nagios configuration - end\n"


# Enable no blame
HPE_NAGIOS_DONT_BLAME="dont_blame_nrpe=1"

# HPE Nagios commands to add
HPE_NAGIOS_SCRIPT_BASE_PATH="/opt/hpe/nagios/plugins"

HPE_NAGIOS_CMD_1_NAME="hardwareCompStatus_python"
HPE_NAGIOS_CMD_1_PROGRAM="${HPE_NAGIOS_SCRIPT_BASE_PATH}/hardwareCompStatus.py"

HPE_NAGIOS_CMD_2_NAME="serviceSetHealth_python"
HPE_NAGIOS_CMD_2_PROGRAM="${HPE_NAGIOS_SCRIPT_BASE_PATH}/serviceSetHealth.py"

HPE_NAGIOS_CMD_3_NAME="systemHealthCapacity_python"
HPE_NAGIOS_CMD_3_PROGRAM="${HPE_NAGIOS_SCRIPT_BASE_PATH}/systemHealthCapacity.py"

HPE_NAGIOS_CMD_4_NAME="vtlThroughputReport_python"
HPE_NAGIOS_CMD_4_PROGRAM="${HPE_NAGIOS_SCRIPT_BASE_PATH}/vtlThroughputReport.py"

HPE_NAGIOS_CMD_5_NAME="vtlStorageReport_python"
HPE_NAGIOS_CMD_5_PROGRAM="${HPE_NAGIOS_SCRIPT_BASE_PATH}/vtlStorageReport.py"

# NRPE CFG - command lines
NRPE_CFG_ENTRY_1="command[${HPE_NAGIOS_CMD_1_NAME}]=${HPE_NAGIOS_CMD_1_PROGRAM} \$ARG1$ \$ARG2$ \$ARG3$ -t 300"
NRPE_CFG_ENTRY_2="command[${HPE_NAGIOS_CMD_2_NAME}]=${HPE_NAGIOS_CMD_2_PROGRAM} \$ARG1$ \$ARG2$ \$ARG3$ -t 300"
NRPE_CFG_ENTRY_3="command[${HPE_NAGIOS_CMD_3_NAME}]=${HPE_NAGIOS_CMD_3_PROGRAM} \$ARG1$ \$ARG2$ \$ARG3$ -t 300"
NRPE_CFG_ENTRY_4="command[${HPE_NAGIOS_CMD_4_NAME}]=${HPE_NAGIOS_CMD_4_PROGRAM} \$ARG1$ \$ARG2$ \$ARG3$ -t 300"
NRPE_CFG_ENTRY_5="command[${HPE_NAGIOS_CMD_5_NAME}]=${HPE_NAGIOS_CMD_5_PROGRAM} \$ARG1$ \$ARG2$ \$ARG3$ -t 300"

HPE_NAGIOS_LOG_FILE="/var/log/hpe/nagios/hpe-nagios.log"

mkdir -p /var/log/hpe/nagios
if [ -d /var/log/hpe/nagios ]; then
        touch /var/log/hpe/nagios/hpe-nagios.log
fi

# -----------------------------------------------------------------------------
# Function to add the HPE NRPE Plugin configuration items
# -----------------------------------------------------------------------------
add_hpe_nrpe_cfg()
{
    if [ -f "${NAGIOS_NRPE_CFG_FILE}" ]; then

        echo "`date` [*] Found Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}"
        echo "`date` [*] Found Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}" >> "$HPE_NAGIOS_LOG_FILE"

        # Take backup of exisitng file
        cp "${NAGIOS_NRPE_CFG_FILE}" "${NAGIOS_NRPE_CFG_FILE_BACKUP}"
        echo "`date` [*] Created backup of existing configuration at ${NAGIOS_NRPE_CFG_FILE_BACKUP}"
        echo "`date` [*] Created backup of existing configuration at ${NAGIOS_NRPE_CFG_FILE_BACKUP}" >> "$HPE_NAGIOS_LOG_FILE"

        # Add the HPE Nagios plugin configuration changes to the configuration file
        echo -e "\n" >> "${NAGIOS_NRPE_CFG_FILE}"
        echo -e "${HPE_CHANGE_BEGIN_TAG}" >> "${NAGIOS_NRPE_CFG_FILE}"

        echo "${HPE_NAGIOS_DONT_BLAME}" >> "${NAGIOS_NRPE_CFG_FILE}"

        echo -e "\n" >> "${NAGIOS_NRPE_CFG_FILE}"
        echo -e "# HPE Nagios plugin command entries\n" >> "${NAGIOS_NRPE_CFG_FILE}"

        echo ${NRPE_CFG_ENTRY_1} >> "${NAGIOS_NRPE_CFG_FILE}"
        echo ${NRPE_CFG_ENTRY_2} >> "${NAGIOS_NRPE_CFG_FILE}"
        echo ${NRPE_CFG_ENTRY_3} >> "${NAGIOS_NRPE_CFG_FILE}"
        echo ${NRPE_CFG_ENTRY_4} >> "${NAGIOS_NRPE_CFG_FILE}"
        echo ${NRPE_CFG_ENTRY_5} >> "${NAGIOS_NRPE_CFG_FILE}"

        echo -e "\n" >> "${NAGIOS_NRPE_CFG_FILE}"
        echo -e "${HPE_CHANGE_END_TAG}" >> "${NAGIOS_NRPE_CFG_FILE}"
    else
        echo "`date` [*] ! Did not find expected Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}"
        echo "`date` [*] ! Did not find expected Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}" >> "$HPE_NAGIOS_LOG_FILE"

    fi
}

# -----------------------------------------------------------------------------
# Function to remove the HPE NRPE Plugin configuration items
# -----------------------------------------------------------------------------
del_hpe_nrpe_cfg()
{
    if [ -f "${NAGIOS_NRPE_CFG_FILE}" ]; then

        echo "`date` [*] Found Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}"
        echo "`date` [*] Found Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}" >> "$HPE_NAGIOS_LOG_FILE"

        # Delete the HPE Nagios plugin configuration changes from the configuration file
        sed -i "/${HPE_CHANGE_BEGIN_TAG}/,/${HPE_CHANGE_END_TAG}/d"  "${NAGIOS_NRPE_CFG_FILE}"
    else
        echo "`date` [*] ! Did not find expected Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}"
        echo "`date` [*] ! Did not find expected Nagios NRPE configuration at ${NAGIOS_NRPE_CFG_FILE}" >> "$HPE_NAGIOS_LOG_FILE"
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

# Check if this RPM is being run on a Nagios server installation or Nagios client installation
flag_nagios_server=0
flag_nagios_client=0
flag_nagios_client_cfg=0
flag_install_failed=0

# Check for Nagios server and set flag
if [ -f "${NAGIOS_SERVER_BINARY_PATH}" ]; then
    flag_nagios_server=1
else
    flag_nagios_server=0
fi

# Check for Nagios client and set flag
if [ -f "${NAGIOS_NRPE_BINARY_PATH}" ]; then
    flag_nagios_client=1
else
    flag_nagios_client=0
fi

if [ "${flag_nagios_server}" -eq "1" ]; then
    echo "`date` [*] Detected a Nagios server system"
    echo "`date` [*] Detected a Nagios server system" >> "$HPE_NAGIOS_LOG_FILE"

fi

if [ "${flag_nagios_client}" -eq "1" ]; then
    echo "`date` [*] Detected a Nagios client system"
    echo "`date` [*] Detected a Nagios client system" >> "$HPE_NAGIOS_LOG_FILE"
fi

# Check if no Nagios Server and Client detected on the system
if [ "${flag_nagios_server}" -eq "0" ] && [ "${flag_nagios_client}" -eq "0" ]; then
    echo "`date` [*] No Nagios installation detected, installation cannot continue"
    echo "`date` [*] No Nagios installation detected, installation cannot continue" >> "$HPE_NAGIOS_LOG_FILE"
    flag_install_failed=1
    exit 0
fi

# Check if both Nagios Server and Client detected on the same system
if [ "${flag_nagios_server}" -eq "1" ] && [ "${flag_nagios_client}" -eq "1" ] && [ "${flag_install_failed}" -ne "1" ]; then
    echo "`date` [*] Both Nagios Server and Nagios Client detected"
    echo "`date` [*] Both Nagios Server and Nagios Client detected" >> "$HPE_NAGIOS_LOG_FILE"

    echo "`date`    Installation will modify the Nagios Client settings"
    echo "`date`    Installation will modify the Nagios Client settings" >> "$HPE_NAGIOS_LOG_FILE"

    echo "`date`    Please modify the Nagios Server, services configuration manually"
    echo "`date`    Please modify the Nagios Server, services configuration manually"
fi

# If there is a Nagios client detected, then add the NRPE configuration
if [ "${flag_nagios_client}" -eq "1" ] && [ "${flag_install_failed}" -ne "1" ]; then

    # Install the NRPE configuration
    add_hpe_nrpe_cfg    
fi

# Check if installation failed or successful
if [ "${flag_install_failed}" -eq "0" ]; then
    echo "`date` [*] Installation of HPE StoreOnce Monitoring Plugin for Nagios Core completed successfully"
    echo "`date` [*] Installation of HPE StoreOnce Monitoring Plugin for Nagios Core completed successfully" >> "$HPE_NAGIOS_LOG_FILE"
else
    echo "`date` [*] ! Installation of HPE StoreOnce Monitoring Plugin for Nagios Core failed"
    echo "`date` [*] ! Installation of HPE StoreOnce Monitoring Plugin for Nagios Core failed" >> "$HPE_NAGIOS_LOG_FILE"

fi

exit 0

# -----------------------------------------------------------------------------
# End of file
# -----------------------------------------------------------------------------
