curl -i -u perf:perf@123 -H "Content-Type: application/json" -X POST -d '{"service_name":"sand-scube","build_number":"0.0.94","concurrency_rate": "5", "triggered_by": "kaushik"}' http://deployer.swiggyperf.in/deploy





#!/bin/bash
function goLoop() {

  sleep 5
  url=$1
  result=`curl -s -u perf:perf@123 -H "Content-Type: application/json" $url | jq '.message'`
  test=`sed -e 's/^"//' -e 's/"$//' <<<"$result"`
  echo $test

  if [[ $test =~ "ERROR" ]];
  then
     exit 1
  fi
  ERROR=0
  while [ "$test" != "No state found" ];
  do
    result=`curl -s -u perf:perf@123 -H "Content-Type: application/json" $url | jq '.message'`
    test=`sed -e 's/^"//' -e 's/"$//' <<<"$result"`
    if [[ "$test" != "[INPROGRESS]" ]];
    then
          echo $test
  grep -E "ERROR|FAILED" <<< "$test"
          if [[ "$?" == 0 ]];
          then
             ERROR=1
          fi
    fi
  done
  if [[ $ERROR == 1 ]];
  then
    exit 1
  fi
}




echo "Service name is " ${SERVICE_NAME}
echo "build version is " ${BUILD_NUMBER}
echo "Concurrent rate is " ${concurrency_rate}
params={\"service_name\":\"${SERVICE_NAME}\",\"build_number\":\"${BUILD_NUMBER}\",\"triggered_by\":\"${BUILD_USER_EMAIL}\",\"concurrency_rate\":\"${concurrency_rate}\"}

echo "params" ${params}
message=`curl -i-u perf:perf@123 -H "Content-Type: application/json" -X POST -d ${params} http://deployer.swiggyperf.in/deploy | jq '.message'`

test=`sed -e 's/^"//' -e 's/"$//' <<<"$message"`
echo $test
if [[ $test =~ "status" ]];
then
   goLoop $test
fi   

