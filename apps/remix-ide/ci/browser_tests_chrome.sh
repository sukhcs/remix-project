#!/usr/bin/env bash

set -e

setupRemixd () {
  mkdir remixdSharedfolder
  cd apps/remix-ide/contracts
  echo 'sharing folder: '
  echo $PWD
  ../../../node_modules/.bin/remixd -s $PWD --remix-ide http://127.0.0.1:8080 &
  cd ../../..
}

BUILD_ID=${CIRCLE_BUILD_NUM:-${TRAVIS_JOB_NUMBER}}
echo "$BUILD_ID"
TEST_EXITCODE=0

npm run ganache-cli &
npm run serve &
setupRemixd

sleep 5

TESTFILES=$(circleci tests glob "./apps/remix-ide/test-browser/tests/**/*.test.js" | circleci tests split --split-by=timings)
npm run nightwatch_local_chrome $TESTFILES

echo "$TEST_EXITCODE"
if [ "$TEST_EXITCODE" -eq 1 ]
then
  exit 1
fi
