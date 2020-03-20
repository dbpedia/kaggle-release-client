#!/bin/bash

# Contributor: Milan Dojchinovski - dojcinovski.milan@gmail.com

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DATASETS_QUERY_FILE="$ROOT/datasets_query.sparql"
TARGETFILE="$ROOT/results.csv"
DATASET_METADATA_TEMPLATE_PATH="$ROOT/dataset-metadata-template.json"
DATASET_METADATA_TEMPLATE=`cat $DATASET_METADATA_TEMPLATE_PATH`



############################################################################
# The DEPLOY function does following:
# - collects list of download links for a given account/group and dataset version
# - downloads the files in /download
# - prepares datasets-metadata.json file
# - deploys the data to kaggle:
#    * if the dataset exists, it deploys new version
#    * if the dataset does not exist, it creates a dataset
############################################################################
function deploy
{

	prepare_datasets_query $1 $2 > datasets_query.sparql

	curl --data-urlencode query@$DATASETS_QUERY_FILE -H "Accept: text/csv" --data-urlencode default-graph-uri= https://databus.dbpedia.org/repo/sparql > results.csv

	rm -r download ; mkdir download ; cd download

	JSON_FMT='{"path":"%s","description":"%s"}\n'

	RESOURCES_LIST=""
	echo "[INFO] Started downloading the group files."
	first_pass=false
	{
		read
		while IFS=',', read -r distribution file
		do	
			# download every dataset from the group
			echo "[INFO] Downloading $file"
			echo "$file" |  sed 's/\"//g' | xargs wget -q 
			FILE_PATH="$file"
			FILE_NAME=$(basename $file)
			FILE_NAME=$(echo $FILE_NAME | sed 's/\"//g' )
			DESCRIPTION="dataset description: TODO"
			if [ "$first_pass" = false ] ; 
			then
				RESOURCES_LIST="${RESOURCES_LIST} "$(printf "$JSON_FMT" "$FILE_NAME" "$DESCRIPTION" )
				first_pass=true
			else
				RESOURCES_LIST="${RESOURCES_LIST} ",""$(printf "$JSON_FMT" "$FILE_NAME" "$DESCRIPTION" )
			fi
		done
	} < $TARGETFILE

	echo "${DATASET_METADATA_TEMPLATE/REPLACE_DATASET_RESOURCES/$RESOURCES_LIST}" | sed 's/\%//g' > dataset-metadata.json

	# FIX REQUIRED: hardcoded account/dataset-id parameter
	dataset_status=$(kaggle datasets status milandojchinovski/dbpedia-nif-dataset)

	if [ "$dataset_status" = ready ] ; 
	then
		echo "[INFO] The dataset exists. Deploying new version."
		new_version_status=$(kaggle datasets version -m "new dataset version: $VERSION")
		echo "[INFO] "$new_version_status
	else
		echo "[INFO] The dataset does not exist. Deploying initial version."
		create_status=$(kaggle datasets create)
		echo "[INFO] "$create_status
		echo "[INFO] Your dataset has been created. It might take few minutes until it is available online."
	fi

}


######################################
# The functions takes two arguments: 
#    - account/group
#    - dataset version
#
function prepare_datasets_query () 
{
	echo "
	PREFIX dcat: <http://www.w3.org/ns/dcat#>
	PREFIX dct: <http://purl.org/dc/terms/>
	PREFIX dataid-cv: <http://dataid.dbpedia.org/ns/cv#>
	PREFIX dataid: <http://dataid.dbpedia.org/ns/core#>
	
	# Get all files
	SELECT DISTINCT ?distribution ?file WHERE {
		<http://dbpedia-generic.tib.eu/release/text/equations/2020.02.01/dataid.ttl#Dataset> dataid:group <https://databus.dbpedia.org/"$1"> .
		<http://dbpedia-generic.tib.eu/release/text/equations/2020.02.01/dataid.ttl#Dataset> dct:hasVersion \""$2"\"^^xsd:string .
		<http://dbpedia-generic.tib.eu/release/text/equations/2020.02.01/dataid.ttl#Dataset> dcat:distribution ?distribution .
		?distribution dcat:downloadURL ?file .
	} LIMIT 2"
}





