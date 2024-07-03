#!/bin/bash
############################################################################## 
#                                                                            #
#	SHELL: !/bin/bash       version 2.0                                      #
#									                                         #
#	NOM: BEUGNET							                                 #
#									                                         #
#	PRENOM: Thierry							                                 #
#									                                         #
#	DATE: 17/04/2024	           				                             #
#								                                      	     #
#	BUT: Script pour identifier des albums en doublon    		             #
#									                                         #
############################################################################## 

######CONFIGURATION###########################################################
BASE=/music/base/folder/
DATE=$(date "+%Y-%m-%d")
LOG=/path/to/logs/folder/${DATE}-doublons_potentiels.txt
NBSLASH=7 #num of / for cut command and find artist name in the path
NBSLASH2=8 #num of / for cut command and find album name in the path
######CONFIGURATION###########################################################

#création du fichier log
touch ${LOG}
#calcul du nombre de dossiers artistes
NBDIR=$(find "${BASE}"* -maxdepth 0 -type d | wc -l)

echo "Nombre de dossiers d'artistes : $NBDIR"
echo "let's go !!!"

#analyse des dossiers artistes 1 par 1
for ((c=1; c<=$NBDIR; c++))
do
DIR=$(find "${BASE}"* -maxdepth 0 -type d | head -$c | tail +$c )
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
        echo "${DIR2}" | cut -d "/" -f${NBSLASH2} > "${BASE}ALBUMTEMP1"
        ALBUM=$(echo "${DIR2}" | cut -d "/" -f${NBSLASH2})
        sed -i 's/(//g;s/)//g;s/remix//i;s/single//i;s/album//i;s/[0-9]\{4\}//g;s/-//' "${BASE}ALBUMTEMP1"
        cat "${BASE}ALBUMTEMP1" | tr -d "[" | tr -d "]" | tr -d "-" | tr -s " " > "${BASE}ALBUMTEMP"
    	sed -i 's/^ *//' "${BASE}ALBUMTEMP"
       	ALBUMNOM=$(cat "${BASE}ALBUMTEMP")
        echo "${ALBUMNOM}"
        #défini le nb de mots composants le titre de l'album
		NBDIR2MOT=$(echo "${ALBUMNOM}" | wc -w )
        TEMPFICHIER="temp${d}"
		#création d'un fichier temp
        touch "${BASE}${TEMPFICHIER}"
            
            for ((e=1 ;e<=$NBDIR2MOT ;e++))
            do
	    	#identification de chaque mot et de son nombre de caractères
            MOT=$(echo "${ALBUMNOM}" | cut -d " " -f${e} )
            echo "mot${e} : ${MOT}" 
            NBCAR=$(echo "${MOT}" | wc -m)
           
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
            	NBDIR3=$(find "${DIR}" -maxdepth 1 -mindepth 1 -type d | grep -i "${OKMOT}" | wc -l) 
        			if [ $NBDIR3 -gt 0 ]
        			then
					#si correspondance trouvée, elle est envoyée dans le fichier log 
        			echo "j'ai trouvé $NBDIR3 correspondance(s), liste à contrôler ci dessous :" 
        				for ((f=1 ;f<=$NBDIR3 ;f++))
            			do
                		DIR3=$(find "${DIR}" -maxdepth 1 -mindepth 1 -type d | grep -i "${OKMOT}" | head -$f | tail +$f)
							if [ "${DIR3}" == "${DIR2}" ]
							then
                			echo "non c'est good"
							else
                			echo $DIR3 | tee -a ${LOG}
							fi
						done			
        			else
        			echo "aucune correspondance trouvée, cool mec"
        			fi
	   			else
           		#si nombre de mots dans le fichier temp >= 4 il sélectionne les 2 mots les plus longs pour faire une recherche	
           		OKMOT=$(cat "${BASE}${TEMPFICHIER}" | sort -n -r -t " " -k 2 | cut -d " " -f1 | head -n 1)
           		OKMOT2=$(cat "${BASE}${TEMPFICHIER}" | sort -n -r -t " " -k 2 | cut -d " " -f1 | head -2 | tail +2)
	   			echo "recherche sur ces mots : ${OKMOT} & ${OKMOT2}"
           		NBDIR3=$(find "${DIR}" -maxdepth 1 -mindepth 1 -type d | grep -i "${OKMOT}" | grep -i "${OKMOT2}" | wc -l) 
        			if [ $NBDIR3 -gt 0 ]
        			then
        			echo "j'ai trouvé $NBDIR3 correspondance(s), liste à contrôler ci dessous :" 
        				for ((f=1 ;f<=$NBDIR3 ;f++))
            			do
						DIR3=$(find "${DIR}" -maxdepth 1 -mindepth 1 -type d | grep -i "${OKMOT}" | grep -i "${OKMOT2}" | head -$f | tail +$f)
							if [ "${DIR3}" == "${DIR2}" ]
							then
                			echo "non c'est good"
        					else
        					echo $DIR3 | tee -a ${LOG}
							fi
						done	    
	      			else
              		echo "aucune correspondance trouvée, cool mec"
          			fi
	  			fi
   	 		rm "${BASE}${TEMPFICHIER}"
         	rm "${BASE}ALBUMTEMP1"
    	 	rm "${BASE}ALBUMTEMP"
    	 done
    else
    echo "1 seul album pour cet artiste donc pas de doublon"
    fi
done

