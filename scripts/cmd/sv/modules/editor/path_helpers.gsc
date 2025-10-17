get_custom_pathnode_by_id( id )
{
	return level._mapents[ "path_nodes" ][ id ];
}

private draw_node_box( origin, color, vec )
{
	vec = _DEFAULT( vec, ( 20, 20, 20 ) );
	box( origin + ( 0, 0, 20 ), vec * -1, vec, 0, color, 1.0 );
}

draw_custom_pathnode( color )
{
	self endon( "deselected" );
	
	for ( ;; )
	{
		color = _DEFAULT( color, ( 1, 1, 1 ) );
		origin = self._selected_pathnode.origin;
		draw_node_box( origin, color );
	}
}