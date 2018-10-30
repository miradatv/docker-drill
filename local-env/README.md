# Apache Drill Docker Local Environment


In this directory you can find a simplified Apache Drill environment

## Requirements

* Linux system.
* Docker Engine 18.x

## Building Docker image

You can build the Docker image with the following command:

```
$ cd docker-drill/local-env
$ bin/build.sh

... truncated log ...

Successfully built c2dd80e647fc
Successfully tagged drill-img:latest
```

## Running Docker container

Once you have built the image (drill-image) you can start a container with the following command:

```
$ bin/run.sh
Usage:
    ./run.sh DRILL_STORAGE_DIR

$ bin/run.sh /opt/mirada/drill-storages

```

As you can see, you must set as first argument a directory in the host where you can save your raw data (.json, .csv, ...). This directory in the host is mounted as a volume inside the container and is used by Apache Drill to read raw data and store views, tables and processed data.

You can access these directories inside the container at:

* ```/drill-data/raw```: Read only. Raw data to be processed.
* ```/drill-data/tvmetrix```: Writable. Created views, tables and processed data.
