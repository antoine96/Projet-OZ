local
   QTk
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%RECUPERATION DES ARGUMENTS
   NZombies=3 %Nombre de zombies par d�faut (quand on ne passe pas en argument)
   NObjetNeeded=3 %Nombre d'objets n�cessaires par d�faut (quand on ne passe pas en argument)
   NAmmo=2 %Nombre de balles par d�faut (quand on ne passe pas en argument)
   %TODO RECUPERER LES ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%AUTRES
   NObjetTake= 0 %Nb d'objet pris
   NBullets
   NObjetT
   Xporte
   Yporte
   S1
   S2
   L1
   LZ %Coordonn�es Zombie
   TailleCase=40 %Taille d'une case de la map
   NbZeros %Nombre d'espaces vides dans la map
   Lzombies %Liste des cases ou on mettra des zombies
   Canvas % Le canvas de la carte
   LargeurMax %Largeur maximale de la carte
   HauteurMax %Hauteur maximale de la carte
   Map % La map comme d�crite dans le fichier charg�
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
   %LISTE FINIT TOUJOURS SUR NIL APPAREMMENT
   fun {CheckCase List X Y Image}
      case List of nil then Image=='Floor'
      []r(Img Col Ligne)|T then
	 if Col==X then
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
   
   fun{ListZombie MapList}
      case MapList of nil then nil
      []r(Img X Y)|T then
	 if Img==Zombie then
	    r(X Y)|{ListZombie T}
	 else
	    {ListZombie T}
	 end
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
		    Xporte=Col
		    Ybrave=Ligne
		    Yporte=Ligne
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
%direction al�atoire
   fun{ChooseDirection}
      local I DX DY in
	 I =(({Abs {OS.rand}} mod 4) + 1)
	 if I == 1 then DX=~1 DY=0
	 elseif I==2 then DX=0 DY=~1
	 elseif I==3 then DX=1 DY=0
	 else DX=0 DY=1
	 end
	 r(DX DY)
     end
   end
   %Idealement faut retirer un zombie quand il meurt, ce quon fais pas. ON VA FAIRE UNE FONCTION POUR CA QU'ON APPELERA DANS GAME ; IZI WIN
   %mais FAUX car ordre de la MAPLIST doit changer du coup : POURQUOI ? AUCUNE RELATION D'ORDRE DANS LA MAPLIST JE CROIS
   fun {UpdateListZombie List X Y XN YN}
      case List of r(Col Ligne)|T then
	 if Col==X then
	    if Ligne==Y then
	       r(XN YN)|T
	    else
	       List.1|{UpdateListZombie T X Y XN YN}
	    end
	 else
	    List.1|{UpdateListZombie T X Y XN YN}
	 end
      end
   end
%ON NE VA FAIRE QU'UN MOUVEMENT 
   fun{ZombieMove X0 Y0 Dir Liste N LZ C}
      local
	 XNew
	 YNew
      in
	 {Delay 100}
	 if N=<0 then Liste#LZ
	 else
	    XNew=X0+Dir.1
	    YNew=Y0+Dir.2
	    if{CheckCase Liste XNew YNew Floor}==false then
	       if {CheckCase Liste XNew YNew Wall}==false then
		  if {CheckCase Liste XNew YNew Zombie}==false then %cas ou cest objet, faut 20% de chance de ramasser, sinon changedirection

		     
		     if N=<1 then
			{ZombieMove X0 Y0 {ChooseDirection} Liste N LZ C}
		     else
			local Luck in
			   Luck=(({Abs {OS.rand}} mod 5) + 1)
			   if Luck==3 then
			      {DrawBox Floor X0 Y0}
			      {DrawBox Zombie XNew YNew}
			      local L in
				 L={UpdateList Liste X0 Y0 Floor}
				 {ZombieMove XNew YNew Dir {UpdateList L XNew YNew Zombie} N-2 {UpdateListZombie LZ X0 Y0 XNew YNew} C}
			      end
			   else
			      {ZombieMove X0 Y0 {ChooseDirection} Liste N LZ C}
			   end
			end
			
		     end
		     
		  else
		     {ZombieMove X0 Y0 {ChooseDirection} Liste N LZ C}
		  end
		  
	       else
		  {ZombieMove X0 Y0 {ChooseDirection} Liste N LZ C} %LE CHECKCASE FOIRE ICI
	       end
	       
	    else
	       {DrawBox Floor X0 Y0}
	       {DrawBox Zombie XNew YNew}
	       local L in
		  L={UpdateList Liste X0 Y0 Floor}
		  {ZombieMove XNew YNew Dir {UpdateList L XNew YNew Zombie} N-1 {UpdateListZombie LZ X0 Y0 XNew YNew} C}
	       end
	       
	      
	    end
	 end
      end
   end
   %SELECTIONNE JUSTE LES ZOMBIES DONC LE BUG NE VIENT PAS DE LA
   fun{ZombieFun MapListe ZombieL ZombieUpd C S1}
      case S1 of _|T1 then case ZombieL of nil then ok|{Game C.1 C.2 Command MapList T1}
			   [] r(X Y)|T then
			      local R in
				 R={ZombieMove X Y {ChooseDirection} MapListe 3 ZombieUpd C}

				 {ZombieFun R.1 T R.2 C S1}

			      end
	 
			   end
      end
   end
   
      

   %IL FAUT QUE GAME RENVOIT LA LISTE MODIFIEE QUAND ON A FINI NOS 3 TOURS
   fun{Game OldX OldY Command List S2}%APPLIQUE LES REGLES DU JEU
      NewX NewY
      NextCommand
      fun{UserCommand Command Count X Y LX LY List Nammo Nobjettake}
	 IX IY in
	 {NBullets set(text:Nammo)}
	 {NObjetT set(text:Nobjettake)}
	 case Command of r(DX DY)|T then
	    if Count == 2 then %2 pas � la fois (sans zombie)
	       local LZombie R C in
		  C=r(X Y)
		  case S2 of _|T2 then
		     LZombie={ListZombie List}
		     ok|{ZombieFun List LZombie LZombie C T2}
		  end
	       end
	    else
	       IX = X+DX
	       IY = Y+DY
	       if {CheckCase List IX IY Wall}==true then %PAS PASSER DANS LES MURS
		  {UserCommand T Count X Y LX LY List Nammo Nobjettake}
	       elseif {CheckCase List IX IY Zombie}==true then
		  if Nammo==0 then
		     {DrawBox Floor X Y}
		     {UserCommand finish|nil Count X Y LX LY List Nammo Nobjettake}
		  else
		     {DrawBox Floor X Y}
		     {DrawBox Brave IX IY}
		     {UserCommand T Count+1 IX IY LX LY {UpdateList List IX IY Floor} Nammo-1 Nobjettake} %perd une munition si tue zombie
		  end
	       elseif{CheckCase List IX IY Bullets}==true then if Count<1 then  {DrawBox Floor  X Y}
								  {DrawBox Brave IX IY} {UserCommand T Count+2 IX IY LX LY {UpdateList List IX IY Floor} Nammo+1 Nobjettake+1}
							       else
								  {UserCommand T Count X Y LX LY List Nammo Nobjettake} %PROBLEME ICI
							       end
		 %gagne une mun si il en ramasse une
	       elseif{CheckCase List IX IY Medicine}==true then if Count<1 then  {DrawBox Floor  X Y}
								   {DrawBox Brave IX IY}{UserCommand T Count+2 IX IY LX LY {UpdateList List IX IY Floor} Nammo Nobjettake+1}
								else
								   {UserCommand T Count X Y LX LY List Nammo Nobjettake} %PROBLEME ICI
								end
	       elseif{CheckCase List IX IY Food}==true then if Count<1 then  {DrawBox Floor  X Y}
							       {DrawBox Brave IX IY}{UserCommand T Count+2 IX IY LX LY {UpdateList List IX IY Floor} Nammo Nobjettake+1}
							    else
							       {UserCommand T Count X Y LX LY List Nammo Nobjettake} %PROBLEME ICI
							    end
	       elseif IX==Xporte andthen IY==Yporte then  if Nobjettake>=NObjetNeeded then {UserCommand win|nil Count IX IY LX LY List Nammo Nobjettake}
							  else {UserCommand finish|nil Count IX IY LX LY List Nammo Nobjettake}
							  end
	       elseif{CheckCase List IX IY Floor}==true then {DrawBox Floor  X Y}
		  {DrawBox Brave IX IY}
		  {UserCommand T Count+1 IX IY LX LY List Nammo Nobjettake}
	       else
		  {UserCommand T Count X Y LX LY List Nammo Nobjettake}
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
   LZ={ListZombie MapList}
  % L1={ZombieFun MapList LZ LZ}
   thread S2={ZombieFun MapList LZ LZ r(Xbrave Ybrave) S1} end
   thread S1={Game Xbrave Ybrave Command MapList ok|S2} end
   {Window bind(event:"<space>" action:toplevel#close)}
end