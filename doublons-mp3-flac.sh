#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 1.1                                  #
#									     #
#	NOM: BEUGNET							     #
#									     #
#	PRENOM: Thierry							     #
#									     #
#	DATE: 17/04/2024	           				     #
#									     #
#	BUT: Script pour identifier des albums avec mp3 ET flac 	     #
#									     #
############################################################################## 

######CONFIGURATION###########################################################
BASE=/music/base/folder/
DATE=$(date "+%Y-%m-%d")
LOG=/path/to/logs/folder/${DATE}-dossiers_multiformats.txt
NBSLASH=8 #num of / for cut command and find artist name in the path
NBSLASH2=9 #num of / for cut command and find album name in the path
######CONFIGURATION###########################################################

#création du fichier log
touch "${LOG}"
#calcul du nombre de dossiers artistes
NBDIR=$(find "${BASE}"* -maxdepth 0 -type d | wc -l)

echo "Nombre de dossiers d'artistes : $NBDIR"
echo "let's go !!!"

#analyse des dossiers artistes 1 par 1
for ((c=1; c<=$NBDIR; c++))
do
DIR=$(find "${BASE}"* -maxdepth 0 -type d | head -$c | tail +$c )
ARTISTE=$(echo "${DIR}" | cut -d "/" -f"${NBSLASH}")
echo "${ARTISTE}"
#recherche du nombre de dossiers albums pour l'artiste
NBDIR2=$(find "${DIR}"/* -maxdepth 5 -type d | wc -l)
echo "Nombre d'albums pour cet artiste : ${NBDIR2}" 
        for ((d=1 ; d<=$NBDIR2 ; d++))
        do
	DIR2=$(find "${DIR}"/* -maxdepth 5 -type d | head -$d | tail +$d )
        ALBUM=$(echo "${DIR2}" | rev | cut -d "/" -f1 | rev )
	echo "${ALBUM}"
     
	NBDIR3=$(find "${DIR2}" -maxdepth 1 -mindepth 0 -type d -exec sh -c '[ -f "$0"/*.mp3 ] && [ -f "$0"/*.flac ]' '{}' \; -print | wc -l) 
                if [ $NBDIR3 -gt 0 ]
                then
	        #si correspondance trouvée, elle est envoyée dans le fichier log 
                echo "$NBDIR3 correspondance(s), liste à contrôler ci dessous :" 
                DIR3=$(find "${DIR2}" -maxdepth 1 -mindepth 0 -type d -exec sh -c '[ -f "$0"/*.mp3 ] && [ -f "$0"/*.flac ]' '{}' \; -print | tee -a ${LOG})
                echo $DIR3
                else
                echo "OK"
                fi
        done
done
