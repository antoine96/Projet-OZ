declare
QTk
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}

CD = {OS.getCWD}
PlayerA = {QTk.newImage photo(file:CD#'/food.gif')}
PlayerB = {QTk.newImage photo(file:CD#'/floor.gif')}
Food = {QTk.newImage photo(file:CD#'/brave.gif')}
Bomb = {QTk.newImage photo(file:CD#'/bullets.gif')}

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
{{QTk.build Desc} show}
%{{QTk.build td(Desc)} show}