module window;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import bindbc.sdl;
import bindbc.sdl.ttf;
import sdlexception;
import op;
import e;


struct Window
{
    mixin EOBJECT;

    SDL_Window* win;
}


size_t _see( Window* This, size_t op, size_t arg, size_t arg2 )
{
    SDL_Renderer* renderer = cast( SDL_Renderer* )arg;
    SDL_SetRenderDrawColor( renderer, 0xCC, 0xCC, 0xCC, SDL_ALPHA_OPAQUE );
    see_rect( renderer, This.rect );

    return 0;
}

size_t _vcc_on( Window* This, size_t op, size_t arg, size_t arg2 )
{
    // Window
    This.win = 
        SDL_CreateWindow(
            "SDL2 Window",
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            640, 480,
            0
        );

    if ( !This.win )
        throw new SDLException( "Failed to create window" );

    // Update
    SDL_UpdateWindowSurface( This.win );

    return 0;
}

size_t _vcc_off( Window* This, size_t op, size_t arg, size_t arg2 )
{
    // Window
    SDL_DestroyWindow( This.win );

    return 0;
}

