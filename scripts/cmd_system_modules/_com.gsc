#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_cmd_util;

com_init()
{
	com_filter_add( "cominfo", 1 );
	com_filter_add( "comwarning", 1 );
	com_filter_add( "comerror", 1 );
	com_filter_add( "cmdinfo", 1 );
	com_filter_add( "cmdwarning", 1 );
	com_filter_add( "cmderror", 1 );
	com_filter_add( "scrinfo", 1 );
	com_filter_add( "scrwarning", 1 );
	com_filter_add( "screrror", 1 );
	com_filter_add( "permsinfo", 1 );
	com_filter_add( "permswarning", 1 );
	com_filter_add( "permserror", 1 ); 
	com_filter_add( "debug", 0 );
	com_filter_add( "notitle", 1 );

	com_channel_add( "con", ::com_print );
	com_channel_add( "g_log", ::com_logprint );
	com_channel_add( "iprint", ::com_iprintln );
	com_channel_add( "iprintbold", ::com_iprintlnbold );

	com_channel_add( "iprint_array", ::com_iprintln_array );
}

com_filter_add( filter, default_value )
{
	if ( !isDefined( level.com_filters ) )
	{
		level.com_filters = [];
	}
	if ( !isDefined( level.com_filters[ filter ] ) )
	{
		level.com_filters[ filter ] = getDvarIntDefault( "com_script_filter_" + filter, default_value );
	}
}

com_channel_add( channel, func )
{
	if ( !isDefined( level.com_channels ) )
	{
		level.com_channels = [];
	}
	if ( !isDefined( level.com_channels[ channel ] ) )
	{
		level.com_channels[ channel ] = func;
	}
}

com_filter_is_active( filter )
{
	return is_true( level.com_filters[ filter ] );
}

com_channel_is_active( channel )
{
	return isDefined( level.com_channels[ channel ] );
}

com_caps_msg_title( channel, filter )
{
	if ( filter == "notitle" || channel == "con" )
	{
		return "";
	}
	if ( channel == "g_log" )
	{
		return toUpper( filter ) + ":";
	}
	if ( isSubStr( filter, "error" ) )
	{
		color_code = "^1";
	}
	else if ( isSubStr( filter, "warning" ) )
	{
		color_code = "^3";
	}
	else if ( isSubStr( filter, "info" ) )
	{
		color_code = "^2";
	}
	else 
	{
		color_code = "";
	}
	return color_code + toUpper( filter ) + ":";
}

com_print( message, players )
{
	printf( message );
	message = undefined;
}

com_logprint( message, players )
{
	players = undefined;
	logPrint( message + "\n" );
	message = undefined;
}

com_iprintln( message, player )
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return;
	}
	if ( isDefined( player ) && !is_true( player.is_server ) )
	{
		player iPrintLn( message );
	}	
}

com_iprintln_array( message, players )
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return;
	}
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] iPrintLn( message );
	}
}

com_iprintlnbold( message, players )
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return;
	}
	for ( i = 0; i < level.players.size; i++ )
	{
		level.players[ i ] iPrintLnBold( message );
	}
}

com_printf( channels, filter, message, players )
{
	if ( !isDefined( channels ) )
	{
		return;
	}
	if ( !isDefined( filter ) )
	{
		return;
	}
	if ( !isDefined( message ) || message == "" )
	{
		return;
	}
	channel_keys = strTok( channels, "|" );
	for ( i = 0; i < channel_keys.size; i++ )
	{
		channel = channel_keys[ i ];
		if ( com_is_channel_active( channel ) && com_is_filter_active( filter ) )
		{
			if ( channel == "g_log" )
			{
				message_color_code = "";
			}
			else 
			{
				message_color_code = "^8";
			}
			message_modified = com_caps_msg_title( channel, filter ) + message_color_code + message;
			if ( array_validate( players ) )
			{
				channel = channel + "_array";
			}
			[[ level.com_channels[ channel ] ]]( message_modified, players );
		}
	}
}

com_get_cmd_feedback_channel()
{
	if ( is_true( self.is_server ) )
	{
		return "con";
	}
	else if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return "g_log";
	}
	else 
	{
		return "iprint";
	}
}