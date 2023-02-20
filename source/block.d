module block;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import bindbc.sdl;
import bindbc.sdl.ttf;
import sdlexception;
import op;
import e;
import controlpoint;
import name;
import k;
import d;
import vcc;


// ----------
//   Block
// ----------
// x
// y
// w
// h
// -
// see    see
// ----------
struct Block
{
    mixin EOBJECT;

    ControlPoint*[9] cps;
    Name* name;
    K*[]  ks;
    D*[]  ds;
    Vcc*  vcc;
}

size_t _hit_test( Block* This, size_t op, size_t arg, size_t arg2 )
{
    // control ponits
    if ( This.is_selected )
        foreach ( ref cp; This.cps )
            if ( cp.er( cp, op, arg, arg2 ) )
                return cast( size_t )cp;

    // name
    if ( This.name.er( This.name, op, arg, arg2 ) )
        return cast( size_t )This.name;


    // in
    foreach ( ref k; This.ks )
        if ( k.er( k, op, arg, arg2 ) )
            return cast( size_t )k;

    // out
    foreach ( ref d; This.ds )
        if ( d.er( d, op, arg, arg2 ) )
            return cast( size_t )d;

    return super_er( This, op, arg, arg2 );
}

size_t _select( Block* This, size_t op, size_t arg, size_t arg2 )
{
    create_controls( This );

    // update is_selected
    // push see
    return super_er( This, op, arg, arg2 );
}

size_t _unselect( Block* This, size_t op, size_t arg, size_t arg2 )
{
    This.del_controls();

    SDL_Rect send_rect;
    send_rect.x = This.rect.x - ControlPoint.cp_size/2;
    send_rect.y = This.rect.y - ControlPoint.cp_size/2;
    send_rect.w = This.rect.w + ControlPoint.cp_size;
    send_rect.h = This.rect.h + ControlPoint.cp_size;
    push_rect_see( send_rect );

    return super_er( This, op, arg, arg2 );
}

size_t _see( Block* This, size_t op, size_t arg, size_t arg2 )
{
    if ( !This.is_selected )
    {
        SDL_Renderer* renderer = cast( SDL_Renderer* )arg;
        SDL_SetRenderDrawColor( renderer, 0xCC, 0xCC, 0xCC, SDL_ALPHA_OPAQUE );
        see_rect( renderer, This.rect );
        see_text( This, renderer );
    }
    else

    {
        SDL_Renderer* renderer = cast( SDL_Renderer* )arg;
        SDL_SetRenderDrawColor( renderer, 0x33, 0x33, 0xFF, SDL_ALPHA_OPAQUE );
        see_rect( renderer, This.rect );
        SDL_Rect big_rect;
        big_rect.x = This.rect.x-1;
        big_rect.y = This.rect.y-1;
        big_rect.w = This.rect.w+2;
        big_rect.h = This.rect.h+2;
        see_rect( renderer, big_rect ); // big

        // Control points
        see_controls( This, op, arg, arg2 );
    }

    // name
    This.name.er( This.name, op, arg, arg2 );

    // in
    foreach ( ref k; This.ks )
        k.er( k, op, arg, arg2 );

    // out
    foreach ( ref d; This.ds )
        d.er( d, op, arg, arg2 );

    // Childs
    {
        foreach ( ref c; This.childs )
            c.er( c, op, arg, arg2 );
    }

    return 0;
}

size_t _cp_moved( Block* This, size_t op, size_t arg, size_t arg2 )
{
    auto cpid = arg;
    switch ( cpid )
    {
        case 1: break;
        case 2: break;
        case 3: This.rect.x = This.cps[3].rect.x; break;
        case 4: break;
        case 5: break;
        case 6: break;
        case 7: break;
        case 8: break;
        case 9: break;
        default:
    }

    return 0;
}

size_t see_controls( Block* This, size_t op, size_t arg, size_t arg2 )
{
    foreach ( ref c; This.cps )
        c.er( c, op, arg, arg2 );

    return 0;
}

void create_controls( Block* block )
{
    foreach ( size_t cid; 0..9 )
        block.cps[cid] = new ControlPoint( block, cid+1 );
}

void del_controls( Block* block )
{
    foreach ( size_t cid; 0..9 )
        block.cps[cid].destroy();
}


// Block
//   in1
//   in2
//
// struct Data
//   string name; // Block
//   In_[] gains;
//
// struct In_
//   string name
//   string type

struct Datas
{
    Data[] ds;
}

struct Data
{
   string name; // Block
   In_[] ins;
   Out_[] outs;
}

struct In_
{
   string name; // x
   string type; // int
}

struct Out_
{
   string name; // x
   string type; // int
}

void create_mouse( ref Data d )
{
    d = Data();
    d.name = "Mouse";

    // in
    // out
    auto out1 = Out_();
         out1.name = "x";
         out1.type = "int";
    d.outs ~= out1;

    auto out2 = Out_();
         out2.name = "y";
         out2.type = "int";
    d.outs ~= out2;

    auto out3 = Out_();
         out3.name = "key";
         out3.type = "int";
    d.outs ~= out3;
}

void create_close( ref Data d )
{
    d = Data();
    d.name = "Close";

    // in
    auto in1 = In_();
         in1.name = "x";
         in1.type = "int";
    d.ins ~= in1;

    auto in2 = In_();
         in2.name = "y";
         in2.type = "int";
    d.ins ~= in2;

    auto in3 = In_();
         in3.name = "key";
         in3.type = "int";
    d.ins ~= in3;

    // out
    auto out1 = Out_();
         out1.name = "x";
         out1.type = "int";
    d.outs ~= out1;

    auto out2 = Out_();
         out2.name = "y";
         out2.type = "int";
    d.outs ~= out2;
}

void create_data( ref Datas ds )
{
    Data d1;
    create_mouse(d1);
    ds.ds ~= d1;

    Data d2;
    create_close(d2);
    ds.ds ~= d2;
}

//pragma( msg, module_name!() );
//pragma( msg, __traits( parent, {} ) );
//pragma( msg, __traits( allMembers, __traits( parent, {} ) ) );
//pragma( msg, __traits( allMembers, mixin( __MODULE__ ) ) );

