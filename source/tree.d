module tree;

import std.conv;
import std.format;
import std.stdio;
import bindbc.sdl;
import op;
import area;
import e;
import block;
import ins;
import name;


// 
class Tree
{
    Block* block = new Block();

    this()
    {
        // data
        Data d;
        create_data( d );

        // self
        block.rect = SDL_Rect( 0, 0, 32*5, 32*3 );

        // name
        block.name = new name.Name();
        block.name.rect = SDL_Rect( 0, 0, 32*5, 32*1 );
        block.name.text = d.name;

        // pins
        {
            int i;
            foreach ( ref ins; d.ins )
            {
                auto in_ = new Ins();
                in_.text = ins.name;
                in_.type = ins.type;
                in_.rect = SDL_Rect( 0, 32+i*32, 32*2, 32 );
                block.ins ~= in_;

                i++;
            }
        }

        // pins
        {
            int i;
            foreach ( ref outs; d.outs )
            {
                auto outs_ = new Ins();
                outs_.text = outs.name;
                outs_.type = outs.type;
                outs_.rect = SDL_Rect( 32*3, 32+i*32, 32*2, 32 );
                block.outs ~= outs_;

                i++;
            }
        }
    }

    //override
    size_t see( SDL_Renderer* renderer )
    {
        return block.see( renderer );
    }

    size_t rect_see( SDL_Renderer* renderer, SDL_Rect* rect )
    {
        return block.rect_see( renderer, rect );
    }

    void event( ref SDL_Event event )
    {
        size_t op;
        size_t arg;
        size_t arg2;

        switch ( event.type )
        {
            case SDL_MOUSEBUTTONDOWN: 
                op  = OP.MOUSE_KEY; 
                arg = event.button.button;
                block.er( block, op, arg, arg2 );
                break;
            default:
        }
    }
}


