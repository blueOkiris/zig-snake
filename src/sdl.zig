// Author: Dylan Turner
// Description:
// - We only want to import SDL stuff once bc cImport will complain
// - Basically create minimal bindings here

const csdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

pub const Renderer = csdl.SDL_Renderer;
pub const Window = csdl.SDL_Window;
pub const Texture = csdl.SDL_Texture;
pub const Event = csdl.SDL_Event;
pub const Rect = csdl.SDL_Rect;

pub const INIT_VIDEO = csdl.SDL_INIT_VIDEO;
pub const RENDERER_ACCELERATED = csdl.SDL_RENDERER_ACCELERATED;
pub const INIT_PNG = csdl.IMG_INIT_PNG;
pub const QUIT = csdl.SDL_QUIT;
pub const SCANCODE_SPACE = csdl.SDL_SCANCODE_SPACE;
pub const SCANCODE_RIGHT = csdl.SDL_SCANCODE_RIGHT;
pub const SCANCODE_DOWN = csdl.SDL_SCANCODE_DOWN;
pub const SCANCODE_LEFT = csdl.SDL_SCANCODE_LEFT;
pub const SCANCODE_UP = csdl.SDL_SCANCODE_UP;
pub const FLIP_NONE = csdl.SDL_FLIP_NONE;

pub const init = csdl.SDL_Init;
pub const log = csdl.SDL_Log;
pub const getError = csdl.SDL_GetError;
pub const quit = csdl.SDL_Quit;
pub const pollEvent = csdl.SDL_PollEvent;
pub const getKeyboardState = csdl.SDL_GetKeyboardState;
pub const delay = csdl.SDL_Delay;

pub const imgInit = csdl.IMG_Init;
pub const imgGetError = csdl.IMG_GetError;
pub const imgQuit = csdl.IMG_Quit;
pub const imgLoad = csdl.IMG_Load;

pub const createRenderer = csdl.SDL_CreateRenderer;
pub const destroyRenderer = csdl.SDL_DestroyRenderer;
pub const setRenderDrawColor = csdl.SDL_SetRenderDrawColor;
pub const renderClear = csdl.SDL_RenderClear;
pub const renderPresent = csdl.SDL_RenderPresent;
pub const renderCopy = csdl.SDL_RenderCopy;
pub const renderCopyEx = csdl.SDL_RenderCopyEx;

pub const createWindow = csdl.SDL_CreateWindow;
pub const destroyWindow = csdl.SDL_DestroyWindow;

pub const freeSurface = csdl.SDL_FreeSurface;

pub const createTextureFromSurface = csdl.SDL_CreateTextureFromSurface;
pub const queryTexture = csdl.SDL_QueryTexture;
pub const destroyTexture = csdl.SDL_DestroyTexture;

