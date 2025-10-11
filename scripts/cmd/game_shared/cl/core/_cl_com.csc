#include clientscripts\mp\_utility;

#include scripts\cmd\game_shared\cl\core\_cl_utility;

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
	com_filter_add( "debug", 0 );
	com_filter_add( "notitle", 1 );

	com_channel_add( "con", ::com_print );
	com_channel_add( "iprintbold", ::com_iprintlnbold );
}

private com_filter_is_active( filter )
{
	return is_true( level.com_filters[ filter ] );
}

private com_channel_is_active( channel )
{
	return isDefined( level.com_channels[ channel ] );
}

private com_caps_msg_title( channel, filter, allow_custom_colors )
{
	allow_custom_colors = _DEFAULT( allow_custom_colors, false );
	if ( filter == "notitle" )
	{
		return "";
	}
	if ( issubstr( filter, "error" ) )
	{
		color_code = "^1";
	}
	else if ( issubstr( filter, "warning" ) )
	{
		color_code = "^3";
	}
	else if ( issubstr( filter, "info" ) )
	{
		color_code = "^2";
	}
	else 
	{
		color_code = "";
	}
	return color_code + ":";
}

private com_print( message, players )
{
	printf( message );
	message = undefined;
}

private com_iprintlnbold( message, players )
{
	if ( is_true( level.doing_cmd_system_unittest ) )
	{
		return;
	}
	
	iprintlnbold( message );
}

com_printf_internal( channels, filter, message, players )
{
	if ( !isDefined( channels ) )
	{
		assert( false );
		return;
	}
	if ( !isDefined( filter ) )
	{
		assert( false );
		return;
	}
	if ( !isDefined( message ) || isstring( message ) && message == "" )
	{
		assert( false );
		return;
	}
	channel_keys = strTok( channels, "|" );
	for ( i = 0; i < _SIZE( channel_keys.size ); i++ )
	{
		channel = channel_keys[ i ];
		if ( com_channel_is_active( channel ) && com_filter_is_active( filter ) )
		{
			if ( channel == "g_log" || channel == "notitle" )
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

com_get_cmd_feedback_channel_internal()
{
	if ( is_true( self.is_server ) )
	{
		return "con|g_log";
	}
	else if ( is_true( self.is_host ) )
	{
		return "iprint|con|g_log";
	}
	else
	{
		return "iprint";
	}
}