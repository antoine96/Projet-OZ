   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Fonction qui nous donne la position relative des zombies (par rapport au nombre de Floor(0) sur la map
functor
export
   zombiesNumber:ZombiesNumber
   remplirListe:RemplirListe
define
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
