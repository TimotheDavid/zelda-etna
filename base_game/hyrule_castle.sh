#/bin/sh

base="/home/devretry/Bureau/etna/zelda/base_game/files"
shuffleBosses=()
shuffleEnemies=()
shufflePlayers=()
bossesLine=""
enemiesLine=""
playersLine=""
enemiesLifeBar=""
enemiesLife=30
enemiesStr=5
linkLife=60
linkStr=15
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
	lastLinesBosses=$( tail -1 $file | cut -d ',' -f1  ) 
	for ((lines=0; lines<$lastLinesBosses ; lines++ ))
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
	index=${shuffleBosses[$indexBosses]}
	grepBosses $index
}

grepShufflePlayers( ){
        file="$base/players.csv"
        lastLinesBosses=$( tail -1 $file | cut -d ',' -f1  ) 
        for ((lines=0; lines<$lastLinesBosses ; lines++ ))
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
        index=${shuffleBosses[$indexBosses]}
        grepPlayers $index
}

grepShuffleEnemies( ){
        file="$base/enemies.csv"
        lastLinesBosses=$( tail -1 $file | cut -d ',' -f1  ) 
        for ((lines=0; lines<$lastLinesBosses ; lines++ ))
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
        index=${shuffleBosses[$indexBosses]}
        grepEnemies $index
}

setPlayers( ){
	linkLife=$( echo $playersLine | cut -d ',' -f3 )
	linkStr=$( echo $playersLine | cut -d ',' -f5 )

}

setEnenemies( ){
        enemiesLife=$( echo $enemiesLine | cut -d ',' -f3 )
        enemiesStr=$( echo $enemiesLine | cut -d ',' -f5 )
}

setBoss( ){
	bossLife=$( echo $bossesLine | cut -d ',' -f3 )
	bossStr=$( echo $bossesLine | cut -d ',' -f5 )
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
	if  [[ $1 == 1 ]]
	then
		enemiesLife=$(( enemiesLife -= $linkStr ))
	fi

	if [[ $1 == 2 ]]
	then
		if [[ $linkLife -lt 30 ]]
		then
			linkLife=35
		fi

	fi
	 linkLife=$(( linkLife -= $enemiesStr ))

}



main( ){
	grepShuffleBosses
	setBoss

	for (( id=1; id<11; id++ ))
	do
		echo -ne '\033c'
		while [ $enemiesLife -gt 1 ]
		do
			showHeader $id
			showLifeEnemies
			showLifeLink
			showOptions
			read attaqueOptions
			attaque $attaqueOptions
			echo -ne '\033c'
		done
		grepShuffleEnemies
		setEnenemies
		enemiesLife=30

	done 

	
}

testing ( ){
	grepShuffleEnemies
	echo $enemiesLine
	setEnenemies
	echo $enemiesLife

}
#testing 
main $1 
