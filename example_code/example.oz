declare
QTk
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}

CD = {OS.getCWD}
PlayerA = {QTk.newImage photo(file:CD#'/playerA.gif')}
PlayerB = {QTk.newImage photo(file:CD#'/playerB.gif')}
Food = {QTk.newImage photo(file:CD#'/food.gif')}
Bomb = {QTk.newImage photo(file:CD#'/bomb.gif')}

L R
Desc = td(
	  lr(
	     label(image: PlayerA)
	     label(image: PlayerB)
	     )
	  lr(
	     label(image: Food)
	     label(image: Bomb)
	     )
	  
	  )

{{QTk.build td(Desc)} show}