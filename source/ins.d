module ins;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import bindbc.sdl;
import bindbc.sdl.ttf;
import sdlexception;
import op;
import e;


struct Ins
{
    mixin EOBJECT;

    string type;
}


