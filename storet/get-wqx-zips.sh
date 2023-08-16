!#/bin/bash

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/zip' -d '{"countrycode":["US"],"statecode":["US:15"],"organization":["HUIWAIOLA_WQX"],"providers":["STORET"]}' 'https://www.waterqualitydata.us/data/Organization/search?mimeType=tsv&zip=yes' --output "organizationData.zip"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/zip' -d '{"countrycode":["US"],"statecode":["US:15"],"organization":["HUIWAIOLA_WQX"],"providers":["STORET"]}' 'https://www.waterqualitydata.us/data/Project/search?mimeType=tsv&zip=yes' --output "projectData.zip"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/zip' -d '{"countrycode":["US"],"statecode":["US:15"],"organization":["HUIWAIOLA_WQX"],"providers":["STORET"]}' 'https://www.waterqualitydata.us/data/Station/search?mimeType=tsv&zip=yes' --output "siteDataOnly.zip"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/zip' -d '{"countrycode":["US"],"statecode":["US:15"],"organization":["HUIWAIOLA_WQX"],"dataProfile":"resultPhysChem","providers":["STORET"]}' 'https://www.waterqualitydata.us/data/Result/search?mimeType=tsv&zip=yes' --output "resultsPhysChem.zip"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/zip' -d '{"countrycode":["US"],"statecode":["US:15"],"organization":["HUIWAIOLA_WQX"],"dataProfile":"biological","providers":["STORET"]}' 'https://www.waterqualitydata.us/data/Result/search?mimeType=tsv&zip=yes' --output "resultsBiological.zip"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/zip' -d '{"countrycode":["US"],"statecode":["US:15"],"organization":["HUIWAIOLA_WQX"],"dataProfile":"narrowResult","providers":["STORET"]}' 'https://www.waterqualitydata.us/data/Result/search?mimeType=tsv&zip=yes' --output "resultsNarrow.zip"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/zip' -d '{"countrycode":["US"],"statecode":["US:15"],"organization":["HUIWAIOLA_WQX"],"dataProfile":"activityAll","providers":["STORET"]}' 'https://www.waterqualitydata.us/data/Activity/search?mimeType=tsv&zip=yes' --output "samplingActivity.zip"

curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/zip' -d '{"countrycode":["US"],"statecode":["US:15"],"organization":["HUIWAIOLA_WQX"],"providers":["STORET"]}' 'https://www.waterqualitydata.us/data/ResultDetectionQuantitationLimit/search?mimeType=tsv&zip=yes' --output "detectionQuantitationLimitData.zip"