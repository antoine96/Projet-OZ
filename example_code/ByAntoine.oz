local
   QTK
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   %PATH POUR MOI. A TOI DE METTRE LES TIENS (COMME POUR L'AUTRE LE LOAD MAP)
   Brave = {QTk.newImage photo(file:'x-oz://system/wp/brave.gif')}
   Zombie = {QTk.newImage photo(file:'x-oz://system/wp/zombie.gif')}
   Food = {QTk.newImage photo(file:'x-oz://system/wp/food.gif')}
   Bullets = {QTk.newImage photo(file:'x-oz://system/wp/bullets.gif')}
   Medicine = {QTk.newImage photo(file:'x-oz://system/wp/medicine.gif')}
   Floor = {QTk.newImage photo(file:'x-oz://system/wp/floor.gif')}
   Wall = {QTk.newImage photo(file:'x-oz://system/wp/floor.gif')}
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   Canvas
   Z
   Command
   CommandPort = {NewPort Command}%VOIR MESSAGE PASSING
   Desc=td(canvas(bg:green %MAP DE BASE (TAILLE ETC)
		  width:800
		  height:800
		  handle:Canvas))
   Window={QTk.build Desc}
   {Window bind(event:"<Up>" action:proc{$} {Send CommandPort r(0 ~1)} end)} % ASSIGNER LES TOUCHES
   {Window bind(event:"<Left>" action:proc{$} {Send CommandPort r(~1 0)} end)}
   {Window bind(event:"<Down>" action:proc{$} {Send CommandPort r(0 1)}  end)}
   {Window bind(event:"<Right>" action:proc{$} {Send CommandPort r(1 0)} end)}
   {Window bind(event:"<space>" action:proc{$} {Send CommandPort finish} end)}


   
   proc{DrawBox Color X Y}%POUR FAIRE LES CASES
      {Canvas create(rect X*40 Y*40 X*40+40 Y*40+40 fill:Color outline:black)}
   end
   proc{InitLayout ListToDraw}
      proc{DrawHline X1 Y1 X2 Y2}%LIGNES HORIZONTALES
	 if X1>800 orelse X1<0 orelse Y1>800 orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawHline X1+40 Y1 X2+40 Y2}
	 end
      end
      proc{DrawVline X1 Y1 X2 Y2}%LIGNES VERTICALES
	 if X1>800 orelse X1<0 orelse Y1>800 orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawVline X1 Y1+40 X2 Y2+40}
	 end
      end
      proc{DrawUnits L}%COLOR LES CASES
	 case L of r(Color X Y)|T then
	    {DrawBox Color X Y}
	    {DrawUnits T}
	 else
	    skip
	 end
      end
   in
      {DrawHline 0 0 0 800}
      {DrawVline 0 0 800 0}
      {DrawUnits ListToDraw}
   end
   fun {LoadPickle URL}
      F={New Open.file init(url:URL flags:[read])}
   in
      try 
	 VBS
      in
	 {F read(size:all list:VBS)}
	 {Pickle.unpack VBS}
      finally
	 {F close}
      end
   end
   proc{Game OldX OldY Command}%APPLIQUE LES REGLES DU JEU
      NewX NewY
      NextCommand
      fun{UserCommand Command Count X Y LX LY}
	 IX IY in
	 case Command of r(DX DY)|T then
	    if Count == 2 then
	       {UserCommand T Count X Y  LX LY}
	    else
	       IX = X+DX
	       IY = Y+DY
	       {DrawBox green X Y}
	       {DrawBox white IX IY}
	       {UserCommand T Count+1 IX IY LX LY }
	    end
	 [] finish|T then
	    LX = X
	    LY = Y
	    T
	 end
      end
   in
      NextCommand = {UserCommand Command 0 OldX OldY NewX NewY}
      {Game NewX NewY NextCommand}
   end
in
   Z={LoadPickle 'x-oz://system/wp/map_test.ozp'}
   {Browse Z}
   {Window show}
   %Initialize zombies and user
   %ON VOIT ICI LES CASES A COLORER
   {InitLayout [r(yellow 1 12) r(blue 10 3) r(black 11 10) r(white 8 8)]}
   {Game 8 8 Command}
end
