#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 2.0                                  #
#									     #
#	NOM: BEUGNET							     #
#									     #
#	PRENOM: Thierry							     #
#									     #
#	DATE: 17/04/2024	           				     #
#									     #
#	BUT: Script pour identifier des albums en doublon    		     #
#									     #
############################################################################## 

#définition des variables
#BASE=/home/thierry/bidule/
BASE=/mnt/user/Medias/"Shared Music"/Collection/
DATE=$(date "+%Y-%m-%d")
LOG=/mnt/user/Documents/scripts/logs/${DATE}-doublons_potentiels.txt
#NBSLASH=5
#NBSLASH2=6
NBSLASH=7
NBSLASH2=8
#création du fichier log
touch ${LOG}
#calcul du nombre de dossiers artistes
#NBDIR=$(find "${BASE}"* -maxdepth 0 -type d | wc -l)
NBDIR=5
echo "Nombre de dossiers d'artistes : $NBDIR"
echo "let's go !!!"

#analyse des dossiers artistes 1 par 1
for ((c=1; c<=$NBDIR; c++))
do
DIR=$(find "${BASE}"* -maxdepth 0 -type d | head -$c | tail +$c )
echo "${DIR}"
ARTISTE=$(echo "${DIR}" |  cut -d "/" -f${NBSLASH})
echo "${ARTISTE}"
#recherche du nombre de dossiers albums pour l'artiste
NBDIR2=$(find "${DIR}"/* -maxdepth 0 -type d | wc -l)
echo "Nombre d'albums pour cet artiste : ${NBDIR2}" 

    if [ $NBDIR2 -gt 1 ]
    then
    #check si le nb d'albums est supérieur à 1, si oui, il continue, si non il passe au dossier artiste suivant

        for ((d=1 ; d<=$NBDIR2 ; d++))
        do
	#pour chaque album, récupération du nom
        DIR2=$(find "${DIR}"/* -maxdepth 0 -type d | head -$d | tail +$d )
echo "${DIR2}"
        ALBUM=$(echo "${DIR2}" | cut -d "/" -f${NBSLASH2})
        #défini le nb de mots composants le titre de l'album
	NBDIR2MOT=$(echo "${ALBUM}" | wc -w )
        TEMPFICHIER="temp${d}"
	#création d'un fichier temp
        touch "${BASE}${TEMPFICHIER}"
        echo "${ALBUM}"



            for ((e=1 ;e<=$NBDIR2MOT ;e++))
            do
	    #identification de chaque mot et de son nombre de caractères
            MOT=$(find "${DIR2}" -maxdepth 0 -type d | cut -d "/" -f"${NBSLASH2}" | cut -d "-" -f3 | cut -d " " -f${e} )
            echo "mot${e} : ${MOT}" 
            NBCAR=$(find "${DIR2}" -maxdepth 0 -type d | cut -d "/" -f"${NBSLASH2}" | cut -d "-" -f3 | cut -d " " -f${e} | wc -m)
            
	    

                if [ $NBCAR -ge 4 ]
                then
		#si le mot est composé d'au moins 4 caractères, celui ci est envoyé dans le fichier temp
		echo "${MOT} ${NBCAR}" >> "${BASE}${TEMPFICHIER}"
                else
                echo "pas assez de caractères"
                fi
            done
	NBMOTSFIND=$(cat "${BASE}${TEMPFICHIER}" | wc -l)

        if [ $NBMOTSFIND -lt 4 ]
        then
	#si le nombre de mots dans le fichier temp est inférieur à 4, la recherche s'établie sur le mot le plus long dans le dossier artiste 
	OKMOT=$(cat "${BASE}${TEMPFICHIER}" | sort -n -r -t " " -k 2 | cut -d " " -f1 | head -n 1) 
	echo "recherche sur ce mot : ${OKMOT}"
    NBDIR3=$(find "${DIR}" -maxdepth 1 -mindepth 1 -type d | grep -i "${OKMOT}" | grep -v -i "${ALBUM}" | wc -l) 
        if [ $NBDIR3 -gt 0 ]
        then
	#si correspondance trouvée, elle est envoyée dans le fichier log 
        echo "j'ai trouvé $NBDIR3 correspondance(s), liste à contrôler ci dessous :" 
        DIR3=$(find "${DIR}" -maxdepth 1 -mindepth 1 -type d | grep -i "${OKMOT}"  | grep -v -i "${ALBUM}" | tee -a ${LOG})
echo "(find "${DIR}" -maxdepth 1 -mindepth 1 -type d | grep -i "${OKMOT}"  | grep -v -i "${ALBUM}" | tee -a ${LOG})"
	    echo $DIR3
        else
        echo "aucune correspondance trouvée, cool mec"
        fi
	else
    #si nombre de mots dans le fichier temp >= 4 il sélectionne les 2 mots les plus longs pour faire une recherche	
    OKMOT=$(cat "${BASE}${TEMPFICHIER}" | sort -n -r -t " " -k 2 | cut -d " " -f1 | head -n 1)
    OKMOT2=$(cat "${BASE}${TEMPFICHIER}" | sort -n -r -t " " -k 2 | cut -d " " -f1 | head -2 | tail +2)
	echo "recherche sur ces mots : ${OKMOT} & ${OKMOT2}"
    NBDIR3=$(find "${DIR}" -maxdepth 1 -mindepth 1 -type d | grep -i "${OKMOT}" | grep -i "${OKMOT2}" | grep -v -i "${ALBUM}" | wc -l) 
        if [ $NBDIR3 -gt 0 ]
        then
        echo "j'ai trouvé $NBDIR3 correspondance(s), liste à contrôler ci dessous :" 
        DIR3=$(find "${DIR}" -maxdepth 1 -mindepth 1 -type d | grep -i "${OKMOT}"  | grep -i "${OKMOT2}" | grep -v -i "${ALBUM}" | tee -a ${LOG})
	    echo $DIR3
        else
        echo "aucune correspondance trouvée, cool mec"
        fi
	fi
    	rm "${BASE}${TEMPFICHIER}"
	    done
    else
    echo "1 seul album pour cet artiste donc pas de doublon"
    fi
done

