#!/bin/bash

base="$(pwd)/files"
shuffleBosses=()
shuffleEnemies=()
shufflePlayers=()
bossesLine=""
enemiesLine=""
playersLine=""
enemiesLifeBar=""
enemiesLife=0
enemiesStr=O
enmiesTotalLife=0
linkLife=0
linkStr=0
linkTotalLife=0
bossLife=0
bossStr=0
bossTotalLife=0
linkLifeBar=""
combat_id=0


grepBosses( ){
														
        while IFS=',' read -r lines
        do
                line=$( echo $lines | cut -d "," -f1 )
		if [[ $line -eq $1 ]]
                then
                        bossesLine=$lines
                fi
        done < <(tail -n +2  "$base/bosses.csv")

}

grepEnemies( ){
	while IFS=',' read -r lines
        do
                line=$( echo $lines | cut -d "," -f1 )
                if [[ $line -eq $1 ]]
                then
                       enemiesLine=$lines
                fi
        done < <(tail -n +2  "$base/enemies.csv")
	echo $enemiesLine
}

grepPlayers( ){
	while IFS=',' read -r lines
        do
                line=$( echo $lines | cut -d "," -f1 )
                if [[ $line -eq $1 ]]
                then
                        playersLine=$lines
                fi
        done < <(tail -n +2  "$base/players.csv")

}

grepShuffleBosses( ){
	file="$base/bosses.csv"
	lastLines=$( tail -1 $file | cut -d ',' -f1  ) 
	for ((lines=0; lines<$lastLines ; lines++ ))
	do 
		combat_id=$(tail -n +2  $file  | cut -d ',' -f1 )
		rarity=$(tail -n +2  $file | cut -d ',' -f13 )
	for i in $rarity 
		do
			shuffleBosses+=($combat_id)
		done 
	done
	randomIndex=$(($RANDOM % ${#shuffleBosses[@]}))
	index=${shuffleBosses[$randomIndex]}
	grepBosses $index
}

grepShufflePlayers( ){
        file="$base/players.csv"
        lastLines=$( tail -1 $file | cut -d ',' -f1  )
        for ((lines=0; lines<$lastLines ; lines++ ))
        do
                combat_id=$( tail -n +2  $file  | cut -d ',' -f1 )
                rarity=$( tail -n +2  $file | cut -d ',' -f13 )
        for i in $rarity
                do
                        shufflePlayers+=($combat_id)
                done
        done
        randomIndex=$(($RANDOM % ${#shufflePlayers[@]}))
        index=${shufflePlayers[$randomIndex]}
	grepPlayers $index
}

grepShuffleEnemies( ){
        file="$base/enemies.csv"
        lastLines=$( tail -1 $file | cut -d ',' -f1  )
	for ((lines=0; lines<$lastLines ; lines++ ))
        do
                enemies_id=$(tail -n +2  $file  | cut -d ',' -f1 )
                rarity=$(tail -n +2  $file | cut -d ',' -f13 ) 
		for i in $rarity
                do
                        shuffleEnemies+=($enemies_id)
                done
        done
	randomIndex=$(($RANDOM % ${#shuffleEnemies[@]}))
    echo " index $randomIndex"
	index=${shuffleEnemies[$randomIndex]}
	grepEnemies $index
}



showLifeEnemies ( ){

	bar=''
	for (( i=0; i < $enemiesLife; i++ ))
	do
		bar="${bar}I"
	done

	for (( i=$enemiesLife; i< $enmiesTotalLife; i++ ))
	do
		bar="${bar}_"
	done
	
	bar="HP: ${bar} ${enemiesLife} / $enmiesTotalLife"

	echo "$(tput setaf 2)Bokoblin"
	echo $bar

}

showLifeLink ( ){
        bar=''
        for (( i=0; i < $linkLife; i++ ))
        do
                bar="${bar}I"
        done

	for (( i=$linkLife; i<$linkTotalLife; i++ ))
        do
                bar="${bar}_"
        done

	bar="HP: ${bar} ${linkLife} / $linkTotalLife"
	echo ""
	echo "$(tput setaf 1)Link"
	echo $bar
	
}

showLifeBoss( ){
        bar=''
        for (( i=0; i < $bossLife; i++ ))
        do
                bar="${bar}I"
        done

	for (( i=$bossLife; i<$bossTotalLife ; i++ ))
        do
                bar="${bar}_"
        done

	bar="HP: ${bar} ${bossLife} / $bossTotalLife"
	echo ""
	echo "$(tput setaf 1)Boss"
	echo $bar
	
}

setEnemies( ){
	enemiesLife=$( echo $enemiesLine | cut -d ',' -f3 )
	enemiesStr=$( echo $enemiesLine | cut -d ',' -f5 )
	enmiesTotalLife=$enemiesLife

}

setPlayers( ){
        linkLife=$( echo $playersLine | cut -d ',' -f3 )
        linkStr=$( echo $playersLine | cut -d ',' -f5 )
		linkTotalLife=$linkLife
		
}

setBoss( ){
        bossLife=$( echo $bossesLine | cut -d ',' -f3 )
        bossStr=$( echo $bossesLine | cut -d ',' -f5 )
		bossTotalLife=$bossLife
}

showOptions ( ){
	echo ""
	echo "---Options----------"
	echo "1. Attack 2. Heal"
}

showHeader( ){
	echo ""
	echo "======== FIGHT $1 ========"
	echo ""
}

showDeath( ){
	echo "Ho link you are dead, hope you will try another time"
	cat "$base/death.txt"
}

showSuccess( ){
	echo "Ho link Congratulations!"
	cat "$base/death.txt"
}

attaque ( ){
	if  [[ $1 -eq 1 ]]
	then
		enemiesLife=$(( enemiesLife -= linkStr ))
		if [[ $enemiesLife -lt 0 ]]
		then
			enemiesLife=0
		fi
	elif [[ $1 -eq 2 ]]
	then
		linkLife=$(( linkLife + (linkTotalLife / 2) ))
		if [[ $linkLife -ge $linkTotalLife ]]
		then
			linkLife="$linkTotalLife"
		fi
	fi
	 linkLife=$(( linkLife - enemiesStr ))

}

attaqueBoss ( ){
	if  [[ $1 -eq 1 ]]
	then
		bossLife=$(( bossLife -= linkStr ))
		if [[ $bossLife -lt 0 ]]
		then
			bossLife=0
		fi
	elif [[ $1 -eq 2 ]]
	then
		linkLife=$(( linkLife + (linkTotalLife / 2) ))
		if [[ $linkLife -ge $linkTotalLife ]]
		then
			linkLife="$linkTotalLife"
		fi
	fi
	linkLife=$(( linkLife - bossStr ))

}

main( ){
	grepShufflePlayers
	setPlayers
	grepShuffleBosses
	setBoss
	grepShuffleEnemies
	setEnemies
	for (( combat_id=1; combat_id<=10; combat_id++ ))
	do
		clear
		while [ $enemiesLife -gt 1 ]
		do
			if [ $linkLife -lt 0 ]
			then 
				clear
				showDeath
				exit 1			
			fi
			if [ $combat_id -gt 9 ]
			then
				if [ $bossLife -lt 0 ]
				then 
					clear
					showSuccess
					exit 1			
				fi
				showHeader "Boss"
				showLifeBoss
				showLifeLink
				showOptions
				read attaqueOptions
				attaqueBoss $attaqueOptions
			else
				showHeader $combat_id
				showLifeEnemies
				showLifeLink
				showOptions
				read attaqueOptions
				attaque $attaqueOptions
			fi		
			clear 
		done
		enemiesLife=0
		enemiesStr=0
		grepShuffleEnemies
		setEnemies
	done 	
}

main $1 
