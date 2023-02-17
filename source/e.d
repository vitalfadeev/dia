module e;

import std.conv;
import std.format;
import std.stdio;
import std.string;
import std.traits;
import bindbc.sdl;
import bindbc.sdl.ttf;
import sdlexception;
import focused;
import op;


enum Var
{
    color,
    text,
    image,
    font_file,
    font_size,
    name,
    in1,
}

union Val
{
    string    string_;
    string    uint_;
    SDL_Color color;
    E         e;

    this( string s )
    {
        string_ = s;
    }

    void opAssign( string s )
    {
        string_ = s;
    }

    void opAssign( E e )
    {
        this.e = e;
    }

    string toString()
    {
        return "Val(" ~ uint_.to!string ~ ")";
    }
}

alias ER = size_t function( void* This, size_t op, size_t arg, size_t arg2 );


struct E
{
    SDL_Rect rect;
    bool     is_selected;
    bool     is_deleted;
    E*[]     childs;
    E*       parent;
    Val[Var] vars;

    ER er = cast(ER)&.er;

    //
    // get
    auto opDispatch( string name )()
      if ( hasMember!( Var, name ) )
    {
        mixin( " return vars[Var." ~ name ~ "];" );
    }

    // set
    auto opDispatch( string name, T )( T val )
      if ( hasMember!( Var, name ) )
    {
        mixin( "vars[Var." ~ name ~ "] = val;" );
    }

    // get
    Val* get( Var var, ref Val val )
    {
        auto v = var in this.vars;

        if ( v !is null )
            val = *v;

        return v;
    }

    string toString()
    {
        return "E(" ~ vars.to!string ~ ")";
    }
}

size_t er( E* This, size_t op, size_t arg, size_t arg2 )
{
    switch ( op )
    {
        case OP.TOUCH:         return 1;
        case OP.SEE:           return _see( This, op, arg, arg2 );
        case OP.RECT_SEE:      return _rect_see( This, op, arg, arg2 );
        case OP.HIT_TEST:      return _hit_test( This, op, arg, arg2 );
        case OP.RECT_HIT_TEST: return _rect_hit_test( This, op, arg, arg2 );
        case OP.MOUSE_MOVE:    return _mouse_move( This, op, arg, arg2 );
        case OP.MOUSE_KEY:     return _mouse_key( This, op, arg, arg2 );
        case OP.ADD_CHILD:     return _add_child( This, op, arg, arg2 );
        case OP.DEL_CHILD:     return _del_child( This, op, arg, arg2 );
        case OP.SELECT:        return _select( This, op, arg, arg2 );
        case OP.UNSELECT:      return _unselect( This, op, arg, arg2 );
        case OP.FOCUS:         return _focus( This, op, arg, arg2 );
        default:
            return 0;
    }
}


//
size_t _see( E* This, size_t op, size_t arg, size_t arg2 )
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
        SDL_SetRenderDrawColor( renderer, 0xAA, 0xAA, 0xFF, SDL_ALPHA_OPAQUE );
        see_rect( renderer, This.rect );
    }

    return 0;
}

size_t _rect_see( E* This, size_t op, size_t arg, size_t arg2 )
{
    SDL_Renderer* renderer = cast( SDL_Renderer* )arg;
    SDL_Rect*     r        = cast( SDL_Rect* )arg2;

    SDL_SetRenderDrawColor( renderer, 0x00, 0x00, 0x00, SDL_ALPHA_OPAQUE );
    SDL_RenderFillRect( renderer, r );

    size_t htarg  = arg2;
    size_t htarg2 = 0;

    // childs n rect
    foreach ( c; This.childs )
        if ( c.er( c, OP.RECT_HIT_TEST, htarg, htarg2 ) )
            c.er( c, OP.RECT_SEE, arg, arg2 );

    return 0;
}

size_t _hit_test( E* This, size_t op, size_t arg, size_t arg2 )
{
    SDL_Point p;
              p.y = arg & ( typeof(SDL_Point.y).max );
              p.x = ( arg >> p.y.sizeof*8 ) & ( typeof(SDL_Point.y).max );
    return SDL_PointInRect( &p, &This.rect );
}

size_t _rect_hit_test( E* This, size_t op, size_t arg, size_t arg2 )
{
    SDL_Rect* r = cast( SDL_Rect* )arg;

    SDL_Rect result;

    return 
        SDL_IntersectRect( &This.rect, r, &result );
}

size_t _mouse_move( E* This, size_t op, size_t arg, size_t arg2 )
{
    if ( This.er( This, OP.HIT_TEST, arg, arg2 ) )
    {
        //
    }

    return 0;
}

size_t _mouse_key( E* This, size_t op, size_t arg, size_t arg2 )
{
    alias key = arg;
    switch ( key )
    {
        case SDL_BUTTON_LEFT:
        {
            // Focus
            size_t focused_arg = cast(size_t)This;
            This.er( This, OP.FOCUS, focused_arg, arg2 );

            // Select
            if ( !This.is_selected )
                return This.er( This, OP.SELECT, arg, arg2 );
            else
                return This.er( This, OP.UNSELECT, arg, arg2 );
        }
        default:
            return 0;
    }
}

size_t _select( E* This, size_t op, size_t arg, size_t arg2 )
{
    This.is_selected = true;
    This.push_see();

    return 0;
}

size_t _unselect( E* This, size_t op, size_t arg, size_t arg2 )
{
    This.is_selected = false;
    This.push_see();

    return 0;
}

size_t _focus( E* This, size_t op, size_t arg, size_t arg2 )
{
    auto fe = cast( E* )arg;
    focused.focused = fe;
    fe.push_see();

    return 0;
}

size_t _add_child( E* This, size_t op, size_t arg, size_t arg2 )
{
    auto c = cast( E* )arg;

    This.childs ~= c;

    if ( c.parent )
    {
        auto carg = cast( size_t )c;
        auto carg2 = cast( size_t )0;
        auto cparent = c.parent;
        cparent.er( cparent, OP.DEL_CHILD, carg, carg2 );
        c.parent = This;
    }

    return 0;
}

size_t _del_child( E* This, size_t op, size_t arg, size_t arg2 )
{
    import std.algorithm;

    auto c = cast(E*)arg;

    auto i = This.childs.countUntil( c );
    if ( i != -1 )
        This.childs.remove( i );

    c.parent = null;

    return 0;
}


// This.see( renderer )
// to This.opCall( This, op_see, renderer, 0 )
size_t see(T)( T This, SDL_Renderer* renderer )
{
    size_t arg  = cast( size_t )renderer;
    size_t arg2 = 0;
    return This.er( This, OP.SEE, arg, arg2 );
}


size_t rect_see(T)( T This, SDL_Renderer* renderer, SDL_Rect* rect )
{
    size_t arg  = cast( size_t )renderer;
    size_t arg2 = cast( size_t )rect;
    return This.er( This, OP.RECT_SEE, arg, arg2 );
}


void push_see(T)( T This )
{
    // Create new SDL render event
    // Push in SDL Event Loop
    SDL_Event e;
    e.type          = SDL_USEREVENT;
    e.user.code     = SDL_OP.RENDER_1;
    e.user.data1    = cast( void* )This; // FIXME
    auto res = SDL_PushEvent( &e );
    //  1 - success
    //  0 - filtered
    // <0 - error
    if ( res == 0 )
        throw new SDLException( "SDL_PushEvent(): filtered" );
    else if ( res < 0 )
        throw new SDLException( "SDL_PushEvent(): error" );
}

void push_rect_see( ref SDL_Rect rect )
{
    // Create new SDL render event
    // Push in SDL Event Loop
    SDL_Event e;
    e.type          = SDL_USEREVENT;
    e.user.code     = SDL_OP.RENDER_RECT;
    auto send_rect = new SDL_Rect();
    send_rect.x = rect.x;
    send_rect.y = rect.y;
    send_rect.w = rect.w;
    send_rect.h = rect.h;
    e.user.data1  = cast( void* )send_rect; // FIXME
    auto res = SDL_PushEvent( &e );
    //  1 - success
    //  0 - filtered
    // <0 - error
    if ( res == 0 )
        throw new SDLException( "SDL_PushEvent(): filtered" );
    else if ( res < 0 )
        throw new SDLException( "SDL_PushEvent(): error" );
}

size_t see_rect( SDL_Renderer* renderer, ref SDL_Rect rect )
{
    SDL_RenderDrawRect( renderer, &rect );
    return 0;
}    

//void push_see(T)( T* This )
//{
//    // Create new SDL render event
//    // Push in SDL Event Loop
//    SDL_Event e;
//    e.type          = SDL_USEREVENT;
//    e.user.code     = OP.RENDER_1;
//    e.user.data1    = cast( void* )This; // FIXME
//    e.user.data2    = null;
//    auto res = SDL_PushEvent( &e );
//    //  1 - success
//    //  0 - filtered
//    // <0 - error
//    if ( res == 0 )
//        throw new SDLException( "SDL_PushEvent(): filtered" );
//    else if ( res < 0 )
//        throw new SDLException( "SDL_PushEvent(): error" );
//}

void see_text(T)( ref T This, SDL_Renderer* renderer )
{
    Val val;
    string text;
    if ( This.get( Var.text, val ) )
        text = val.string_;
    else
        return;
    //string text = "S";
    string font_file = "InputSansCondensed-Regular.ttf";
    int    font_size = 17;

    if ( text.length > 0 )
    {
        SDL_SetRenderDrawColor( renderer, 0xFF, 0xFF, 0xFF, SDL_ALPHA_OPAQUE );

        // Font
        TTF_Font* font = TTF_OpenFont( font_file.toStringz, font_size );
        if ( !font )
            throw new SDLException( "TTF_OpenFont()" );

        //TTF_SetFontStyle( font, TTF_STYLE_BOLD );

        // Color
        SDL_Color white = { 255, 255, 255 };
        SDL_Color bg_c  = { 0, 0, 0 };

        // Text Rect
        SDL_Rect trect;
        {
            // Content Rect
            SDL_Rect crect;
            content_rect( This, crect );

            // Text Rect
            int w;
            int h;
            if ( TTF_SizeText( font, text.toStringz, &w, &h ) )
                throw new SDLException( "TTF_SizeText()" );
            trect.x = crect.x;
            trect.y = crect.y;
            trect.w = w;
            trect.h = h;

            SDL_Rect px_crect;
            px_crect.x = crect.x;
            px_crect.y = crect.y;
            px_crect.w = crect.w;
            px_crect.h = crect.h;

            // Center Text inside Content Rect
            center_rect_in_rect( trect, px_crect );

            // Clip
            SDL_RenderSetClipRect( renderer, &px_crect );
        }

        // Render
        SDL_Surface* text_surface =
            TTF_RenderText_Solid( font, text.toStringz, white ); 
            //TTF_RenderText_Shaded( font, "Text", white, bg_c ); 

        SDL_Texture* text_texture = 
            SDL_CreateTextureFromSurface( renderer, text_surface );

        // Copy
        SDL_RenderCopy( renderer, text_texture, null, &trect );

        // Free
        SDL_RenderSetClipRect( renderer, null );
        TTF_CloseFont( font );
        SDL_FreeSurface( text_surface );
        SDL_DestroyTexture( text_texture );
    }
}

void content_rect(T)( ref T This, ref SDL_Rect rect )
{
    rect = This.rect;
}

void center_rect_in_rect( ref SDL_Rect a, ref SDL_Rect b )
{
    // x
    if ( b.w > a.w )
    {        
        a.x = b.x + ( b.w / 2 ) - ( a.w / 2 );
    }

    // y
    if ( b.h > a.h )
    {        
        a.y = b.y + ( b.h / 2 ) - ( a.h / 2 );
    }
}


auto ref select(T)( ref T This )
{
    size_t arg  = 0;
    size_t arg2 = 0;
    return This.er( This, OP.SELECT, arg, arg2 );
}


void set( ref E This, Var var, Val val )
{
    This.vars[var] = val;
}
void set( ref E This, Var var, E v )
{
    Val val;
    val.e = v;
    This.vars[var] = val;
}

//Val* get( ref E This, Var var, ref Val val )
//{
//    auto v = var in This.vars;

//    if ( v !is null )
//        val = *v;

//    return v;
//}
//Val* get( ref E This, Var var, ref E e )
//{
//    auto v = var in This.vars;

//    if ( v !is null )
//        e = v.e;

//    return v;
//}

// This.hit_test( point )
// to This.opCall( This, op_hit_test, point, 0 )
pragma( inline, true )
auto ref hit_test(T)( ref T This, ref SDL_Point p )
{
    size_t arg   = cast( size_t )p.x;
           arg <<= p.y.sizeof*8;
           arg  |= p.y;
    size_t arg2 = 0;
    return This.er( This, OP.HIT_TEST, arg, arg2 );
}

// This.rect_hit_test( point )
// to This.opCall( This, op_rect_hit_test, point, 0 )
pragma( inline, true )
auto ref rect_hit_test(T)( ref T This, SDL_Rect* rect )
{
    size_t arg   = cast( size_t )rect;
    size_t arg2 = 0;
    return This.er( This, OP.RECT_HIT_TEST, arg, arg2 );
}

// This.see( renderer )
// to This.opCall( This, op_see, renderer, 0 )
pragma( inline, true )
auto ref rect_hit_test(T)( ref T This, ref SDL_Rect rect )
{
    size_t arg  = cast( size_t )&rect;
    size_t arg2 = 0;
    return This.er( This, OP.RECT_HIT_TEST, arg, arg2 );
}


// This.add_child( c )
// to This.opCall( This, op_add_child, c, 0 )
pragma( inline, true )
auto ref add_child(T,C)( ref T This, ref C c )
{
    size_t arg  = cast( size_t )cast( void* )c;
    size_t arg2 = 0;
    return This.er( This, OP.ADD_CHILD, arg, arg2 );
}

auto ref del_child(T,C)( ref T This, ref C c )
{
    size_t arg  = cast( size_t )c;
    size_t arg2 = 0;
    return This.er( This, OP.DEL_CHILD, arg, arg2 );
}
auto ref del_child(T,C)( ref T This, C* c )
{
    size_t arg  = cast( size_t )&c;
    size_t arg2 = 0;
    return This.er( This, OP.DEL_CHILD, arg, arg2 );
}

//
template op_methods( T, args... )
{
    import std.uni;
    import std.traits;
    import std.meta;

    alias TMODULE = __traits( parent, T );

    bool is_op_method( string NAME )()
    {
        import std.string;

        alias TFUNC = __traits( getMember, TMODULE, NAME );

        static if ( 
            NAME.startsWith( "_" ) && 
            isFunction!TFUNC &&
            is( Parameters!TFUNC == AliasSeq!( T*, size_t, size_t, size_t ) ) &&
            is( ReturnType!TFUNC == size_t )
        )
            return true;
        else
            return false;
    }

    alias op_methods = 
        Filter!( 
            is_op_method, 
            //__traits( allMembers, mixin(__MODULE__) ) 
            __traits( allMembers, TMODULE ) 
        );
}


auto super_er(T)( T This, size_t op, size_t arg, size_t arg2 )
{
    return This._super.init.er( This, op, arg, arg2 );
}

size_t er_mixin(T)( T* This, size_t op, size_t arg, size_t arg2 )
{
    import std.meta; 

    pragma( msg, AliasSeq!( "er_mixin", T, op_methods!T ) );

    alias TMODULE = __traits( parent, T );
    
    switch ( op )
    {
        static 
        foreach ( FNAME; op_methods!T )
        {
        case __traits( getMember, OP, FNAME.toUpper()[1..$] ): return __traits( getMember, TMODULE, FNAME )( This, op, arg, arg2 );
        }

        default:
            return super_er( This, op, arg, arg2 );
    }
}

mixin template EOBJECT(T=E)
{
    T _super = { er: cast(ER)&er_mixin!( typeof( this ) ) };
    alias _super this;
}
