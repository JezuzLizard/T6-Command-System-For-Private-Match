#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cmd_system_modules\_com;

HAS_CHILD_HUDS()
{
	return isdefined( self.child_huds ) && self.child_huds.size > 0;
}

set_alignment( max_depth, alignx, aligny, horzalign, vertalign )
{
	self set_hud_field( max_depth, "alignx", alignx );
	self set_hud_field( max_depth, "aligny", aligny );
	self set_hud_field( max_depth, "horzalign", horzalign );
	self set_hud_field( max_depth, "vertalign", vertalign );
}

set_position( max_depth, x, y )
{
	self set_hud_field( max_depth, "setx", x );
	self set_hud_field( max_depth, "sety", y );
}

set_alpha( max_depth, val )
{
	self set_hud_field( max_depth, "alpha", val );
}

set_hide_in_menu_flag( max_depth, val )
{
	self set_hud_field( max_depth, "hidewheninmenu", val );
}

apply_offset( max_depth, x, y )
{
	self set_hud_field( max_depth, "offsetx", x );
	self set_hud_field( max_depth, "offsety", y );
}

set_hud_field( max_depth, field_name, val )
{
	max_depth = _DEFAULT( max_depth, 0 );

	switch ( field_name )
	{
		case "alignx":
			self.alignx = val;
			break;
		case "aligny":
			self.aligny = val;
			break;
		case "horzalign":
			self.horzalign = val;
			break;
		case "vertalign":
			self.vertalign = val;
			break;
		case "alpha":
			if ( !is_true( self.root ) )
			{
				self.alpha = val;
			}
			break;
		case "hidewheninmenu":
			self.hidewheninmenu = val;
			break;
		case "setx":
			self.x = val;
			break;
		case "sety":
			self.y = val;
			break;
		case "offsetx":
			self.x += val;
			break;
		case "offsety":
			self.y += val;
			break;
		default:
			return;
	}

	if ( !self HAS_CHILD_HUDS() )
	{
		return;
	}

	if ( max_depth <= 0 )
	{
		return;
	}
	max_depth--;

	child_hud_keys = getarraykeys( self.child_huds );

	for ( i = 0; i < child_hud_keys.size; i++ )
	{
		child = self.child_huds[ child_hud_keys[ i ] ];

		child set_hud_field( max_depth, field_name, val );
	}
}

call_hud_method( max_depth, call_name, arg1 = undefined, arg2 = undefined, arg3 = undefined, arg4 = undefined, arg5 = undefined )
{
	max_depth = _DEFAULT( max_depth, 0 );

	switch ( call_name )
	{
		case "fadeovertime":
			time = arg1;
			self fadeOverTime( time );
			break;
		default:
			return;
	}

	if ( !self HAS_CHILD_HUDS() )
	{
		return;
	}

	if ( max_depth <= 0 )
	{
		return;
	}
	max_depth--;

	child_hud_keys = getarraykeys( self.child_huds );

	for ( i = 0; i < child_hud_keys.size; i++ )
	{
		child = self.child_huds[ child_hud_keys[ i ] ];

		child call_hud_method( max_depth, call_name, arg1, arg2, arg3, arg4, arg5 );
	}
}

create_root_hud()
{
	root = self maps\mp\gametypes_zm\_hud_util::createfontstring( "objective", 1.8 );
	root.alpha = 0.0;
	root.root = true;
	return root;
}

/*hud_binding_t*/ hud_binding_new( binding_name, binding_type, binding_default_val )
{
	hud_binding_obj = spawnstruct();
	hud_binding_obj.binding_name = binding_name;
	hud_binding_obj.binding_type = binding_type;
	hud_binding_obj.binding_val = binding_default_val;
	hud_binding_obj.binding_subscriber_huds = [];
}

register_hud_binding( binding_name, binding_type, binding_default_val )
{
	if ( !isdefined( level._hud_bindings ) )
	{
		level._hud_bindings = [];
	}

	if ( !isdefined( level._hud_bindings[ binding_name ] ) )
	{
		level._hud_bindings[ binding_name ] = hud_binding_new( binding_name, binding_type, binding_default_val );
	}

	hud_binding_obj = level._hud_bindings[ binding_name ];
	switch ( binding_type )
	{
		case "text":
			break;
		case "value":
			break;
	}
}

register_hud_binding_for_player( binding_name, subscriber_hud, binding_type, binding_default_val )
{
	if ( !isdefined( self._hud_bindings ) )
	{
		self._hud_bindings = [];
	}

	if ( !isdefined( self._hud_bindings[ binding_name ] ) )
	{
		self._hud_bindings[ binding_name ] = hud_binding_new( binding_name, binding_type, binding_default_val );
	}
}

binding_add_subscriber_hud( subscriber_hud )
{
	self.binding_subscriber_huds = add_to_array( self.binding_subscriber_huds, subscriber_hud, false );
}

update_binding_for_player( binding_name, new_value )
{
	hud_binding_obj = self._hud_bindings[ binding_name ];

	if ( !isdefined( hud_binding_obj ) )
	{
		return;
	}

	for ( i = 0; i < hud_binding_obj.binding_subscriber_huds.size; i++ )
	{
		hud = hud_binding_obj.binding_subscriber_huds[ i ];
		switch ( hud_binding_obj.binding_type )
		{
			case "text":
				hud settext( new_value );
				break;
			case "value":
				hud setvalue( new_value );
				break;
		}
	}
}

set_position( max_depth, x, y )
{
	self set_hud_field( max_depth, "setx", x );
	self set_hud_field( max_depth, "sety", y );
}

set_alpha( max_depth, val )
{
	self set_hud_field( max_depth, "alpha", val );
}

set_hide_in_menu_flag( max_depth, val )
{
	self set_hud_field( max_depth, "hidewheninmenu", val );
}

vertical_text_list_add_member( parent, new_member )
{
	new_member set_alignment( 0, parent.alignx, parent.aligny, parent.horzalign, parent.vertalign );
	new_member set_alpha( 0, parent.alpha );
	new_member set_position( 0, parent.x, ( parent.y + ( parent.vertical_spacing * parent.members.size ) ) );
	new_member set_hide_in_menu_flag( 0, parent.hidewheninmenu );

	new_member.font = parent.font;
	new_member.fontscale = parent.fontscale;

	parent.members = add_to_array( parent.members, new_member, false );
}

vertical_text_list_create( vertical_spacing, font, fontscale )
{
	root = create_root_hud();
	root.elem_type = "vertical_list";
	root.list_root = true;
	root.members = [];
	root.add_member_func = ::vertical_text_list_add_member;
	root.vertical_spacing = _DEFAULT( vertical_spacing, 10 );

	root.alpha = 0.0;
	root.font = font;
	root.fontscale = fontscale;
	return root;
}

vertical_text_list_add( parent, binding_name )
{
	fontelem = newclienthudelem( self );
	fontelem.elem_type = "font";

	if ( isdefined( self._hud_bindings[ binding_name ] ) )
	{
		self._hud_bindings[ binding_name ] binding_add_subscriber_hud( fontelem );
	}
	
	level [[ parent.add_member_func ]]( parent, fontelem );
	return fontelem;
}