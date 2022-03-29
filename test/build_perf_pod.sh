#! /bin/bash -x 
docker rmi wyue/perfpod
docker image build -t wyue/perfpod -f etc/docker/netperf_test.Dockerfile .

# docker load -i ./perf_pod.tar
