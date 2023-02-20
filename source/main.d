import std.conv;
import std.format;
import std.stdio;
import bindbc.sdl;
import op;
import tree;
import area;
import e;
import block;


int main()
{
    // Init
    init_sdl();
    register_custom_events();

    // Tree
    Tree tree;
    create_tree( tree );

    // Window, Surface
    SDL_Window*  window;
    create_window( window );

    // Renderer
    SDL_Renderer* renderer;
    create_renderer( window, renderer );

    // Event Loop
    event_loop( tree, window, renderer );

    return 0;
}


//
void init_sdl()
{
    SDLSupport ret = loadSDL();

    if ( ret != sdlSupport ) 
    {
        if ( ret == SDLSupport.noLibrary ) 
            throw new Exception( "The SDL shared library failed to load" );
        else if ( SDLSupport.badLibrary ) 
            throw new Exception( "One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_204, GLFW_2010 etc.)" );
    }

    loadSDL( "sdl2.dll" );

    // TTF
    SDLTTFSupport ret_ttf = loadSDLTTF();

    if ( ret_ttf != sdlTTFSupport )
    {
        if ( ret_ttf == SDLTTFSupport.noLibrary ) 
            throw new Exception( "The SDL_TTF shared library failed to load" );
        else if ( SDLTTFSupport.badLibrary ) 
            throw new Exception( "One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-sdl was configured to load (via SDL_TTF_2018, etc.)" );
    }

    if ( TTF_Init() )
        throw new Exception( "ERR: TTF_Init()" );
}


//
void create_tree( ref Tree tree )
{
    tree = new Tree;

    //E e1;
    //e1.name( "s" );
    //e1.name = "s";
    //writeln( "This.text: ", e1.name() );
    //writeln( "This.text: ", e1.name );
}


//
void create_window( ref SDL_Window* window )
{
    // Window
    window = 
        SDL_CreateWindow(
            "SDL2 Window",
            SDL_WINDOWPOS_CENTERED,
            SDL_WINDOWPOS_CENTERED,
            640, 480,
            0
        );

    if ( !window )
        throw new SDLException( "Failed to create window" );

    // Update
    SDL_UpdateWindowSurface( window );    
}


//
void create_renderer( SDL_Window* window, ref SDL_Renderer* renderer )
{
    renderer = SDL_CreateRenderer( window, -1, SDL_RENDERER_SOFTWARE );
}


//
void event_loop( Tree tree, ref SDL_Window* window, SDL_Renderer* renderer )
{
    //
    bool game_is_still_running = true;

    // 1st render
    tree.see( renderer );
    SDL_RenderPresent( renderer );

    //
    while ( game_is_still_running )
    {
        SDL_Event e;

        // Process Event
        while ( SDL_PollEvent( &e ) > 0 ) 
        {
            // Quit
            if ( e.type == SDL_QUIT ) 
            {
                game_is_still_running = false;
                break;
            }
            else

            // Key
            if ( e.type == SDL_KEYDOWN || e.type == SDL_KEYUP )
            {
                tree.event( e );
            }
            else

            // Mouse key
            if ( e.type == SDL_MOUSEBUTTONDOWN || e.type == SDL_MOUSEBUTTONUP )
            {
                tree.event( e );
            }
            else

            // Render 1 
            if ( e.type == SDL_USEREVENT )
            {
                if ( e.user.code == SDL_OP.RENDER_1 )
                {
                    auto obj = cast( E* ) e.user.data1;
                    writeln( "SDL_OP.RENDER_1: ", *obj );
                    obj.see( renderer );
    
                    // Rasterize
                    SDL_RenderPresent( renderer );
                }
                else

                if ( e.user.code == SDL_OP.RENDER_RECT )
                {
                    SDL_Rect* send_rect = ( cast( SDL_Rect* )( e.user.data1 ) );
                    writeln( "SDL_OP.RENDER_RECT: ", *send_rect );

                    tree.rect_see( renderer, send_rect );
    
                    // Rasterize
                    SDL_RenderPresent( renderer );

                    //
                    send_rect.destroy();
                }
            }
            else

            // ...
            {            
                //
            }
        }

        // Delay
        SDL_Delay( 100 );
    }        
}


E*[] find_objs_at_rect( ref Tree tree, SDL_Rect* rect )
{
    E*[] found;

    void cb( E* e )
    {
        if ( .rect_hit_test( e, rect ) )
            found ~= e;
    }

    foreach ( block; tree.blocks )
        scan_in_deep( cast(E*)block, &cb );

    return found;
}

alias SCAN_IN_DEEP_CB = void delegate( E* c );
void scan_in_deep( E* root, SCAN_IN_DEEP_CB cb )
{
    cb( root );

    foreach ( ref c; root.childs )
        scan_in_deep( c, cb );
}


//
class SDLException : Exception
{
    this( string msg )
    {
        super( format!"%s: %s"( SDL_GetError().to!string, msg ) );
    }
}
