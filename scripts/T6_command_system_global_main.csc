#include clientscripts\mp\_utility;

main()
{
	clientscripts\mp\_utility::registersystem( "cl_tcs", ::cl_tcs_handler );
}

cl_tcs_handler( clientnum, state, oldstate )
{
	tokens = strtok( state, " " );

	if ( isdefined( level._tcs_client_handlers[ tokens[ 0 ] ] ) )
	{
		[[ level._tcs_client_handlers[ tokens[ 0 ] ] ]]( clientnum, state, oldstate );
	}
}