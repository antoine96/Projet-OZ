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
										 QTk at 'x-oz://system/wp/QTk.ozf'
										 System
										 Application
									      define
										 Show = System.show
										 Desc = td(button(text:"Show"
												  action:proc {$}
													    {Show 'Hello World'}
													 end)
											   button(text:"Close"
												  action:proc {$}
													    {Application.exit 0}
													 end))
									      in
										 {{QTk.build Desc} show}
									      end