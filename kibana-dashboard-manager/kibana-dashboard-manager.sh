#!/bin/bash
# Author : Sarah Bourgeois
# Description : import visualizations and dashboards directly on your own kibana.

#Elastic Stack parameters
ELASTICSEARCH_HOST="http://localhost:9200"

#Internal script command
NAME_ELASTIC_INDEX=".kibana"
CURL=curl
DIR=dash

printf "\n"
echo "-------------------------------------------------"
echo "              kibana_dashboard_manager             "
echo "-------------------------------------------------"
printf "\n"

# Help to use correctly arguments
help_command () {
  echo  "help :
  import       ==> to import vizualisation and dashboards from json your json file
  delete_all   ==> to delete  vizualisations and dashboards which are in your .kibana:
  delete_visu  ==> to delete vizualisations one per one
  delete_dash  ==> to delete dashboards one per one"
  printf "\n"
}

# Import your vizualisations, your index-pattern and your dasboards
import () {
  echo "Processing... "
  echo "Loading to $ELASTICSEARCH_HOST in $NAME_ELASTIC_INDEX ... "
  printf "\n"

  for file in $DIR/visualization/*.json
  do
    name=`basename $file .json`
    echo "Loading visualization called $name: "
    curl -XPUT $ELASTICSEARCH_HOST/$NAME_ELASTIC_INDEX/visualization/$name -d @$file ||exit 1
    printf "\n"
  done

  for file in $DIR/index-pattern/*.json
  do
    name=`awk '$1 == "\"title\":" {gsub(/"/, "", $2); print $2}' $file`
    echo "Loading index pattern $name:"
    curl -XPUT $CURL_OPTS $ELASTICSEARCH_HOST/$NAME_ELASTIC_INDEX/index-pattern/$name  \
    -d @$file
    printf "\n"
  done

  for file in $DIR/dashboards/*.json
  do
    name=`basename $file .json`
    echo "Loading dashboard $name:"
    curl -XPUT $CURL_OPTS $ELASTICSEARCH_HOST/$NAME_ELASTIC_INDEX/dashboard/$name \
    -d @$file
    echo
  done
  printf "\n"
}

# Delete all : vizualisations, index-pattern and dasboards
delete_all () {
  for file in $DIR/visualization/*.json
  do
    name=`basename $file .json`
    echo "Supressing visualization called $name: "
    curl -XDELETE $CURL_OPTS $ELASTICSEARCH_HOST/$NAME_ELASTIC_INDEX/visualization/$name -d @$file ||exit 1
    printf "\n"
  done

  for file in $DIR/dashboards/*.json
  do
    name=`basename $file .json`
    echo "Supressing dashboards called $name: "
    curl -XDELETE $CURL_OPTS $ELASTICSEARCH_HOST/$NAME_ELASTIC_INDEX/dashboard/$name -d @$file ||exit 1
    printf "\n"
  done

  for file in $DIR/index-pattern/*.json
  do
    name=`basename $file .json`
    echo "Supressing index-pattern called $name: "
    curl -XDELETE $CURL_OPTS $ELASTICSEARCH_HOST/$NAME_ELASTIC_INDEX/index-pattern/$name -d @$file ||exit 1
    printf "\n"
  done
}

# Delete vizualisation one per one
delete_visu () {
  echo "List of your vizualisation  : "
  echo $DIR/visualization/*.json "\n"
  for file in $DIR/visualization/*
  do
    read -p 'Which vizualisation do you want to delete ? ' name
    curl -XDELETE $CURL_OPTS $ELASTICSEARCH_HOST/$NAME_ELASTIC_INDEX/visualization/$name \
    -d @$file
    printf "\n"
  done
}


# Delete dashboards one per one
delete_dash() {
  echo "List of your dashboards : "
  echo $DIR/dashboards/*.json "\n"
  for file in $DIR/dashboards/*.json
  do
    read -p 'Which dashboard do you want to delete ?   ' name
    curl -XDELETE $CURL_OPTS $ELASTICSEARCH_HOST/$NAME_ELASTIC_INDEX/dashboard/$name -d @$file ||exit 1
    printf "\n"
  done
}

#Arguments to use the  script
if [[ $1 = '' ]];
then
  help_command
fi

if [[ $1 = 'import' ]];
then
  import
fi

if [[ $1 = 'delete_all' ]];
then
  delete_all
fi

if [[ $1 = 'delete_visu' ]];
then
  delete_visu
fi

if [[ $1 = 'delete_dash' ]];
then
  delete_dash
fi
