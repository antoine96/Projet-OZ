declare

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
{Browse {Take 1 {List 10}}}
%fun{ChooseRand N L Taille}
 %  if N==0 then nil
  % else
   %   (({Abs {OS.rand}} mod Taille) + 1)|{ChooseRand N-1 L Taille-1}