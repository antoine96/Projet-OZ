declare
QTK
Z
CD = {OS.getCWD}
{Browse CD}
[QTk] = {Module.link ["x-oz://system/wp/QTk.ozf"]}
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
local
   Desc=td(label(text:"Up Left"
                 glue:nw)
           label(text:"Down right"
		 glue:se))
   %Z={LoadPickle 'map_test.ozp'}
   Z={LoadPickle 'x-oz://system/wp/map_test.ozp'}
in
   %{{QTk.build Desc} show}
   {Browse Z}
end
