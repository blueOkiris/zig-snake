// Author: Dylan Turner
// Description:
// - We only want to import SDL stuff once bc cImport will complain
// - Basically create minimal bindings here

const csdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

pub const Renderer = csdl.SDL_Renderer;
pub const Texture = csdl.SDL_Texture;
pub const Event = csdl.SDL_Event;
pub const Rect = csdl.SDL_Rect;

pub const INIT_VIDEO = csdl.SDL_INIT_VIDEO;
pub const RENDERER_ACCELERATED = csdl.SDL_RENDERER_ACCELERATED;
pub const INIT_PNG = csdl.IMG_INIT_PNG;
pub const QUIT = csdl.SDL_QUIT;

pub const init = csdl.SDL_Init;
pub const log = csdl.SDL_Log;
pub const get_error = csdl.SDL_GetError;
pub const quit = csdl.SDL_Quit;
pub const poll_event = csdl.SDL_PollEvent;
pub const delay = csdl.SDL_Delay;

pub const img_init = csdl.IMG_Init;
pub const img_get_error = csdl.IMG_GetError;
pub const img_quit = csdl.IMG_Quit;
pub const img_load = csdl.IMG_Load;

pub const create_renderer = csdl.SDL_CreateRenderer;
pub const destroy_renderer = csdl.SDL_DestroyRenderer;
pub const set_render_draw_color = csdl.SDL_SetRenderDrawColor;
pub const render_clear = csdl.SDL_RenderClear;
pub const render_present = csdl.SDL_RenderPresent;
pub const render_copy = csdl.SDL_RenderCopy;

pub const create_window = csdl.SDL_CreateWindow;
pub const destroy_window = csdl.SDL_DestroyWindow;

pub const free_surface = csdl.SDL_FreeSurface;

pub const create_texture_from_surface = csdl.SDL_CreateTextureFromSurface;
pub const query_texture = csdl.SDL_QueryTexture;

