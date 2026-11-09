#!/bin/sh
# Travis archives job logs asynchronously; the build harvester reads each job's log as soon as the
# build finishes, so a lagging archive yields a truncated log without the test results. Keep the job
# open (heartbeat every 20 s, capped) until its own public log.txt contains the Surefire grand total.
# after_script cannot change the build result, so this never masks a failure.
URL="https://api.travis-ci.com/v3/job/${TRAVIS_JOB_ID}/log.txt"
MAX=1800
waited=0
while [ "$waited" -lt "$MAX" ]; do
  if curl -fsSL "$URL" 2>/dev/null | grep -Eq 'SUREFIRE TOTAL \(api \+ impl \+ extensions\): Tests run: [0-9]+, Passed: [0-9]+'; then
    echo "wait-for-log: test summary archived after ${waited}s"
    exit 0
  fi
  echo "wait-for-log: waiting for log archive... (${waited}s)"
  sleep 20
  waited=$((waited + 20))
done
echo "wait-for-log: gave up after ${MAX}s"
exit 0
