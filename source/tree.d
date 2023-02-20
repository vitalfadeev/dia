module tree;

import std.conv;
import std.format;
import std.stdio;
import bindbc.sdl;
import op;
import area;
import e;
import block;
import k;
import d;
import name;
import vcc;


// 
class Tree
{
    Block*[] blocks;

    this()
    {
        // data
        Datas ds;
        create_data( ds );

        int xx;
        foreach ( ref d; ds.ds )
        {
            auto block = new Block();
            blocks ~= block;

            // self
            block.rect = SDL_Rect( xx, 0, 32*5, 32*4 );

            // name
            block.name = new name.Name();
            block.name.rect = SDL_Rect( xx, 0, 32*5, 32*1 );
            block.name.text = d.name;

            // vcc
            block.vcc = new Vcc();

            // ins
            {
                int i;
                foreach ( ref ins; d.ins )
                {
                    auto k1 = new K();
                    k1.text = ins.name;
                    k1.type = ins.type;
                    k1.rect = SDL_Rect( xx, 32+i*32, 32*2, 32 );
                    block.ks ~= k1;

                    i++;
                }
            }

            // outs
            {
                int i;
                foreach ( ref outs; d.outs )
                {
                    auto d1 = new D();
                    d1.text = outs.name;
                    d1.type = outs.type;
                    d1.rect = SDL_Rect( xx+32*3, 32+i*32, 32*2, 32 );
                    block.ds ~= d1;

                    i++;
                }
            }
        
            xx += 32*10;
        }
    }

    //override
    size_t see( SDL_Renderer* renderer )
    {
        foreach ( block; blocks )
            block.see( renderer );

        return 0;
    }

    size_t rect_see( SDL_Renderer* renderer, SDL_Rect* rect )
    {
        foreach ( block; blocks )
            block.rect_see( renderer, rect );

        return 0;
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
                foreach ( block; blocks )
                    block.er( block, op, arg, arg2 );
                break;
            default:
        }
    }
}


