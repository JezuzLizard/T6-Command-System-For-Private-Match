#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

#include scripts\cmd\core\_api_hud;
#include scripts\cmd\core\_utility_hud;

init_unittest_helpers()
{
	addcallback( "on_player_connect", ::unittest_connect );
}

do_unit_test( required_bots, duration, rate )
{
	if ( duration > 0 )
	{
		level thread end_unittest_after_time( duration );
	}

	level.unittest_total_cmds_used = 0;
	set_cmd_rate( rate );
	level thread manage_unittest_bots( required_bots );
	level waittill( "unittest_stop" );

	for ( i = 0; i < _SIZE( level.players.size ); i++ )
	{
		if ( is_true( level.players[ i ].pers["isBot"] ) )
		{
			kick( level.players[ i ] getEntityNumber() );
		}
	}
	level.doing_cmd_system_unittest = false;

	set_cmd_rate( undefined );
}

do_module_test( module, sequential, duration, rate )
{
	if ( duration > 0 )
	{
		level thread end_unittest_after_time( duration );
	}

	level.unittest_total_cmds_used = 0;
	set_cmd_module( module );
	set_cmd_sequential( sequential );
	set_cmd_duration( duration );
	set_cmd_rate( rate );
	level thread manage_unittest_bots( 1 );
	level waittill( "unittest_stop" );

	for ( i = 0; i < _SIZE( level.players.size ); i++ )
	{
		if ( is_true( level.players[ i ].pers["isBot"] ) )
		{
			kick( level.players[ i ] getEntityNumber() );
		}
	}
	level.doing_cmd_system_unittest = false;
	set_cmd_module( undefined );
	set_cmd_sequential( undefined );
	set_cmd_duration( undefined );
	set_cmd_rate( undefined );
}

private unittest_connect()
{
	if ( self istestclient() )
	{
		if ( is_true( level.doing_cmd_system_testcmd ) )
		{

		}
		else if ( is_true( level.doing_cmd_system_unittest ) )
		{
			if ( isdefined( self.module_cmd ) )
			{
				self thread activate_cmds_from_module();
			}
			else
			{
				self thread activate_random_cmds();
			}
		}
	}
}

private set_cmd_module( module )
{
	level.unittest_cmd_module = module;
}

private set_cmd_sequential( sequential )
{
	level.unittest_cmd_sequential = sequential;
}

private set_cmd_duration( duration )
{
	level.unittest_cmd_duration = duration;
}

private set_cmd_rate( rate )
{
	level.unittest_cmd_rate = rate;
}

private manage_unittest_bots( required_bots, module )
{
	bot_count = 0;
	for ( i = 0; i < _SIZE( level.players.size ); i++ )
	{
		if ( is_true( level.players[ i ].pers["isBot"] ) )
		{
			bot_count++;
		}
	}
	if ( bot_count < required_bots )
	{
		bot = undefined;
		//Need to do this in T6 because the bots can fail to be added for no reason sometimes
		while ( !isdefined( bot ) && ( getNumConnectedPlayers() < getDvarInt( "sv_maxclients" ) ) )
		{
			bot = addtestclient();
		}
		if ( !isDefined( bot ) )
		{
			return;
		}
		bot.pers[ "isBot" ] = true;
		
		reset_rampage_func = getfunction( "maps/mp/zombies/_zm", "reset_rampage_bookmark_kill_times" );
		if ( isdefined( reset_rampage_func ) )
		{
			bot [[ reset_rampage_func ]]();
		}
		if ( isDefined( module ) )
		{
			bot.module_cmd = module;
		}
	}
}

private activate_cmds_from_module()
{
	self endon( "disconnect" );
	self.health = 2100000000;

	if ( !isdefined( level._unittest_host ) )
	{
		level._unittest_host = _GET_SERVER_ENTITY();
		level._unittest_host.default_executors = [];
	}

	if ( level._unittest_host.is_server )
	{
		level._unittest_host.default_executors[ level._unittest_host.default_executors.size ] = self;
	}
	
	if ( sessionModeIsZombiesGame() )
	{	
		flag_clear( "solo_game" );
	}
	while ( !isDefined( self._connected ) )
	{
		wait 1;
	}

	while ( true )
	{
		while ( !is_true( level.doing_cmd_system_unittest ) )
		{
			level.doing_cmd_system_unittest = get_dvar_int_default( "tcs_resume_test", 0 );
			wait 1;
		}
		self construct_chat_message_for_unittest();
		wait level.unittest_cmd_rate;
	}
}

private activate_random_cmds()
{
	self endon( "disconnect" );
	self.health = 2100000000;

	if ( !isdefined( level._unittest_host ) )
	{
		level._unittest_host = _GET_SERVER_ENTITY();
		level._unittest_host.default_executors = [];
	}

	level._unittest_host.default_executors[ level._unittest_host.default_executors.size ] = self;
	if ( sessionModeIsZombiesGame() )
	{	
		flag_clear( "solo_game" );
	}
	while ( !isDefined( self._connected ) )
	{
		wait 1;
	}

	while ( true )
	{
		self construct_chat_message_for_unittest();
		wait level.unittest_cmd_rate;
	}
}

private create_random_valid_targets( cmd )
{
	target_gen_obj = generic_obj_t_new( "target_gen" );
	targets = "";
	target_gen_obj.value = targets;
	types = cmd.target_types;

	if ( types.size <= 0 )
	{
		return target_gen_obj;
	}

	count = 0;
	foreach ( ordinal, val in types )
	{
		if ( !val.is_required && cointoss() )
		{
			continue;
		}

		random_overload = random_val( val.overloads );
		if ( !isdefined( level._entity_type_funcs[ random_overload.etype ] ) )
		{
			_ASSERT_MSG_ONLY( "Unknown entity type: '{}' registered for command: '{}'", random_overload.etype, cmd.cmd_name );
			target_gen_obj.errored = true;
			return target_gen_obj;
		}

		if ( targets == "" )
		{
			targets += "@{";
		}

		if ( cointoss() )
		{
			targets += "target";
		}
		else
		{
			targets += "t";
		}

		targets += ordinal;
		targets += "=";

		target_str = self [[ level._target_obj_generate ]]( val, random_overload );
		if ( target_str == "" )
		{
			_ASSERT_MSG_ONLY( "Could not generate entities of etype: '{}' max_targets: '{}'", random_overload.etype, random_overload.max_targets );
			target_gen_obj.errored = true;
			return target_gen_obj;
		}
		targets += target_str;
		count++;

		targets += ",";
	}

	if ( targets != "" && targets[ targets.size - 1 ] == "," )
	{
		targets = getsubstr( targets, 0, ( targets.size - 1 ) );
	}

	if ( targets != "" )
	{
		targets += "}";
	}

	target_gen_obj.value = targets;

	return target_gen_obj;
}

private construct_chat_message_for_unittest()
{
	cmd_find_result = undefined;
	if ( isdefined( level.unittest_cmd_module ) )
	{
		index = undefined;
		if ( is_true( level.unittest_cmd_sequential ) )
		{
			if ( !isdefined( level._unittest_module_counter ) )
			{
				level._unittest_module_counter = 0;
			}
			index = ( level._unittest_module_counter % level._cmd_modules[ level.unittest_cmd_module ].size );
			level._unittest_module_counter++;
		}

		cmd_find_result = level [[ level.tcs_arg_type_handlers[ "cmdalias" ].rand_gen_func ]]( level.unittest_cmd_module, index );
	}
	else
	{
		cmd_find_result = level [[ level.tcs_arg_type_handlers[ "cmdalias" ].rand_gen_func ]]();
	}
	
	if ( cmd_find_result.errored )
	{
		_ASSERT_MSG_ONLY( cmd_find_result.msg );
		return;
	}

	cmd_object = cmd_find_result.value;
	if ( is_true( cmd_object.immune_to_unittest ) )
	{
		return;
	}
	arg_gen_obj = self create_random_valid_args2( cmd_object );
	if ( arg_gen_obj.errored )
	{
		return;
	}

	target_gen_obj = self create_random_valid_targets( cmd_object );
	if ( target_gen_obj.errored )
	{
		return;
	}

	message = format( "{}", cmd_object.cmd_name );
	if ( target_gen_obj.value != "" )
	{
		message = format( "{} {}", message, target_gen_obj.value );
	}
	else if ( cmd_object.has_required_target )
	{
		return; // something went wrong
	}

	if ( arg_gen_obj.value.size > 0 )
	{
		message += " " + repackage_args( arg_gen_obj.value );
	}

	if ( message[ message.size - 1 ] == " " )
	{
		message = getsubstr( message, 0, message.size - 1 );
	}

	cmd_log = format( "'{}' executed '{}' count: '{}'", self.name, message, level.unittest_total_cmds_used );
	com_printdebuginfo( cmd_log );
	level notify( "say", message, level._unittest_host, true, false );
	level.unittest_total_cmds_used++;
}

private create_random_valid_args2( cmd_object )
{
	arg_gen_obj = generic_obj_t_new( "arg_gen" );
	arg_gen_obj.value = [];
	types = cmd_object.arg_types;

	if ( !isDefined( types ) )
	{
		return arg_gen_obj;
	}

	i = 0;
	foreach ( ordinal, type in types )
	{
		if ( !type.is_required )
		{
			if ( cointoss() )
			{
				break;
			}
		}

		// TODO: write logic to handle generating variadic command args
		if ( isdefined( type.overloads[ "..." ] ) )
		{
			break;
		}

		random_overloaded_type = random_key( type.overloads );
		arg = self generate_args_from_type( random_overloaded_type );
		if ( arg.errored || is_true( arg.rand_gen_unimplemented ) )
		{
			arg_gen_obj.errored = true;
			return arg_gen_obj;
		}

		arg_gen_obj.value[ i ] = arg.str_value;
		i++;
	}

	return arg_gen_obj;
}

private generate_args_from_type( type )
{
	rand_obj = generic_obj_t_new();
	if ( isDefined( level.tcs_arg_type_handlers[ type ] ) && isdefined( level.tcs_arg_type_handlers[ type ].rand_gen_func ) )
	{
		com_printdebugwarning( "generate_args_from_type: '" + type + "'" );
		rand_obj = self [[ level.tcs_arg_type_handlers[ type ].rand_gen_func ]]();
		if ( rand_obj.errored )
		{
			_ASSERT_MSG_ONLY( "generate_args_from_type: Error that should never happen has happened: '{}' msg: '{}'", type, rand_obj.msg );
			return rand_obj;
		}
		else if ( is_true( rand_obj.rand_gen_unimplemented ) )
		{
			_ASSERT_MSG_ONLY( "generate_args_from_type: Tried to generate args for type: '{}' but generation was unimplemented", type );
			return rand_obj;
		}

		return rand_obj;
	}

	rand_obj.errored = true;
	_ASSERT_MSG_ONLY( "Tried to generate args for '{}' but no rand_gen_func handler exists for it", type );
	return rand_obj;
}

private end_unittest_after_time( time_required_in_seconds )
{
	level endon( "unittest_stop" );

	time_passed_in_seconds = 0;
	while ( time_passed_in_seconds < time_required_in_seconds )
	{
		wait 1;
		time_passed_in_seconds++;
	}

	level notify( "unittest_stop" );
}