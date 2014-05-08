local
   QTk
   [QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%RECUPERATION DES ARGUMENTS
   NZombies=40 %Nombre de zombies par défaut (quand on ne passe pas en argument)
   NObjetNeeded=3 %Nombre d'objets nécessaires par défaut (quand on ne passe pas en argument)
   NAmmo=2 %Nombre de balles par défaut (quand on ne passe pas en argument)
   %TODO RECUPERER LES ARGUMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%AUTRES
   NObjetTake= 0 %Nb d'objet pris
   NBullets
   NObjetT
   Xporte
   Yporte
   L1
   L2
   LZ %Coordonnées Zombie
   TailleCase=40 %Taille d'une case de la map
   NbZeros %Nombre d'espaces vides dans la map
   Canvas % Le canvas de la carte
   LargeurMax %Largeur maximale de la carte
   HauteurMax %Hauteur maximale de la carte
   Map % La map comme décrite dans le fichier chargé
   MapList %Liste de ce qu'il y a dans la map
   Xbrave %La position horizontale du brave
   Ybrave %La position verticale du brave
   Command % le port
   CommandPort = {NewPort Command}
   CommandZombie
   CommandZombiePort
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
   %Fonction qui nous donne la position relative des zombies (par rapport au nombre de Floor(0) sur la map
   fun{ZombiesNumber NbZombies Map}
      fun{List N}
	 if N==0 then nil
	 else
	    N|{List N-1}
	 end
      end
      fun{ChooseRand N L Taille}
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
      in
	 
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
   in
      NbZeros={CountZero Map}
      if NbZeros < NZombies then
	 {Trier {ChooseRand NbZeros {List NbZeros} NbZeros}}
      else
	 {Trier {ChooseRand NZombies {List NbZeros} NbZeros}}
      end
   end



   
  
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
   
   fun{RemplirListe Z Zombies}
      fun{RemplirListeAcc Z Ligne Col Zombies Acc2}
	 if (Ligne==HauteurMax) andthen (Col=={Width Z.HauteurMax}+1) then
	    nil
	 else if Col=={Width Z.Ligne}+1 then
		 {RemplirListeAcc Z Ligne+1 1 Zombies Acc2}
	      else
		 if (Z.Ligne.Col)==0 then
		    if Zombies==nil then
		       r(Floor Col Ligne)|{RemplirListeAcc Z Ligne Col+1 Zombies Acc2+1}
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
   proc{BuildZombiePort N ?S ?P}
      S={MakeTuple s N}
      P={MakeTuple p N}
      for I in 1..N do
	 P.I={NewPort S.I}
      end
   end
   proc{ChooseDirection N}
      local I in
	    I =(({Abs {OS.rand}} mod 4) + 1)
	    if I == 1 then {Send CommandZombiePort.N r(~1 0)}
	    elseif I==2 then  {Send CommandZombiePort.N r(0 ~1)}
	    elseif I==3 then  {Send CommandZombiePort.N r(1 0)}
	    else  {Send CommandZombiePort.N r(0 1)}
	    end
      end
   end
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
   fun{ZombiesMove ZombieListe N MapListe Command R}
      Liste
      fun{ZombieGame OldX OldY Command MapListe R}
	 fun{ZombieCommand Command Count X Y MapListe R AntiBug}
	    {NBullets set(text:R.1)}
	    if Count == 3 then
	       MapListe#R.1
	    else
	       IX IY in
	       case Command of r(DX DY)|T then
		  IX = X+DX
		  IY = Y+DY
		  if {CheckCase MapListe IX IY Wall} orelse {CheckCase MapListe IX IY Zombie}==true then
		     {ChooseDirection N}
		     {ZombieCommand T Count X Y MapListe R AntiBug+1} 
		  elseif {CheckCase MapListe IX IY Floor}==true then
		     {Delay 200}
		     {DrawBox Floor X Y}
		     {DrawBox Zombie IX IY}
		     {ZombieCommand Command Count+1 IX IY {UpdateList {UpdateList MapListe IX IY Zombie} X Y Floor} R AntiBug}
		  elseif {CheckCase MapListe IX IY Brave}==true then
		     local Nammo DirX DirY in
			Nammo = R.1
			DirX=R.2.1.1
			DirY=R.2.1.2
			{Browse DirY}
			if(R.1==0) orelse DirX==DX orelse DirY==DY then%pas de mun, tue le brave--Meme direction = zombie derriere, tue le brave ENVOYER GAME OVER !?
			   {Delay 200}
			   {DrawBox Floor X Y}
			   {DrawBox Zombie IX IY}
			   1
			else
			   {Delay 200}
			   {DrawBox Floor X Y}
			   {ZombieCommand Command 3 X Y {UpdateList MapListe X Y Floor} (Nammo-1)#R.2 AntiBug} %Zombie se fait tuer, je sais pas trop comment faire. Deja mis a jour la liste. Comment passer au zombie suivant?
			end
		     end
		  elseif {CheckCase MapListe IX IY Medicine} orelse {CheckCase MapListe IX IY Bullets} orelse {CheckCase MapListe IX IY Food} then
		     if Count=<1 then
			if (({Abs {OS.rand}} mod 5) + 1)==3 then
			   {Delay 1000}
			   {DrawBox Floor X Y}
			   {DrawBox Zombie IX IY}
			   {ZombieCommand Command Count+2 IX IY {UpdateList {UpdateList MapListe IX IY Zombie} X Y Floor} R AntiBug}
			else
			   {ChooseDirection N}
			   {ZombieCommand T Count X Y MapListe R AntiBug}
			end
		     else
			{ChooseDirection N}
			{ZombieCommand T Count X Y MapListe R AntiBug}
		     end
		  elseif {CheckCase MapListe IX IY Zombie} then
		     if(AntiBug >=4) then
			{Delay 200}
			{DrawBox Floor X Y}
			{ZombieCommand Command Count+2 IX IY {UpdateList MapListe  X Y Floor} R 0}
		     else
			{ChooseDirection N}
			{ZombieCommand T Count X Y MapListe R AntiBug+1}
		     end

		  else
		     {ChooseDirection N}
		     {ZombieCommand T Count X Y MapListe R AntiBug}
		  end
	       end
	    end
	 end
      in
	 {ZombieCommand Command 0 OldX OldY MapListe R 0}
      end
   in
      case ZombieListe of nil then MapListe#R.1
      [] r(X Y)|T then
	 local Res in
	    {ChooseDirection N}
	    Res={ZombieGame X Y Command.N MapListe R}
	    if Res==1 then
	       1
	    else
	       {ZombiesMove T N+1 Res.1 Command Res.2#R.2}
	    end
	 end
      end
   end
   fun{Game OldX OldY Command List}
      fun{UserCommand Command Count X Y List Nammo Nobjettake R}
	 {NBullets set(text:Nammo)}
	 {NObjetT set(text:Nobjettake)}
	 if Count==2 then
	    local Res in
	       Res={ZombiesMove {ListZombie List} 1 List CommandZombie Nammo#R}
	       if Res==1 then
		  1
	       else
		  {UserCommand Command 0 X Y Res.1 Res.2  Nobjettake R}
	       end
	    end
	 else
	    local IX IY
	    in
	       case Command of r(DX DY)|T then   
		  IX = X+DX
		  IY = Y+DY
		  if {CheckCase List IX IY Wall} then
		     {UserCommand T Count X Y List Nammo Nobjettake R}
		  elseif {CheckCase List IX IY Zombie} then
		     if Nammo==0 then
			{DrawBox Floor X Y}
			1
		     else
			{DrawBox Floor X Y}
			{DrawBox Brave IX IY}
			{UserCommand T Count+1 IX IY {UpdateList {UpdateList List IX IY Brave} X Y Floor} Nammo-1 Nobjettake r(DX DY)|R}
		     end
		  elseif{CheckCase List IX IY Bullets} then
		     if Count<1 then
			{DrawBox Floor  X Y}
			{DrawBox Brave IX IY}
			{UserCommand T Count+2 IX IY {UpdateList {UpdateList List IX IY Brave} X Y Floor} Nammo+1 Nobjettake r(DX DY)|R}
		     else
			{UserCommand T Count X Y List Nammo Nobjettake R}
		     end
		  elseif{CheckCase List IX IY Medicine} orelse {CheckCase List IX IY Food} then
		     if Count<1 then
			{DrawBox Floor  X Y}
			{DrawBox Brave IX IY}
			{UserCommand T Count+2 IX IY {UpdateList {UpdateList List IX IY Brave} X Y Floor} Nammo Nobjettake+1 r(DX DY)|R}
		     else
			{UserCommand T Count X Y List Nammo Nobjettake R} %PROBLEME ICI
		     end
		  elseif IX==Xporte andthen IY==Yporte then  if Nobjettake>=NObjetNeeded then {UserCommand win|nil Count IX IY List Nammo Nobjettake R}
							     else 1
							     end
		  elseif{CheckCase List IX IY Floor} then
		     {DrawBox Floor  X Y}
		     {DrawBox Brave IX IY}
		     {UserCommand T Count+1 IX IY {UpdateList {UpdateList List IX IY Brave} X Y Floor} Nammo Nobjettake r(DX DY)|R}
		  else
		     {UserCommand T Count X Y List Nammo Nobjettake R}
		  end
	       [] win|T then
		  {Canvas create(rect 0 0 TailleCase*LargeurMax TailleCase*HauteurMax fill:black outline:black)}
		  {Canvas create(text ((TailleCase*LargeurMax) div 2) ((TailleCase*HauteurMax) div 2) text:"YOU WIN !!!!!!!!" fill:red)}
		  {Canvas create(text ((TailleCase*LargeurMax) div 2) ((TailleCase*HauteurMax) div 2)+15 text:"Press space bar to close the window" fill:red)}
		  {Canvas create(text (TailleCase*LargeurMax)-130 (TailleCase*HauteurMax)-20 text:"By Daubry Benjamin & Van Malleghem Antoine" fill:red)}
		  T
	       end
	    end
	 end
      end
      
   in
      {UserCommand Command 0 OldX OldY List NAmmo NObjetTake nil}
   end
in
   {Window show}
   MapList={RemplirListe Map {ZombiesNumber NZombies Map}}
   {InitLayout MapList}
   {BuildZombiePort NZombies CommandZombie CommandZombiePort}
   {Canvas create(text 55 10 text:"Number of bullets :" fill:red)}
   {Canvas create(text 125 10 text:NAmmo fill:red handle:NBullets)}
   {Canvas create(text 410 10 text:"Item needed :" fill:red)}
   {Canvas create(text 460 10 text:NObjetTake fill:red handle:NObjetT)}
   {Canvas create(text 470 10 text:"/" fill:red)}
   {Canvas create(text 475 10 text:NObjetNeeded fill:red)}
   L2={Game Xbrave Ybrave Command MapList}
   if L2==1 then
   {Canvas create(rect 0 0 TailleCase*LargeurMax TailleCase*HauteurMax fill:black outline:black)}
   {Canvas create(text ((TailleCase*LargeurMax) div 2) ((TailleCase*HauteurMax) div 2) text:"GAME OVER" fill:red)}
   {Canvas create(text ((TailleCase*LargeurMax) div 2) ((TailleCase*HauteurMax) div 2)+15 text:"Press space bar to close the window" fill:red)}
   {Canvas create(text (TailleCase*LargeurMax)-130 (TailleCase*HauteurMax)-20 text:"By Daubry Benjamin & Van Malleghem Antoine" fill:red)}
   {Window bind(event:"<space>" action:toplevel#close)}
   end
   
end
