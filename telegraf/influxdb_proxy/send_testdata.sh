#!/usr/bin/env bash

netappClusterName="netappClusterName"
netappClusterID="netappClusterID"
netappClusterVersion="netappClusterVersion"
netappClusterMgmNet="netappClusterMgmNet"
netappClusterVersiongen="netappClusterVersiongen"
netappClusterVersionmaj="netappClusterVersionmaj"
netappClusterVersionmin="netappClusterVersionmin"
netappInfluxDB="netappInfluxDB"
netappClusterVersiongen="netappClusterVersiongen"

netappInfluxDBURL="localhost"
netappInfluxDBPort=8086

curl -i -XPOST "$netappInfluxDBURL:$netappInfluxDBPort/api/v2/write?precision=s" --data-binary "netapp_cluster_overview,clustername=$netappClusterName,uuid=$netappClusterID,clusterversion=$netappClusterVersion,managementnetwork=$netappClusterMgmNet,versiongeneration=$netappClusterVersiongen a=3,b=4,c=5"
