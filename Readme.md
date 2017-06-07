## Docker image for Apache Drill on Kubernetes ##

This a Docker image of Drill intented to be used with Kubernetes.  We're using
a patched version of Drill ([source here](http://github.com/miradatv/drill)) with some custom [UDF](https://drill.apache.org/docs/adding-custom-functions-to-drill/).

* Requisites:
  * wget
  * jq
