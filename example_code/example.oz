declare
QTk
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}

CD = {OS.getCWD}
Brave = {QTk.newImage photo(file:CD#'/brave.gif')}
Zombie = {QTk.newImage photo(file:CD#'/zombie.gif')}
Food = {QTk.newImage photo(file:CD#'/food.gif')}
Bullets = {QTk.newImage photo(file:CD#'/bullets.gif')}
Medicine = {QTk.newImage photo(file:CD#'/medicine.gif')}
Floor = {QTk.newImage photo(file:CD#'/floor.gif')}
Wall = {QTk.newImage photo(file:CD#'/wall.gif')}
L R
Desc = td(
	  lr(
	     label(image: Brave)
	     label(image: Zombie)
	     )
	  lr(
	     label(image: Food)
	     label(image: Bullets)
	     )
	  
	  )

{{QTk.build td(Desc)} show}