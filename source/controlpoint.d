module controlpoint;

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


struct ControlPoint
{
    mixin EOBJECT;

    Block* controlled;
    size_t cid;
    enum cp_size = 5;

    this( Block* b, size_t cid )
    {
        this.controlled = b;
        this.cid = cid;
        switch ( cid )
        {
            case 1: this.rect = SDL_Rect( b.rect.x-cp_size/2,            b.rect.y-cp_size/2+b.rect.h,   cp_size, cp_size ); break;
            case 2: this.rect = SDL_Rect( b.rect.x-cp_size/2+b.rect.w/2, b.rect.y-cp_size/2+b.rect.h,   cp_size, cp_size ); break;
            case 3: this.rect = SDL_Rect( b.rect.x-cp_size/2+b.rect.w,   b.rect.y-cp_size/2+b.rect.h,   cp_size, cp_size ); break;
            case 4: this.rect = SDL_Rect( b.rect.x-cp_size/2,            b.rect.y-cp_size/2+b.rect.h/2, cp_size, cp_size ); break;
            case 5: this.rect = SDL_Rect( b.rect.x-cp_size/2+b.rect.w/2, b.rect.y-cp_size/2+b.rect.h/2, cp_size, cp_size ); break;
            case 6: this.rect = SDL_Rect( b.rect.x-cp_size/2+b.rect.w,   b.rect.y-cp_size/2+b.rect.h/2, cp_size, cp_size ); break;
            case 7: this.rect = SDL_Rect( b.rect.x-cp_size/2,            b.rect.y-cp_size/2,            cp_size, cp_size ); break;
            case 8: this.rect = SDL_Rect( b.rect.x-cp_size/2+b.rect.w/2, b.rect.y-cp_size/2,            cp_size, cp_size ); break;
            case 9: this.rect = SDL_Rect( b.rect.x-cp_size/2+b.rect.w,   b.rect.y-cp_size/2,            cp_size, cp_size ); break;
            default:
        }
    }

    //
    size_t _move( void* This, size_t op, size_t arg, size_t arg2 )
    {
        auto cp = cast(ControlPoint*)This;

        //controlled( Op.CP_MOVED, arg, arg2 );
        return 0;
    }
}
