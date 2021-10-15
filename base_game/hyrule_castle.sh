#/bin/sh

base="/home/devretry/Bureau/etna/zelda/base_game/files"

bossesLine=""
enemiesLine=""
playersLine=""
enemiesLifeBar=""
enemiesLife=30
enemiesStr=5
linkLife=60
linkStr=15
linkLifeBar=""
id=0


grepBosses( ){
														
        while IFS=',' read -r lines
        do
                line=$( echo $lines | cut -d "," -f1 )
		if [[ $line -eq $1 ]]
                then
			echo $lines
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
	echo $1
	while IFS=',' read -r lines
        do
                line=$( echo $lines | cut -d "," -f1 )
                if [[ $line -eq $1 ]]
                then
                        playersLine=$lines
                fi
        done < <(tail -n +2  "$base/players.csv")

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
		enemiesLife=30

	done 

	
}

main $1 
