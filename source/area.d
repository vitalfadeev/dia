module area;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import bindbc.sdl;
import bindbc.sdl.ttf;
import sdlexception;
import op;
import e;
import block;


struct Area
{
    mixin EOBJECT;
}


//size_t er( ref E This, size_t op, ref size_t arg, ref size_t arg2 )
//{
//    //if ( op == OP_SEE )           return see( This, op, arg, arg2 );
//    //if ( op == OP_RECT_SEE )      return rect_see( This, op, arg, arg2 );
//    //if ( op == OP_HIT_TEST )      return hit_test( This, op, arg, arg2 );
//    //if ( op == OP_RECT_HIT_TEST ) return hit_test( This, op, arg, arg2 );
//    //if ( op == OP_MOUSE_MOVE )    return mouse_move( This, op, arg, arg2 );
//    //if ( op == OP_MOUSE_KEY )     return mouse_key( This, op, arg, arg2 );
//    //if ( op == OP_ADD_CHILD )     return add_child( This, op, arg, arg2 );
//    //if ( op == OP_DEL_CHILD )     return del_child( This, op, arg, arg2 );

//    return This.er( op, arg, arg2 );
//}


//size_t see( ref E This, size_t op, ref size_t arg, ref size_t arg2 )
//{
//    //SDL_Renderer* renderer = cast( SDL_Renderer* )arg;
//    //This.b1.see( arg, arg2 );
//    This.b1.er( OP_SEE, arg, arg2 );
//}

//size_t rect_see( ref E This, size_t op, ref size_t arg, ref size_t arg2 )
//{
//    SDL_Renderer* renderer = cast( SDL_Renderer* )arg;
//    SDL_Rect*     rect     = cast( SDL_Rect* )arg2;

//    // Clear bg
//    SDL_SetRenderDrawColor( renderer, 0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE );
//    SDL_SetRenderDrawBlendMode( renderer, SDL_BLENDMODE_NONE );
//    SDL_RenderFillRect( renderer, &rect );

//    // Inner
//    if ( This.b1.hit_test( rect ) )
//        This.b1.see( This, op, arg, arg2 );
//}

//void event( ref SDL_Event event )
//{
//    b1.event( event );
//    //t1.event( event );
//}

//SDL_Rect get_rect()
//{
//    return SDL_Rect();
//}

