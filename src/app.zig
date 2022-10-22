// Author: Dylan Turner
// Description: Contain SDL set up and such

const sdl = @import("sdl.zig");
const snake = @import("snake.zig");
const settings = @import("settings.zig");
const err = @import("error.zig");
const res = @import("res.zig");

const GameState = enum {
    Title,
    Playing,
    GameOver
};

pub const App = struct {
    window: *sdl.Window,
    renderer: *sdl.Renderer,

    // Game objects
    player: snake.Snake,
    title_spr: res.Sprite,

    state: GameState,

    pub fn init() !App {
        if(sdl.init(sdl.INIT_VIDEO) < 0) {
            sdl.log("Unable to initialize SDL: %s", sdl.getError());
            return err.SnakeError.InitFailed;
        }
        const window = sdl.createWindow(
            "Snake", 0, 0, settings.WINDOW_WIDTH, settings.WINDOW_HEIGHT, 0
        ) orelse {
            sdl.log("Unable to initialize SDL: %s", sdl.getError());
            return err.SnakeError.InitFailed;
        };
        const renderer = sdl.createRenderer(window, -1, sdl.RENDERER_ACCELERATED) orelse {
            sdl.log("Unable to initialize SDL: %s", sdl.getError());
            return err.SnakeError.InitFailed;
        };

        _ = sdl.setRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);

        if(sdl.imgInit(sdl.INIT_PNG) & sdl.INIT_PNG == 0) {
            sdl.log("Unable to initialize SDL_image: %s", sdl.imgGetError());
            return err.SnakeError.ImgInitFailed;
        }

        return App {
            .renderer = renderer,
            .window = window,

            .player = try snake.Snake.init(renderer),
            .title_spr = try res.Sprite.init(@ptrCast(*const u8, "img/title.png"), renderer),

            .state = GameState.Title
        };
    }

    pub fn handle_event(_: *App, event: sdl.Event) void {
        switch(event.@"type") {
            else => {}
        }
    }

    pub fn update(app: *App, dt: f64) void {
        app.player.update(dt);
        // TODO: Other game objects
        
        switch(app.state) {
            GameState.Title => {
                const kb_state = sdl.getKeyboardState(null);
                if(kb_state[sdl.SCANCODE_SPACE] != 0) {
                    app.state = GameState.Playing;
                    app.player.state = snake.SnakeState.Reset;
                }
            }, GameState.Playing => {},
            GameState.GameOver => {
                const kb_state = sdl.getKeyboardState(null);
                if(kb_state[sdl.SCANCODE_SPACE] != 0) {
                    app.state = GameState.Title;
                    app.player.state = snake.SnakeState.Invisible;
                }
            }
        }
    }

    pub fn draw(app: *App) void {
        _ = sdl.renderClear(app.renderer);

        switch(app.state) {
            GameState.Title => {
                app.title_spr.draw(app.renderer);
            }, else => {
                app.player.draw(app.renderer);
                // TODO: Make all the game objects render
            }
        }

        _ = sdl.renderPresent(app.renderer);
    }

    pub fn deinit(app: *App) void {
        app.player.deinit();
        sdl.destroyRenderer(app.renderer);
        sdl.destroyWindow(app.window);
        sdl.imgQuit();
        sdl.quit();
    }
};

