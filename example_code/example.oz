declare
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

{Browse {ChooseRand 10 {List 20} 20}}