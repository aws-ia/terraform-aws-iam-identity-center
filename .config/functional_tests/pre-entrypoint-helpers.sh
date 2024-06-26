#!/bin/bash
## NOTE: this script runs at the start of functional test
## use this to load any configuration before the functional test
## TIPS: avoid modifying the .project_automation/functional_test/entrypoint.sh
## migrate any customization you did on entrypoint.sh to this helper script
echo "Executing Pre-Entrypoint Helpers"

#********** Project Path *************
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype
cd ${PROJECT_PATH}

#********** AWS Region Export *************
export AWS_DEFAULT_REGION=us-east-1
