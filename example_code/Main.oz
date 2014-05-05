local
   QTk
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%RECUPERATION DES ARGUMENTS
   NZombies=15 %Nombre de zombies par défaut (quand on ne passe pas en argument)
   NObjetNeeded=3 %Nombre d'objets nécessaires par défaut (quand on ne passe pas en argument)
   NAmmo=2 %Nombre de balles par défaut (quand on ne passe pas en argument)
   %TODO RECUPERER LES ARGUMENTS

   
   Message="Dead"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%AUTRES
   NObjetTake= 0 %Nb d'objet pris
   NBullets
   NObjetT
   TailleCase=40 %Taille d'une case de la map
   NbZeros %Nombre d'espaces vides dans la map
   Lzombies %Liste des cases ou on mettra des zombies
   Canvas % Le canvas de la carte
   LargeurMax %Largeur maximale de la carte
   HauteurMax %Hauteur maximale de la carte
   Map % La map comme décrite dans le fichier chargé
   MapList %Liste de ce qu'il y a dans la map
   Xbrave %La position horizontale du brave
   Ybrave %La position verticale du brave
   Command % le port
   CommandPort = {NewPort Command}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CHARGEMENT DES IMAGES
   CD = {OS.getCWD}
   Brave = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/brave.gif')}
   Zombie = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/zombie.gif')}
   Food = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/food.gif')}
   Bullets = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/bullets.gif')}
   Medicine = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/medicine.gif')}
   Floor = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/floor.gif')}
   Wall = {QTk.newImage photo(height:TailleCase width:TailleCase file:CD#'/wall.gif')}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun{List N}
      if N==0 then nil
      else
	 N|{List N-1}
      end
   end
   fun{Retirer N L}
      if N==1 then if L==nil then nil else L.2 end
      else
	 L.1|{Retirer N-1 L.2}
      end
   end
   fun{Take N L}
      if N==1 then L.1
      else
	 {Take N-1 L.2}
      end
   end
   fun{ChooseRand N L Taille}
      if N==0 then nil
      else
	 local Rand in Rand=(({Abs {OS.rand}} mod Taille) + 1)
	    {Take Rand L}|{ChooseRand N-1 {Retirer Rand L}  Taille-1}
	 end
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
   fun {CheckCase List X Y Image}
      case List of r(Img Col Ligne)|T then
	 if Col == X then
	    if Ligne==Y then Image==Img
	    else
	       {CheckCase T X Y Image}
	    end
	 else
	    {CheckCase T X Y Image}
	 end
      end
   end

       fun {UpdateList List X Y Image}
      case List of r(Img Col Ligne)|T then
	 if Col == X then
	    if Ligne==Y then
	       r(Image Col Ligne)|T
	    else
	      r(Img Col Ligne)|{UpdateList T X Y Image}
	    end
	 else
	    r(Img Col Ligne)|{UpdateList T X Y Image}
	 end
      end
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
		    Xbrave=Col
		    Ybrave=Ligne
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
   LargeurMax={MaxWidth Map}
   HauteurMax={Width Map}
   Desc=td(title:"Zombieland" canvas(
				 bg:white %MAP DE BASE (TAILLE ETC)
				 width:TailleCase*LargeurMax
				 height:TailleCase*HauteurMax
				 handle:Canvas))
   Window={QTk.build Desc}
   %ASSIGNER LES TOUCHES
   {Window bind(event:"<Up>" action:proc{$} {Send CommandPort r(0 ~1)} end)}
   {Window bind(event:"<Left>" action:proc{$} {Send CommandPort r(~1 0)} end)}
   {Window bind(event:"<Down>" action:proc{$} {Send CommandPort r(0 1)}  end)}
   {Window bind(event:"<Right>" action:proc{$} {Send CommandPort r(1 0)} end)}
   %%%%%%%%%%%%%%%%%%%%%%%
   proc{DrawBox Image X Y}%POUR FAIRE LES CASES (et les images)
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
   proc{Game OldX OldY Command List}%APPLIQUE LES REGLES DU JEU
      NewX NewY
      NextCommand
      fun{UserCommand Command Count X Y LX LY List Nammo Nobjettake}
	 IX IY in
	 {NBullets set(text:Nammo)}
	 {NObjetT set(text:Nobjettake)}
	 case Command of r(DX DY)|T then
	    if Count == 6 then %2 pas à la fois (sans zombie)
	       {UserCommand T Count X Y  LX LY List Nammo Nobjettake}
	    else
	       IX = X+DX
	       IY = Y+DY
	       if {CheckCase List IX IY Wall}==true then %PAS PASSER DANS LES MURS
		  {UserCommand T Count X Y LX LY List Nammo Nobjettake}
	       elseif {CheckCase List IX IY Zombie}==true then
		  
		  if Nammo==0 then
		     
		     {DrawBox Floor X Y}
		     {UserCommand finish|nil Count X Y LX LY List Nammo Nobjettake}
		     %%DEAD {Browse Message}
		     
		  else
		     
		     {DrawBox Floor X Y}
		     {DrawBox Brave IX IY}
		     {UserCommand T Count+1 IX IY LX LY {UpdateList List IX IY Floor} Nammo-1 Nobjettake} %perd une munition si tue zombie
		  end
	       else
		  if {CheckCase List IX IY Floor}==false then %Ramasser compte pour 1 pas
		     if{CheckCase List IX IY Bullets}==true then if Count<5 then  {DrawBox Floor  X Y}
								    {DrawBox Brave IX IY} {UserCommand T Count+2 IX IY LX LY {UpdateList List IX IY Floor} Nammo+1 Nobjettake}
								 else
								    {UserCommand T Count X Y LX LY List Nammo Nobjettake} %PROBLEME ICI
								 end
		 %gagne une mun si il en ramasse une
		     elseif{CheckCase List IX IY Medicine}==true then if Count<5 then  {DrawBox Floor  X Y}
									 {DrawBox Brave IX IY}{UserCommand T Count+2 IX IY LX LY {UpdateList List IX IY Floor} Nammo Nobjettake+1}
								      else
									 {UserCommand T Count X Y LX LY List Nammo Nobjettake} %PROBLEME ICI
								      end
		     elseif{CheckCase List IX IY Food}==true then if Count<5 then  {DrawBox Floor  X Y}
								     {DrawBox Brave IX IY}{UserCommand T Count+2 IX IY LX LY {UpdateList List IX IY Floor} Nammo Nobjettake+1}
								  else
								     {UserCommand T Count X Y LX LY List Nammo Nobjettake} %PROBLEME ICI
								  end
		     else if Nobjettake>=NObjetNeeded then {UserCommand win|nil Count X Y LX LY List Nammo Nobjettake}
			  else {UserCommand finish|nil Count X Y LX LY List Nammo Nobjettake}
			  end
		     end
		     
		  else
		     {DrawBox Floor  X Y}
		     {DrawBox Brave IX IY}
		     {UserCommand T Count+1 IX IY LX LY List Nammo Nobjettake}
		  end
	       end
	       
	       
	    end
	 [] finish|T then
	    {Canvas create(rect 0 0 TailleCase*LargeurMax TailleCase*HauteurMax fill:black outline:black)}
	    {Canvas create(text ((TailleCase*LargeurMax) div 2) ((TailleCase*HauteurMax) div 2) text:"GAME OVER" fill:red)}
	    {Canvas create(text ((TailleCase*LargeurMax) div 2) ((TailleCase*HauteurMax) div 2)+15 text:"Press space bar to close the window" fill:red)}
	    {Canvas create(text (TailleCase*LargeurMax)-130 (TailleCase*HauteurMax)-20 text:"By Daubry Benjamin & Van Malleghem Antoine" fill:red)}
	    LX = X
	    LY = Y
	    T
	 [] win|T then
	    {Canvas create(rect 0 0 TailleCase*LargeurMax TailleCase*HauteurMax fill:black outline:black)}
	    {Canvas create(text ((TailleCase*LargeurMax) div 2) ((TailleCase*HauteurMax) div 2) text:"YOU WIN !!!!!!!!" fill:red)}
	    {Canvas create(text ((TailleCase*LargeurMax) div 2) ((TailleCase*HauteurMax) div 2)+15 text:"Press space bar to close the window" fill:red)}
	    {Canvas create(text (TailleCase*LargeurMax)-130 (TailleCase*HauteurMax)-20 text:"By Daubry Benjamin & Van Malleghem Antoine" fill:red)}
	    LX = X
	    LY = Y
	    T
	 end
      end
   in
      NextCommand = {UserCommand Command 0 OldX OldY NewX NewY List NAmmo NObjetTake}
   end
in
   {Window show}
   NbZeros={CountZero Map}
   if NbZeros < NZombies then Lzombies={Trier {ChooseRand NbZeros {List NbZeros} NbZeros}}
   else
      Lzombies= {Trier {ChooseRand NZombies {List NbZeros} NbZeros}}
   end
   MapList={RemplirListe Map Lzombies}
   {InitLayout MapList}
   {Canvas create(text 55 10 text:"Number of bullets :" fill:red)}
   {Canvas create(text 125 10 text:NAmmo fill:red handle:NBullets)}
   {Canvas create(text 410 10 text:"Item needed :" fill:red)}
   {Canvas create(text 460 10 text:NObjetTake fill:red handle:NObjetT)}
   {Canvas create(text 470 10 text:"/" fill:red)}
    {Canvas create(text 475 10 text:NObjetNeeded fill:red)}
   {Send CommandPort r(0 1)}
   {Game Xbrave Ybrave Command MapList}
   {Window bind(event:"<space>" action:toplevel#close)}
end
