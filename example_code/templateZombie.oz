/*-------------------------------------------------------------------------
 *
 * This is a template for the Project of INGI1131: Zombieland 
 * The objective is to porvide you with a starting point for application
 * programming in Mozart-Oz, and with a standard way of recibing arguments for
 * the program.
 *
 * Compile in Mozart 2.0
 *     ozc -c templateZombie.oz  **This will generate templateZombie.ozf
 *     ozengine templateZombie.ozf
 * Examples of execution
 *    ozengine templateZombie --help
 *    ozengine templateZombie --map mymap
 *    ozengine templateZombie -m mymap --z 4 -i 4
 *
 *-------------------------------------------------------------------------
 */

functor
import
   Application
   Property
   System

define
  
   %% Default values
   MAP      = map
   NUMZOMBIES = 5
   ITEMS2PICK    = 5
   INITIALBULLETS    = 3

   %% For feedback
   Say    = System.showInfo

   %% Posible arguments
   Args = {Application.getArgs
              record(
                     map(single char:&m type:atom default:MAP)
                     zombie(single char:&s type:int default:NUMZOMBIES)
                     item(single char:&b type:int default:ITEMS2PICK) 
                     bullet(single char:&n type:int default:INITIALBULLETS) 
                     help(single char:[&? &h] default:false)
                    )}

in
   
   %% Help message
   if Args.help then
      {Say "Usage: "#{Property.get 'application.url'}#" [option]"}
      {Say "Options:"}
      {Say "  -m, --map FILE\tFile containing the map (default "#MAP#")"}
      {Say "  -z, --zombie INT\tNumber of zombies"}
      {Say "  -i, --item INT\tTotal number of items to pick"}
      {Say "  -n, --bullet INT\tInitial number of bullets"}
      {Say "  -h, -?, --help\tThis help"}
      {Application.exit 0}
   end

   {System.show 'These are the arguments to run the application'}
   {Say "Map:\t"#Args.map}
   {Say "Zombie:\t"#Args.zombie}
   {Say "Item:\t"#Args.item}
   {Say "Bullet:\t"#Args.bullet}
   {Application.exit 0}
end
