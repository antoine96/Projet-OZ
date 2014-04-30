declare 
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
Z={LoadPickle 'C:\Users\Antoine\Documents\GitHub\Projet-OZ\example_code\lol.ozp'}
{Show Z}