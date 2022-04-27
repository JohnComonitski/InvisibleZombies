#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai_shared;

#insert scripts\shared\shared.gsh;

#namespace clientids;

REGISTER_SYSTEM( "clientids", &__init__, undefined )
	
function __init__()
{
	callback::on_start_gametype( &init );
	callback::on_connect( &on_player_connect );
	callback::on_spawned( &on_player_spawned ); 
}	

function init()
{
	level.clientid = 0;
}

function on_player_connect()
{
	self.clientid = matchRecordNewPlayer( self );
	if ( !isdefined( self.clientid ) || self.clientid == -1 )
	{
		self.clientid = level.clientid;
		level.clientid++;
	}

}

function on_player_spawned() //this function will get called on every spawn! 
{
	level flag::wait_till( "initial_blackscreen_passed" );

	//Does something, when you hold F for five seconds
    foreach (player in GetPlayers()){
        thread eventListener(player);
    }
    
}

function eventListener(player){
    count = 0;
    loop = true;
    while(loop){
        if(player UseButtonPressed()){
            count++;
        }
        else{
            count = 0;
        }
        wait(1);
        if(count == 5){
            gameLoop(player);
            loop = false;
        }
        if(level.round_number > 1){
            gameLoop(player);
            loop = false;
        }

    }
}

function gameLoop(player){
    wait(1);
    player IPrintLnBold("Let the game begin!");
    wait(1);

    while(1){
        wait(60);

        //Make Zombies Invisible
        players = GetPlayers();

        //Make Zombies Invisible with effect
        player IPrintLnBold("Making Zombie Invisible... Good Luck!");
  
        foreach (player in players){
            foreach (ai in GetAIArray()){
                thread makeZombieInvisibleWithEffect(ai, player);
            }
                            
        }

        wait(5);
        //make sure zombies stay invisible
        for (i =0; i<19; i++)
        {
            foreach (player in players){
                foreach (ai in GetAIArray()){
                    thread makeZombieInvisible(ai, player);
                }
            }                
            wait(5);
        }

        //Bring Zombies Back
        foreach (ai in GetAIArray()){
            thread makeZombiesVisible(ai);
        }
        player IPrintLnBold("Zombies are back!");
        player IPrintLnBold("You have 1 minute...");
        
    }
}

function makeZombieInvisible(ai, player){
    ai SetInvisibleToPlayer(player, true);
}

function makeZombieInvisibleWithEffect(ai, player){
    playsoundatposition(  level.zmb_laugh_alias, ai.origin );
    Playfx( level._effect["lightning_dog_spawn"], ai.origin );
    playsoundatposition( "zmb_hellhound_prespawn", ai.origin );
    wait( 1.5 );
    playsoundatposition( "zmb_hellhound_bolt", ai.origin );
    ai SetInvisibleToPlayer(player, true);
    
}


function makeZombiesVisible(ai){
    Playfx( level._effect["lightning_dog_spawn"], ai.origin );
    playsoundatposition( "zmb_hellhound_prespawn", ai.origin );
    wait( 1.5 );
    playsoundatposition( "zmb_hellhound_bolt", ai.origin );
    ai SetVisibleToAll();
}

function makeZombiesVisibleWithoutEffect(ai){
    ai SetVisibleToAll();
}