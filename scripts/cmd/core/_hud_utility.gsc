#include common_scripts\utility;
#include maps\mp\_utility;

#include scripts\cmd\core\_utility;

HAS_CHILD_HUDS()
{
	return array_validate( self.members );
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
			if ( !is_true( self.is_root ) )
			{
				self.alpha = val;
			}
			else
			{
				self.parent_alpha = val;
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

	for ( i = 0; i < self.members.size; i++ )
	{
		child = self.members[ i ];

		child set_hud_field( max_depth, field_name, val );
	}
}

create_text_hud_baseline()
{
	level._text_limit = 40;
	level._text_count = 0;
	level._text_huds = [];
	hud = newhudelem();
	hud.is_text_baseline = true;
	return hud;
}

set_safe_text( text )
{
	if ( level._text_count >= level._text_limit )
	{
		// clear all strings
		level._baseline_text_hud clearalltextafterhudelem();
		for ( i = 0; i < level._text_huds.size; i++ )
		{
			text_hud = level._text_huds[ i ];
			text_hud settext( "" );
		}

		level._text_count = 0;

		// restore previous text for active huds
		for ( i = 0; i < level._text_huds.size; i++ )
		{
			text_hud = level._text_huds[ i ];
			text_hud settext( level._text_huds[ i ].save_text );
			level._text_count++;
		}

		level.server com_printinfo( "Had to clear the text cache..." );
	}

	if ( isdefined( self.save_text ) && self.save_text == text )
	{
		return;
	}

	level._text_count++;

	self.save_text = text;
	self settext( text );
}

set_safe_label( text )
{

}

call_hud_method( max_depth, call_name, arg1 = undefined, arg2 = undefined, arg3 = undefined, arg4 = undefined, arg5 = undefined )
{
	max_depth = _DEFAULT( max_depth, 0 );

	switch ( call_name )
	{
		case "fadeovertime":
			time = arg1;
			self fadeovertime( time );
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

	for ( i = 0; i < self.members.size; i++ )
	{
		child = self.members[ i ];

		child call_hud_method( max_depth, call_name, arg1, arg2, arg3, arg4, arg5 );
	}
}

create_root_hud()
{
	root = newclienthudelem( self );
	root.alpha = 0.0;
	root.parent_alpha = 1.0;
	root.is_root = true;
	return root;
}

/*hud_binding_t*/ hud_binding_new( binding_name, binding_type, binding_subtype, binding_default_val )
{
	hud_binding_obj = spawnstruct();
	hud_binding_obj.binding_name = binding_name;
	hud_binding_obj.binding_type = binding_type;
	hud_binding_obj.binding_subtype = binding_subtype;
	hud_binding_obj.binding_val = binding_default_val;
	hud_binding_obj.binding_default_val = binding_default_val;
	hud_binding_obj.binding_subscribed_entity = undefined;
	hud_binding_obj.binding_subscriber_hud = undefined;

	return hud_binding_obj;
}

hud_binding_register( binding_name, binding_type, binding_subtype, binding_default_val )
{
	if ( !isdefined( self._hud_bindings ) )
	{
		self._hud_bindings = [];
	}

	if ( !isdefined( self._hud_bindings[ binding_name ] ) )
	{
		self._hud_bindings[ binding_name ] = hud_binding_new( binding_name, binding_type, binding_subtype, binding_default_val );
	}
}

hud_binding_unregister( binding_name )
{
	hud_binding_obj = self hud_binding_get( binding_name );
}

hud_binding_add_subscriber_hud( subscriber_hud )
{
	self.binding_subscriber_hud = subscriber_hud;
	hud_binding_set_default( self, subscriber_hud );
}

hud_binding_set( binding_name, hud, new_value )
{
	hud_binding_obj = self hud_binding_get( binding_name );

	if ( !isdefined( hud_binding_obj ) )
	{
		return undefined;
	}

	if ( hud_binding_obj.binding_type == "text" )
	{
		if ( hud_binding_obj.binding_val != new_value )
		{
			switch ( hud_binding_obj.binding_subtype )
			{
				case "edit_mode":
					hud set_safe_text( "Context edit mode: " + new_value );
					break;
				case "edit_scale":
					hud set_safe_text( "Context scale: " + new_value );
					break;
				default:
					break;
			}

			hud_binding_obj.binding_val = new_value;
		}
	}
	else
	{
		assert( false );
	}

	return hud_binding_obj;
}

hud_binding_set_default( hud_binding_obj, hud )
{
	switch ( hud_binding_obj.binding_subtype )
	{
		case "edit_mode":
		case "edit_scale":
		case "selected_entity":
		case "held_entity":
		case "placed_entities":
			hud_binding_obj.binding_val = hud_binding_obj.binding_default_val;
			hud set_safe_text( hud_binding_obj.binding_default_val );
			break;
		default:
			break;
	}
}

/*gentity_t*/ hud_binding_subscribe_to_entity( binding_name, entity )
{
	self endon( "disconnect" );
	hud_binding_obj = self hud_binding_get( binding_name );
	if ( !isdefined( hud_binding_obj ) || !isdefined( entity ) )
	{
		assert( isdefined( entity ) );
		return undefined;
	}

	hud_binding_obj.binding_subscribed_entity = entity;

	return entity;
}

hud_binding_get_subscribed_entity( binding_name )
{
	hud_binding_obj = self hud_binding_get( binding_name );
	if ( !isdefined( hud_binding_obj ) )
	{
		return undefined;
	}

	return hud_binding_obj.binding_subscribed_entity;
}

hud_bindings_get()
{
	return self._hud_bindings;
}

hud_binding_update( hud_binding_obj, hud )
{
	entity = hud_binding_obj.binding_subscribed_entity;

	if ( hud_binding_obj.binding_type == "entity" )
	{
		switch ( hud_binding_obj.binding_subtype )
		{
			case "held_entity":
				hud_binding_obj.binding_val = "HOLDING: " + "Classname: " + entity.classname + " Org: " + entity.origin + " Ang: " + entity.angles;
				hud set_safe_text( hud_binding_obj.binding_val );
				break;
			case "selected_entity":
				hud_binding_obj.binding_val = "SELECTED: " + "Classname: " + entity.classname + " Org: " + entity.origin + " Ang: " + entity.angles;
				hud set_safe_text( hud_binding_obj.binding_val );
				break;
			case "placed_entities":
				hud_binding_obj.binding_val = "Placed ent count: " + hud_binding_obj.binding_subscribed_entity.size;
				hud set_safe_text( hud_binding_obj.binding_val );
				break;
			default:
				assert( false );
				break;
		}
	}
	else
	{
		assert( false );
	}
}

hud_bindings_update_loop()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		keys = getarraykeys( self._hud_bindings );
		for ( i = 0; i < keys.size; i++ )
		{
			hud_binding_obj = self._hud_bindings[ keys[ i ] ];
			entity = hud_binding_obj.binding_subscribed_entity;
			hud = hud_binding_obj.binding_subscriber_hud;
			if ( isdefined( hud ) )
			{
				if ( isdefined( entity ) )
				{
					self hud_binding_update( hud_binding_obj, hud );
				}
				else
				{
					self hud_binding_set_default( hud_binding_obj, hud );
				}
			}
		}

		wait 0.05;
	}
}

hud_binding_unsubscribe_from_entity( binding_name )
{
	hud_binding_obj = self hud_binding_get( binding_name );
	if ( !isdefined( hud_binding_obj ) )
	{
		return;
	}

	hud_binding_obj.binding_subscribed_entity = undefined;
}

hud_binding_get( binding_name )
{
	return self._hud_bindings[ binding_name ];
}

vertical_text_list_update_member( parent, member, member_index )
{
	member set_alignment( 0, parent.alignx, parent.aligny, parent.horzalign, parent.vertalign );
	member set_alpha( 0, parent.parent_alpha );
	member set_position( 0, parent.x, ( parent.y + ( parent.vertical_spacing * member_index ) ) );
	member set_hide_in_menu_flag( 0, parent.hidewheninmenu );

	member.font = parent.font;
	member.fontscale = parent.fontscale;
}

vertical_text_list_add_member( parent, new_member )
{
	vertical_text_list_update_member( parent, new_member, parent.members.size );

	parent.members = add_to_array( parent.members, new_member, false );
}

vertical_text_list_update_members( parent )
{
	for ( i = 0; i < parent.members.size; i++ )
	{
		member = parent.members[ i ];
		vertical_text_list_update_member( parent, member, i );
	}
}

vertical_text_list_create( vertical_spacing, alpha, font, fontscale, alignx, aligny, horzalign, vertalign )
{
	root = create_root_hud();
	root.elem_type = "vertical_list";
	root.members = [];
	root.add_member_func = ::vertical_text_list_add_member;
	root.vertical_spacing = _DEFAULT( vertical_spacing, 10 );
	root.parent_alpha = alpha;

	root.font = font;
	root.fontscale = fontscale;
	root set_alignment( 0, alignx, aligny, horzalign, vertalign );
	return root;
}

new_client_hud_wrapper( client )
{
	hudelem = newclienthudelem( client );
	level._text_huds[ level._text_huds.size ] = hudelem;
	return hudelem;
}

vertical_text_list_add( parent, binding_name )
{
	hudelem = new_client_hud_wrapper( self );
	hudelem.elem_type = "font";

	if ( isdefined( self._hud_bindings[ binding_name ] ) )
	{
		self._hud_bindings[ binding_name ] hud_binding_add_subscriber_hud( hudelem );
	}
	
	level [[ parent.add_member_func ]]( parent, hudelem );
	return hudelem;
}