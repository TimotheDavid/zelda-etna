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
id=0


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
	echo $1
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
		id=$(tail -n +2  $file  | cut -d ',' -f1 )
		rarity=$(tail -n +2  $file | cut -d ',' -f13 )
	for i in $rarity 
		do
			shuffleBosses+=($id)
		done 
	done
	shuffleBosses=$(shuf -e "${shuffleBosses[@]}")
	randomIndex=$[$RANDOM % ${#shuffleBosses[@]}]
	index=${shuffleBosses[$randomIndex]}
	grepBosses $index
}

grepShufflePlayers( ){
        file="$base/players.csv"
        lastLines=$( tail -1 $file | cut -d ',' -f1  )
        for ((lines=0; lines<$lastLines ; lines++ ))
        do
                id=$( tail -n +2  $file  | cut -d ',' -f1 )
                rarity=$( tail -n +2  $file | cut -d ',' -f13 )
        for i in $rarity
                do
                        shufflePlayers+=($id)
                done
        done
        shufflePlayers=$(shuf -e "${shufflePlayers[@]}")
        randomIndex=$[$RANDOM % ${#shufflePlayers[@]}]
        index=${shufflePlayers[$randomIndex]}
	grepPlayers $index
}

grepShuffleEnemies( ){
        file="$base/enemies.csv"
        lastLines=$( tail -1 $file | cut -d ',' -f1  )
	for ((lines=0; lines<$lastLines ; lines++ ))
        do
                id=$(tail -n +2  $file  | cut -d ',' -f1 )
                rarity=$(tail -n +2  $file | cut -d ',' -f13 ) 
		for i in $rarity
                do
                        shuffleEnemies+=($id)
                done
        done
	shuffleEnemies=$(shuf -e "${shuffleEnemies[@]}")
        randomIndex=$[$RANDOM % ${#shuffleEnemies[@]}]
        index=${shuffleEnemies[$randomIndex]}
	echo $index 
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
	enemiesLife=$( echo $enemiesLine | cut -d ',' -f3 )
	enemiesStr=$( echo $enemiesLine | cut -d ',' -f5 )
}

setPlayers( ){
        linkLife=$( echo $playersLine | cut -d ',' -f3 )
        linkStr=$( echo $playersLine | cut -d ',' -f5 )
}

setBoss( ){
        bossLife=$( echo $bossesLine | cut -d ',' -f3 )
        bossStr=$( echo $bossesLine | cut -d ',' -f5 )
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
	if  [ $1 -eq 1 ]
	then
		enemiesLife=$(( enemiesLife -= $linkStr ))
	fi

	if [ $1 -eq 2 ]
	then
		if [[ $linkLife -lt 30 ]]
		then
			linkLife=35
		fi

	fi
	 linkLife=$(( linkLife -= $enemiesStr ))

}



main( ){
	grepShufflePlayers
	setPlayers
	grepShuffleBosses
	setBoss
	grepShuffleEnemies
	setEnemies
	for (( id=1; id<11; id++ ))
	do
		echo -ne '\033c'
		while [[ $enemiesLife -gt 1 ]]
		do
			showHeader $id
			showLifeEnemies
			showLifeLink
			showOptions
			read attaqueOptions
			attaque $attaqueOptions
			echo -ne '\033c'
		done
		if [[ $id > 2 ]]
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
