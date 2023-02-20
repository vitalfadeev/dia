module op;

import bindbc.sdl;
//import defs;


struct _SDL_OP
{
    Uint32 CREATE;
    Uint32 CREATED;
    Uint32 RENDER_1;
    Uint32 RENDER_RECT;
    Uint32 RENDERED;
    Uint32 KEYDOWN;
    Uint32 KEYUP;
    Uint32 CLICK;
    Uint32 CLICKED;
    Uint32 TIMER;
    Uint32 GET_TEXT;
    Uint32 GET_IMAGE;
}
shared
_SDL_OP SDL_OP;

// SDL_UserEvent()
// SDL_RegisterEvents()
void register_custom_events()
{
    SDL_OP.CREATE      = SDL_RegisterEvents( 1 );
    SDL_OP.CREATED     = SDL_RegisterEvents( 1 );
    SDL_OP.RENDER_1    = SDL_RegisterEvents( 1 );
    SDL_OP.RENDER_RECT = SDL_RegisterEvents( 1 );
    SDL_OP.RENDERED    = SDL_RegisterEvents( 1 );
    SDL_OP.KEYDOWN     = SDL_RegisterEvents( 1 );
    SDL_OP.KEYUP       = SDL_RegisterEvents( 1 );
    SDL_OP.CLICK       = SDL_RegisterEvents( 1 );
    SDL_OP.CLICKED     = SDL_RegisterEvents( 1 );
    SDL_OP.TIMER       = SDL_RegisterEvents( 1 );
    SDL_OP.GET_TEXT    = SDL_RegisterEvents( 1 );
    SDL_OP.GET_IMAGE   = SDL_RegisterEvents( 1 );
}


enum OP : size_t
{
    TOUCH,
    SEE,
    RECT_SEE,
    HIT_TEST,
    RECT_HIT_TEST,
    MOUSE_MOVE,
    MOUSE_KEY,
    ADD_CHILD,
    DEL_CHILD,
    SELECT,
    UNSELECT,
    MOVE,
    CP_MOVED,
    FOCUS,
    VCC_ON,
    VCC_OFF,
}
