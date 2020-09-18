set -euo pipefail
IFS=$'\n\t'

echo "Usage: sh cfn_create_update.sh --environment <ENVIRONMENT> --region <aws default REGION> --read-capacity-units <DynamoDB read capacity units> \
--write-capacity-units <DynamoDB write capacity units>  --max-provisionable-capacity <Max provisionable capacity> \
--auto-scaling-target-percentage <Auto scaling target percentage>"

ENVIRONMENT=""
REGION=""
READ_CAPACITY_UNITS=""
WRITE_CAPACITY_UNITS=""
MAX_PROVISIONABLE_CAPACITY=""
AUTO_SCALING_TARGET_PERCENTAGE=""
AUTO_SCALING_ROLE="arn:aws:iam::906410225242:role/aws-service-role/dynamodb.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_DynamoDBTable"

createDynamoDBTables(){
    cfn-create-or-update \
      --stack-name "swiggy-pay-tables-wallet-service-${ENVIRONMENT}" \
      --template-body file://build/dynamodb/dynamodb_cfn.yml \
      --parameters "ParameterKey=environment,ParameterValue=${ENVIRONMENT}" \
                   "ParameterKey=readCapacityUnits,ParameterValue=${READ_CAPACITY_UNITS}" \
                   "ParameterKey=writeCapacityUnits,ParameterValue=${WRITE_CAPACITY_UNITS}" \
                   "ParameterKey=maxProvisionableCapacity,ParameterValue=${MAX_PROVISIONABLE_CAPACITY}" \
                   "ParameterKey=autoScalingTargetPercentage,ParameterValue=${AUTO_SCALING_TARGET_PERCENTAGE}" \
                   "ParameterKey=autoScalingRole,ParameterValue=${AUTO_SCALING_ROLE}" \
      --region "${REGION}" \
      --wait
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --environment)                    ENVIRONMENT="$2";                    shift; shift;;
        --region)                         REGION="$2";                         shift; shift;;
        --read-capacity-units)            READ_CAPACITY_UNITS="$2";            shift; shift;;
        --write-capacity-units)           WRITE_CAPACITY_UNITS="$2";           shift; shift;;
        --max-provisionable-capacity)     MAX_PROVISIONABLE_CAPACITY="$2";     shift; shift;;
        --auto-scaling-target-percentage) AUTO_SCALING_TARGET_PERCENTAGE="$2"; shift; shift;;
        *)                                                                            shift;;
    esac
done

MISSING=()
if [[ -z "$ENVIRONMENT"                    ]]; then MISSING+=("environment");                    fi
if [[ -z "$REGION"                         ]]; then MISSING+=("region");                         fi
if [[ -z "$READ_CAPACITY_UNITS"            ]]; then MISSING+=("read-capacity-units");            fi
if [[ -z "$WRITE_CAPACITY_UNITS"           ]]; then MISSING+=("write-capacity-units");           fi
if [[ -z "$MAX_PROVISIONABLE_CAPACITY"     ]]; then MISSING+=("max-provisionable-capacity");     fi
if [[ -z "$AUTO_SCALING_TARGET_PERCENTAGE" ]]; then MISSING+=("auto-scaling-target-percentage"); fi
