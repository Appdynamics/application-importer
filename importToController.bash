#!/bin/bash

main ()
{

source $1 

DATE_FORMAT="%m-%d-%Y_%H-%M-%S"
LOG_FILE="log_$( date +"${DATE_FORMAT}" ).txt"

echo "IMPORTING APPLICATION AND CUSTOM DASHBOARD TEMPLATE" > ${LOG_FILE}

while read appName; do

   echo $appName

   # Import Application
   curl -u ${controller_user}@${controller_account}:${controller_pass} --form $appName=@${application_template} "https://${controller_host}:${controller_port}/controller/ConfigObjectImportExportServlet" >> ${LOG_FILE}

   # Replace the custom dashboard with Application Name
   cp ${dashboard_template} $appName_CustomDB_Temp.json
   sed -i '' "s~NONPROD~${appName}~g" ${appName}_CustomDB_Temp.json

   # Import Custom Dashboard

   curl -u ${controller_user}@${controller_account}:${controller_pass} --form $appName=@$appName_CustomDB_Temp.json "https://${controller_host}:${controller_port}/controller/CustomDashboardImportExportServlet" >> ${LOG_FILE}

   rm $appName_CustomDB_Temp.json

done <AppList.txt

}

show_usage ()
{
    echo "Usage: bash importToController.bash <config_file>"
}

if [ -z "$1" ]; then
        show_usage
else
        main $1
        echo "Application and Dashboard import complete"
fi

