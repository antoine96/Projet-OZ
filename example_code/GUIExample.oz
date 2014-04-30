declare 
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}

local
   Canvas
   WidthCell=40
   HeightCell=40
   NW=20
   NH=20
   W =WidthCell*NW
   H =HeightCell*NH
   PLAYER_MAXSTEP = 2
   Command
   CommandPort = {NewPort Command}
   CD = {OS.getCWD}
   {Show CD}
   Desc=td(canvas(bg:green
                  width:W
                  height:H
                  handle:Canvas))
   Window={QTk.build Desc}
   {Window bind(event:"<Up>" action:proc{$} {Send CommandPort r(0 ~1)} end)}
   {Window bind(event:"<Left>" action:proc{$} {Send CommandPort r(~1 0)} end)}
   {Window bind(event:"<Down>" action:proc{$} {Send CommandPort r(0 1)}  end)}
   {Window bind(event:"<Right>" action:proc{$} {Send CommandPort r(1 0)} end)}
   {Window bind(event:"<space>" action:proc{$} {Send CommandPort finish} end)}
   proc{DrawBox Color X Y}
	 {Canvas create(rect X*WidthCell Y*HeightCell X*WidthCell+WidthCell Y*HeightCell+HeightCell fill:Color outline:black)}
   end
   proc{InitLayout ListToDraw}
      proc{DrawHline X1 Y1 X2 Y2}
	 if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawHline X1+HeightCell Y1 X2+HeightCell Y2}
	 end
      end
      proc{DrawVline X1 Y1 X2 Y2}
	 if X1>W orelse X1<0 orelse Y1>H orelse Y1<0 then
	    skip
	 else
	    {Canvas create(line X1 Y1 X2 Y2 fill:black)}
	    {DrawVline X1 Y1+WidthCell X2 Y2+WidthCell}
	 end
      end
      proc{DrawUnits L}
	 case L of r(Color X Y)|T then
	    {DrawBox Color X Y}
	    {DrawUnits T}
	 else
	    skip
	 end
      end
   in
      {DrawHline 0 0 0 W}
      {DrawVline 0 0 W 0}
      {DrawUnits ListToDraw}
   end
   proc{Game OldX OldY Command}
      NewX NewY
      NextCommand
      fun{UserCommand Command Count X Y LX LY}
	 IX IY in
	 case Command of r(DX DY)|T then
	    if Count == PLAYER_MAXSTEP then
	       {UserCommand T Count X Y  LX LY}
	    else
	       IX = X+DX
	       IY = Y+DY
	       {DrawBox green X Y}
	       {DrawBox white IX IY}
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
   %Initialize zombies and user
   {InitLayout [r(yellow 1 12) r(blue 10 3) r(black 11 10) r(white 8 8)]}
   {Game 8 8 Command}
end

