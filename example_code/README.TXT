Zombieland Simulator 
Copyright (C)  Daubry Benjamin / Van Malleghem Antoine

Launch Zombieland Simulator
---------------------------

Launch a Shell and in the directory of Zombieland, type	- ozc -c MainFunctor.oz 
							- ozengine MainFunctor.ozf --map FILE --zombie INT --item INT --bullet INT
--map FILE= File Containing the map (the path or the name of the file if you are in the directory)
--zombie INT= Number of zombies
--item INT= Total number of items to pick
--bullet INT= Initial number of bullets

For help :

ozengine MainFunctor.ozf --help
--help= This help

Using/Playing Zombieland Simulator
--------------

Ce jeu se joue au tour par tour.
En commencant, vous êtes le Brave et vous avez droit à 2 pas. 
Vous dirigez le Brave avec les flèches directionnelles. 
Ramasser un objet vous coute un pas, donc si vous en ramassez un, vous ne ferez qu'un seul pas. Si ce sont des munitions cela ne vous coute pas de pas et vous gagnez une munition.
%%%A VOIR SI CA COUTE PAS UN PAS OU PAS
Si vous arrivez sur un Zombie avec des munitions, vous le tuez et allez sur sa case. Sinon vous mourrez.

Ensuite, c'est le tour des zombies. Ils vont plus vite que vous et ont donc droit à 3 pas.
Détruire un objet coute aussi un pas de plus; mais le zombie n'a qu'une chance sur cinq de détruire l'objet, si ce n'est pas le cas, il change de direction.
%%Le zombie continue dans sa direction précédente jusqu'a rencontrer un obstacle.
Si le zombie arrive sur vous par le dos, il le tue. Sinon, soit vous n'avez pas de munition et il vous tue tout de même soit vous en avez et vous le tuez.


Reporting Problems
------------------

If you encounter problems, please send a bug report to:

	benjamin.daubry@student.uclouvain.be
	Or
	antoine.vanmalleghem@student.uclouvain.be

