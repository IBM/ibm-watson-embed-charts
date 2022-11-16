#! /usr/bin/env bash
# The purpose of this script is to process the archives contained in the model
# container images to populate the model "cache" that the runtime uses when it
# loads models. If the cache is populated, the runtime loads from it instead of
# depending on model store service.
#
# We use the runtime code itself to populate the cache by booting the runtime
# with a simple Python file server serving the archives. The runtime imports the
# models and populates the cache. After the cache is populated, the runtime can
# boot without the file server.
set -u

cleanup() {
  local pids=$(jobs -pr)
  if [ -n "$pids" ]; then
    kill $pids
  fi
}
trap "cleanup" SIGINT SIGQUIT SIGTERM EXIT

python -m http.server --bind 127.0.0.1 --directory /models 3333 &

./runChuck.sh &

# wait for the server to become ready, which happens after it downloads the models
max_tries=10
tries=0
while [[ tries -lt max_tries ]]; do
  curl -sk -o /dev/null "localhost:1080/v1/miniHealthCheck"
  if [[ $? -eq 0 ]]; then
    echo "Model initialization complete"
    exit 0
  fi

  sleep 1
  ((tries+=1))
done

echo "Server failed to initialize models in time."
exit 1
