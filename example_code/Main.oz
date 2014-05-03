local
   QTK
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
   %PATH IMAGES
   CD = {OS.getCWD}
   TailleCase=40
   NbZeros
   Lzombies
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
   fun {Numbers N J}
      if N == 0 then
	 nil
      else
	  (({Abs {OS.rand}} mod J) + 1)|{Numbers N-1 J}
      end
   end
   fun{Trier L}
      fun{Concat Xs Ys}
	 case Xs of X|Xr then
	    X|{Concat Xr Ys}
	 [] nil then Ys
	 end
      end
      proc{Partition L2 X L R}
	 case L2
	 of Y|M2 then
	    if Y<X then Ln in
	       L=Y|Ln
	       {Partition M2 X Ln R}
	    else Rn in
	       R=Y|Rn
	       {Partition M2 X L Rn}
	    end
	 [] nil then L=nil R=nil
	 end
      end
   in
      case L of X|L2 then Left Right SL SR in
	 {Partition L2 X Left Right}
	 SL={Trier Left}
	 SR={Trier Right}
	 {Concat SL X|SR}
      [] nil then nil end
   end
   fun{CountZero Map}
      fun{CountZero Map Acc Lignes}
	 fun{CountZeroAcc L Acc Col}
	    if (Col-1)=={Width L} then Acc
	    else
	       if L.Col==0 then {CountZeroAcc L Acc+1 Col+1}
	       else
		  {CountZeroAcc L Acc Col+1}
	       end
	    end
	 end
      in
	 if (Lignes-1)=={Width Map} then Acc
	 else
	    {CountZero Map Acc+{CountZeroAcc Map.Lignes 0 1} Lignes+1}
	 end
      end
   in
      {CountZero Map 0 1}
   end
   
   fun{Double L NbZeros}
      fun{DoublonList L NbZeros Acc}
	 fun{Doublon A L NbZeros Acc}
	    case L of nil then A
	    [] H|T then if A==H then {Doublon (({Abs {OS.rand}} mod NbZeros) + 1) Acc NbZeros Acc}
			else
			   {Doublon A T NbZeros Acc}
			end
	    end
	 end
      in
	 case L of nil then nil
	 [] H|T then {Doublon H T NbZeros Acc}|{DoublonList T NbZeros Acc}
	 end
      end
   in
      {DoublonList L NbZeros L}
   end
   
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
   fun{RemplirListe Z Zombies}
      fun{RemplirListeAcc Z Ligne Col Zombies Acc2}
	 if (Ligne==HauteurMax) then if (Col=={Width Z.HauteurMax}+1) then nil
				     else
					if (Z.Ligne.Col)==5 then
					   r(Brave Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2}
					else
					   r(Wall Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2}
					end
				     end
	 else if Col=={Width Z.Ligne}+1 then {RemplirListeAcc Z Ligne+1 1 Zombies Acc2}
	      else
		 if (Z.Ligne.Col)==0 then
		    if Zombies==nil then r(Floor Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2+1}
		    else
		       if Acc2==Zombies.1 then 
			  r(Zombie Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies.2 Acc2+1}
		       else
			  r(Floor Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2+1}
		       end
		    end
		 elseif (Z.Ligne.Col)==1 then
		    r(Wall Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2}
		 elseif (Z.Ligne.Col)==2 then
		    r(Bullets Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2}
		 elseif (Z.Ligne.Col)==3 then
		    r(Food Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2}
		 elseif (Z.Ligne.Col)==4 then
		    r(Medicine Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2}
		 elseif (Z.Ligne.Col)==5 then
		    r(Brave Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2}
		 else
		    {RemplirListeAcc Z Ligne Col+1 Zombies Acc2}
		 end
	      end
	 end
      end
   in
      {RemplirListeAcc Z 1 1 Zombies 1}
   end
   Map={LoadPickle CD#'/map_test.ozp'}
   %Map=map(r(1 1 0 0 0 0)
	   %r(0 0 0 1 1 1)
	   %r(0 0 1)
	   %r(1))
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
     % {Canvas create(rect X*40 Y*40 X*40+40 Y*40+40 outline:black)}
      {Canvas create(image X*40-20 Y*40-20 image:Image anchor:center)}
   end
   
   proc{InitLayout ListToDraw}

      proc{DrawUnits L}%COLOR LES CASES
	 case L of r(Image X Y)|T then
	    {DrawBox Image X Y}
	    {DrawUnits T}
	 else
	    skip
	 end
      end
   in

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
   NbZeros={CountZero Map}
   Lzombies= {Trier {Double {Numbers 5 NbZeros} NbZeros}}
   {InitLayout {RemplirListe Map Lzombies}}
   %{Game 8 8 Command}
end
