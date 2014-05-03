local
   QTK
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   %PATH IMAGES
   CD = {OS.getCWD}
   TailleCase=40
   
   Brave = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/brave.gif')}
   Zombie = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/zombie.gif')}
   Food = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/food.gif')}
   Bullets = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/bullets.gif')}
   Medicine = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/medicine.gif')}
   Floor = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/floor.gif')}
   Wall = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/wall.gif')}
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   Canvas
   LargeurMax
   HauteurMax
   Map
   Command
   CommandPort = {NewPort Command}%VOIR MESSAGE PASSING
   
   fun{MaxWidth Z}
      fun{MaxWidthAcc Z Acc Max}
	 if (Acc-1)=={Width Z} then Max
	 else if {Width Z.Acc} > Max then {MaxWidthAcc Z Acc+1 {Width Z.Acc}}
	      else
		 {MaxWidthAcc Z Acc+1 Max}
	      end
	 end
      end
   in
      {MaxWidthAcc Z 1 0}
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
   %TODO : DOUBLE CONDITION
   fun{RemplirListe Z}
      fun{RemplirListeAcc Z Ligne Col}
	 if (Ligne==HauteurMax) then if (Col=={Width Z.HauteurMax}+1) then nil
				     else
					%et si la porte était en bas?
					r(Wall Col Ligne)|{RemplirListeAcc Z Ligne Col+1}
				     end
	 else if Col=={Width Z.Ligne}+1 then {RemplirListeAcc Z Ligne+1 1}
	      else
		 if (Z.Ligne.Col)==0 then
		    r(Floor Col Ligne)|{RemplirListeAcc Z Ligne Col+1}
		 elseif (Z.Ligne.Col)==1 then
		    r(Wall Col Ligne)|{RemplirListeAcc Z Ligne Col+1}
		 elseif (Z.Ligne.Col)==2 then
		    r(Bullets Col Ligne)|{RemplirListeAcc Z Ligne Col+1}
		 elseif (Z.Ligne.Col)==3 then
		    r(Food Col Ligne)|{RemplirListeAcc Z Ligne Col+1}
		 elseif (Z.Ligne.Col)==4 then
		    r(Medicine Col Ligne)|{RemplirListeAcc Z Ligne Col+1}
		 elseif (Z.Ligne.Col)==5 then
		    r(Brave Col Ligne)|{RemplirListeAcc Z Ligne Col+1}
		 else
		    {RemplirListeAcc Z Ligne Col+1}
		 end
	      end
	 end
      end
   in
      {RemplirListeAcc Z 1 1}
   end
   
   Map={LoadPickle CD#'/map_test.ozp'}
   LargeurMax={MaxWidth Map}
   HauteurMax={Width Map}
   Desc=td(canvas(bg:white %MAP DE BASE (TAILLE ETC)
		  width:TailleCase*LargeurMax
		  height:TailleCase*HauteurMax
		  handle:Canvas))
   Window={QTk.build Desc}
   %ASSIGNER LES TOUCHES
   {Window bind(event:"<Up>" action:proc{$} {Send CommandPort r(0 ~1)} end)}
   {Window bind(event:"<Left>" action:proc{$} {Send CommandPort r(~1 0)} end)}
   {Window bind(event:"<Down>" action:proc{$} {Send CommandPort r(0 1)}  end)}
   {Window bind(event:"<Right>" action:proc{$} {Send CommandPort r(1 0)} end)}
   {Window bind(event:"<space>" action:proc{$} {Send CommandPort finish} end)}
   %%%%%%%%%%%%%%%%%%%%%%%
   
   proc{DrawBox Image X Y}%POUR FAIRE LES CASES (et les images)
      {Canvas create(rect X*40 Y*40 X*40+40 Y*40+40 outline:black)}
      {Canvas create(image X*40-20 Y*40-20 image:Image anchor:center)}
   end
   
   proc{InitLayout ListToDraw}
      proc{DrawHline X1 Y1 X2 Y2}%LIGNES HORIZONTALES
	 if X1>TailleCase*LargeurMax orelse X1<0 orelse Y1>TailleCase*HauteurMax orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawHline X1+40 Y1 X2+40 Y2}
	 end
      end
      proc{DrawVline X1 Y1 X2 Y2}%LIGNES VERTICALES
	 if X1>LargeurMax orelse X1<0 orelse Y1>TailleCase*HauteurMax orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawVline X1 Y1+40 X2 Y2+40}
	 end
      end
      proc{DrawUnits L}%COLOR LES CASES
	 case L of r(Image X Y)|T then
	    {DrawBox Image X Y}
	    {DrawUnits T}
	 else
	    skip
	 end
      end
   in
      {DrawHline 0 0 0 TailleCase*HauteurMax}
      {DrawVline 0 0 TailleCase*LargeurMax 0}
      {DrawUnits ListToDraw}
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
	       %{DrawBox green X Y}
	       %{DrawBox white IX IY}
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
   {Window show}
   %Initialize zombies and user
   %ON VOIT ICI LES CASES A COLORER
   {InitLayout {RemplirListe Map}}
   %{InitLayout [r(Brave 1 2)]}
   %{Game 8 8 Command}
end
