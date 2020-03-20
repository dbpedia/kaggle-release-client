# Kaggle Release Client


The client is used to deploy DBpedia data on the Kaggle platform.
Initially, the client is being developed for deployment of the DBpedia NIF datasets.

To run the tool:

``./kaggle-release.sh deploy m1ci/text 2020.02.01``

The tool takes three parameters:

- ``{command}`` - currently only the `deploy` command is supported.
- ``{account/group-id}`` - specify the databus `account` name and the `group-id` which you would like to deploy, e.g. `m1ci/text`  
- ``{version}`` - specify the version of the dataset to deploy, e.g. `2020.02.01`

## Prerequirements

- python 3
- kaggle - `pip3 install kaggle`
- configure kaggle API Token - get one and insert it in `~/.kaggle/kaggle.json`
