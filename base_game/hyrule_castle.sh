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
linkLife=0
linkStr=0
bossLife=0
bossStr=0
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
	shuffleBosses=$(shuf -e "${shuffleBosses[@]}")
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
					shufflePlayers+=("$combat_id")
			done
	done
	shufflePlayers=$(shuf -e "${shufflePlayers[@]}")
	randomIndex=$(($RANDOM % ${#shufflePlayers[@]}))
	index=${shufflePlayers[$randomIndex]}
	grepPlayers $index
}

grepShuffleEnemies( ){
        file="$base/enemies.csv"
        lastLines=$( tail -1 $file | cut -d ',' -f1  )
		for ((lines=0; lines<$lastLines ; lines++ ))
		do
			combat_id=$(tail -n +2  $file  | cut -d ',' -f1 )
			rarity=$(tail -n +2  $file | cut -d ',' -f13 ) 
			for i in $rarity
			do
				shuffleEnemies+=($combat_id)
			done
        done
		shuffleEnemies=$(shuf -e "${shuffleEnemies[@]}")
        randomIndex=$(($RANDOM % ${#shuffleEnemies[@]}))
        index=${shuffleEnemies[$randomIndex]}
	grepEnemies $index
}



showLifeEnemies ( ){

	bar=''
	for (( i=0; i < $enemiesLife; i++ ))
	do
		bar="${bar}I"
	done

	for (( i=$enemiesLife; i< 30; i++ ))
	do
		bar="${bar}_"
	done
	
	bar="HP: ${bar} ${enemiesLife} / 60"

	echo "$(tput setaf 2)Bokoblin"
	echo $bar
}

showLifeLink ( ){
        bar=''
        for (( i=0; i < $linkLife; i++ ))
        do
                bar="${bar}I"
        done

	for (( i=$linkLife; i< 60; i++ ))
        do
                bar="${bar}_"
        done

	bar="HP: ${bar} ${linkLife} / 60"
	echo ""
	echo "$(tput setaf 1)Link"
	echo $bar
}

setEnemies( ){
	enemiesLife=$( echo $enemiesLine | cut -d ',' -f 3 )
	enemiesStr=$( echo $enemiesLine | cut -d ',' -f 5 )
}

setPlayers( ){
        linkLife=$( echo $playersLine | cut -d ',' -f 3 )
        linkStr=$( echo $playersLine | cut -d ',' -f 5 )
}

setBoss( ){
        bossLife=$( echo $bossesLine | cut -d ',' -f 3 )
        bossStr=$( echo $bossesLine | cut -d ',' -f 5 )
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

attaque ( ){
	if  [[ $1 -eq 1 ]]
	then
		enemiesLife=$(( enemiesLife -= linkStr ))
		if [[ $enemiesLife -lt 0 ]]
		then
			enemiesLife=0
		fi
	elif [[ $1 -eq 2 && $linkLife -lt 30 ]]
	then
		linkLife=35
	fi
	 linkLife=$(( linkLife -= enemiesStr ))

}



main( ){
	grepShufflePlayers
	setPlayers
	grepShuffleBosses
	setBoss
	grepShuffleEnemies
	setEnemies
	for i in `seq 1 10`;
	do
		combat_id=$i
		echo -ne '\033c'
		while [[ $enemiesLife -gt 1 ]]
		do
			showHeader $combat_id
			showLifeEnemies
			showLifeLink
			showOptions
			read attaqueOptions
			attaque $attaqueOptions
			echo -ne '\033c'
		done
		if [[ $combat_id -gt 2 ]]
		then 
			grepShuffleEnemies
			setEnemies
		fi 
	done 
	
}

testing ( ){
	grepShuffleBosses
	setBoss
	grepShufflePlayers
	setPlayers
	grepShuffleEnemies
	setEnemies
	echo " en $enemiesStr"
	echo " boss $bossStr"
	echo "lin $linkStr"

}
#testing 
main $1 
