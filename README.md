# Apache Mod Security demo

## Deployment on local container engine (podman)

1. clone this repo:
```
$ git clone --recurse-submodules https://github.com/pbertera/modsecurity-demo.git
$ cd modsecurity-demo
```

2. build the container
```
$ podman build --cgroup-manager=cgroupfs -t quay.io/pbertera/httpd-mod-sec .
```

3. run the container
```
podman run -it --rm -p 8080:8080 -v $PWD/demo-data:/var/www/html/:Z -v $PWD/modsecurity.d/custom-rules.conf:/etc/httpd/modsecurity.d/local_rules/modsecurity_localrules.conf:Z -v $PWD/conf/soap-envelope.xsd:/etc/httpd/conf.d/soap-envelope.xsd:Z quay.io/pbertera/httpd-mod-sec
```

4. run the demo
```
$ export URL="http://localhost:8080"
$ ./cases
```

## Deployment on OpenShift / K8s

1. clone this repo:
```
$ git clone --recurse-submodules https://github.com/pbertera/modsecurity-demo.git 
$ cd modsecurity-demo
```
2. create a namespace
```
$ oc create modsecurity
```

3. deploy the manifest
```
$ oc create -f modsecurity.yaml
```

4. make sure the `modsecurity` pod is running and the route exists
```
$ oc get pods
$ oc get route modsecurity
```

5. start the demo
```
$ export URL=http://$(oc get route modsecurity -o jsonpath='{.spec.host}')
$ ./cases.sh
```

[![asciicast](https://asciinema.org/a/Wdxs7vUE8Z9uOYH5FYGxXgfUQ.svg)](https://asciinema.org/a/Wdxs7vUE8Z9uOYH5FYGxXgfUQ)
