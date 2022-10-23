// Author: Dylan Turner
// Description: Contain SDL set up and such

const std = @import("std");
const sdl = @import("sdl.zig");
const snake = @import("snake.zig");
const settings = @import("settings.zig");
const err = @import("error.zig");
const res = @import("res.zig");

const GameState = enum {
    Title,
    Playing,
    GameOver,
    Reset
};

pub const App = struct {
    window: *sdl.Window,
    renderer: *sdl.Renderer,
    font: res.Font,

    // Game objects
    player: snake.Snake,
    title_spr: res.Sprite,
    wall_sprs: [8]res.Sprite,
    game_over_txt: res.Text,
    rnd: std.rand.Xoshiro256,

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

        if(sdl.imgInit(sdl.INIT_PNG) & sdl.INIT_PNG == 0) {
            sdl.log("Unable to initialize SDL_image: %s", sdl.imgGetError());
            return err.SnakeError.ImgInitFailed;
        }

        if(sdl.ttfInit() == -1) {
            sdl.log("Unable to initialize SDL_ttf: %s", sdl.ttfGetError());
            return err.SnakeError.TtfInitFailed;
        }

        var font = try res.Font.init(@ptrCast(*const u8, "fonts/Ubuntu-R.ttf"), 32);

        return App {
            .renderer = renderer,
            .window = window,
            .font = font,

            .player = undefined,
            .title_spr = try res.Sprite.init(@ptrCast(*const u8, "img/title.png"), renderer),
            .wall_sprs = .{
                try res.Sprite.init(@ptrCast(*const u8, "img/corner_tl.png"), renderer),
                try res.Sprite.init(@ptrCast(*const u8, "img/corner_tr.png"), renderer),
                try res.Sprite.init(@ptrCast(*const u8, "img/corner_br.png"), renderer),
                try res.Sprite.init(@ptrCast(*const u8, "img/corner_bl.png"), renderer),
                try res.Sprite.init(@ptrCast(*const u8, "img/wall_top.png"), renderer),
                try res.Sprite.init(@ptrCast(*const u8, "img/wall_right.png"), renderer),
                try res.Sprite.init(@ptrCast(*const u8, "img/wall_bottom.png"), renderer),
                try res.Sprite.init(@ptrCast(*const u8, "img/wall_left.png"), renderer)
            },
            .game_over_txt = try res.Text.init(
                &font, @ptrCast(*const u8, "Game Over"), 0xFF, 0xFF, 0xFF, 0xFF, renderer
            ),

            .rnd = std.rand.DefaultPrng.init(@intCast(u64, std.time.milliTimestamp())),

            .state = GameState.Title
        };
    }

    pub fn handle_event(_: *App, event: sdl.Event) void {
        switch(event.@"type") {
            else => {}
        }
    }

    pub fn update(app: *App, dt: f64) !void {
        switch(app.state) {
            GameState.Title => {
                const kb_state = sdl.getKeyboardState(null);
                if(kb_state[sdl.SCANCODE_SPACE] != 0) {
                    app.player = try snake.Snake.init(&app.font, app.renderer, &app.rnd);
                    app.state = GameState.Playing;
                }
            }, GameState.Playing => {
                try app.player.update(dt);

                if(app.player.dead) {
                    app.state = GameState.GameOver;
                }
            }, GameState.GameOver => {
                app.game_over_txt.x = @intToFloat(
                    f32, settings.WINDOW_WIDTH / 2 - @divTrunc(app.game_over_txt.width, 2)
                );
                app.game_over_txt.y = @intToFloat(
                    f32, settings.WINDOW_HEIGHT / 2 - @divTrunc(app.game_over_txt.height, 2)
                );

                const kb_state = sdl.getKeyboardState(null);
                if(kb_state[sdl.SCANCODE_SPACE] != 0) {
                    app.state = GameState.Reset;
                }
            }, GameState.Reset => {
                const kb_state = sdl.getKeyboardState(null);
                if(kb_state[sdl.SCANCODE_SPACE] == 0) {
                    app.player.deinit();
                    app.state = GameState.Title;
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
                app.wall_sprs[0].draw(app.renderer);
                app.wall_sprs[1].x = @intToFloat(f32, (settings.WINDOW_WIDTH / 32) * 32 - 32);
                app.wall_sprs[1].draw(app.renderer);
                app.wall_sprs[2].x = @intToFloat(f32, (settings.WINDOW_WIDTH / 32) * 32 - 32);
                app.wall_sprs[2].y = @intToFloat(f32, (settings.WINDOW_HEIGHT / 32) * 32 - 32);
                app.wall_sprs[2].draw(app.renderer);
                app.wall_sprs[3].y = @intToFloat(f32, (settings.WINDOW_HEIGHT / 32) * 32 - 32);
                app.wall_sprs[3].draw(app.renderer);
                var x: u32 = 1;
                while(x < settings.WINDOW_WIDTH / 32 - 1) {
                    app.wall_sprs[4].x = @intToFloat(f32, x * 32);
                    app.wall_sprs[4].draw(app.renderer);
                    app.wall_sprs[6].x = @intToFloat(f32, x * 32);
                    app.wall_sprs[6].y = @intToFloat(f32, (settings.WINDOW_HEIGHT / 32) * 32 - 32);
                    app.wall_sprs[6].draw(app.renderer);
                    x += 1;
                }
                var y: u32 = 1;
                while(y < settings.WINDOW_HEIGHT / 32 - 1) {
                    app.wall_sprs[5].x = @intToFloat(f32, (settings.WINDOW_WIDTH / 32) * 32 - 32);
                    app.wall_sprs[5].y = @intToFloat(f32, y * 32);
                    app.wall_sprs[5].draw(app.renderer);
                    app.wall_sprs[7].y = @intToFloat(f32, y * 32);
                    app.wall_sprs[7].draw(app.renderer);
                    y += 1;
                }

                // TODO: Make all the game objects render
                app.player.draw(app.renderer); // draw last so it's on top
                
                if(app.state == GameState.GameOver) {
                    app.game_over_txt.draw(app.renderer);
                }
            }
        }

        _ = sdl.renderPresent(app.renderer);
    }

    pub fn deinit(app: *App) void {
        app.game_over_txt.deinit();
        app.font.deinit();
        switch(app.state) {
            GameState.Title => {},
            else => {
                app.player.deinit();
            }
        }
        sdl.destroyRenderer(app.renderer);
        sdl.destroyWindow(app.window);
        sdl.ttfQuit();
        sdl.imgQuit();
        sdl.quit();
    }
};

