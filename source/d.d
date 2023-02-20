module d;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import bindbc.sdl;
import bindbc.sdl.ttf;
import sdlexception;
import op;
import e;
import dgate;


struct D
{
    mixin EOBJECT;

    string type;
    DGate  gate;
}


size_t _see( D* This, size_t op, size_t arg, size_t arg2 )
{
    super_er( This, op, arg, arg2 );

    This.gate.rect = This.rect;
    This.gate.er( &This.gate, op, arg, arg2 );

    return 0;
}

