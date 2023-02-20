module dgate;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import bindbc.sdl;
import bindbc.sdl.ttf;
import sdlexception;
import op;
import e;


struct DGate
{
    mixin EOBJECT;

    enum gate_size = 5;
}


size_t _see( DGate* This, size_t op, size_t arg, size_t arg2 )
{
    SDL_Renderer* renderer = cast( SDL_Renderer* )arg;
    SDL_SetRenderDrawColor( renderer, 0xCC, 0xCC, 0xCC, SDL_ALPHA_OPAQUE );
    SDL_Point p = SDL_Point( This.rect.x + This.rect.w, This.rect.y + This.rect.h/2 );
    int gate_size = 5;
    see_round( renderer, p, DGate.gate_size );

    return 0;
}

