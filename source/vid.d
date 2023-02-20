module vid;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import bindbc.sdl;
import bindbc.sdl.ttf;
import sdlexception;
import op;
import e;


// ----------
//    Vid
// ----------
// x
// y
// w
// h
// -
// see    see - image, surface, window
// ----------

struct Vid
{
    E*       tree_root;
    SDL_Rect rect; // x, y, w, h - offset, size
}


size_t see( Vid* vid, SDL_Renderer* renderer )
{
    return 0;
}

