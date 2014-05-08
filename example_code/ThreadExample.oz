declare
fun {Ping S1}
   case S1 of _|T1 then
      {Delay 200}
      {Browse ping}
      ok|{Ping T1}
   end
end
fun {Pong S2}
   case S2 of _|T2 then
      {Browse pong}
      ok|{Pong T2}
   end
end

% This one will run...why?
declare S1 S2 in
thread S2={Ping S1} end
thread S1={Pong ok|S2} end