Zombieland Simulator 
Copyright (C)  Daubry Benjamin / Van Malleghem Antoine

Launch Zombieland Simulator
---------------------------

Launch a Shell and in the directory of Zombieland, type	- ozc -c MainFunctor.oz 
							- ozengine MainFunctor.ozf --map FILE --zombie INT --item INT --bullet INT
--map FILE= File Containing the map in .ozp (the path or the name of the file if you are in the directory) 
  (default value : map_defaut.ozp)
--zombie INT= Number of zombies
  (default value : 5)
--item INT= Total number of items to pick
  (default value : 5)
--bullet INT= Initial number of bullets
  (default value : 3)

For help :

ozengine MainFunctor.ozf --help
--help= This help

Using/Playing Zombieland Simulator
--------------

This game is turn-based.
At the beginning, you're the brave and you can move 2 times per turn (you use directional arrows to move).
Take an object cost one move behalve if it's a bullet (who gives you an additional bullet).
You'll kill a zombie if you have a bullet and if you arrive on a square with a zombie.

Then, it's the turn of zombies. They move faster than you (3 moves per turn).
They can destroy objects but it costs one move and they're out of luck to do that. If they don't arrive, they'll change their direction.
On one hand, if the zombie arrive behind you, he kills you. On the other hand, if you've a bullet and if he doesn't arrive behind you, you kill him.


Reporting Problems
------------------

If you encounter problems, please send a bug report to:

	benjamin.daubry@student.uclouvain.be
	Or
	antoine.vanmalleghem@student.uclouvain.be

