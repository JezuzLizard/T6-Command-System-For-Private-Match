file_init()
{
	level._fhs = [];
	level._max_file_handles = 10;

	level._search_path = "tcs";
}

open_file( filename, mode )
{
	return fs_fopen( filename, mode );
}

read_file( filename, mode )
{
	f = fs_fopen( filename, mode );

	buffer = "";
	if ( f > 0 )
	{

	}

	return "";
}

private fs_fopen( filename, mode )
{
	_ASSERT_MSG( isdefined( filename ) && filename.size > 0 );
	_ASSERT_MSG( mode == "read" || mode == "write" || mode == "append" );

	f = fs_fopen( filename, mode );
	_ASSERT_MSG( f > 0 );

	return f;
}

private fs_read( f, byte_count )
{
	_ASSERT_MSG( f > 0 );
	_ASSERT_MSG( byte_count > 0 );

	buffer = fs_read( f, byte_count );

	return buffer;
}

private fs_fclose( f )
{
	_ASSERT_MSG( f > 0 );

	fs_fclose( f );
}